import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ═══════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════

class AttendanceRecord {
  final String studentId;
  final String studentName;
  final DateTime scannedAt;

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'studentName': studentName,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) =>
      AttendanceRecord(
        studentId: j['studentId'] as String,
        studentName: j['studentName'] as String,
        scannedAt: DateTime.parse(j['scannedAt'] as String),
      );
}

class AttendanceSession {
  final String id;
  String fileName;
  final DateTime createdAt;
  DateTime lastModified;
  List<AttendanceRecord> records;
  String? excelPath;
  bool isExported;

  AttendanceSession({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.lastModified,
    required this.records,
    this.excelPath,
    this.isExported = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
        'records': records.map((r) => r.toJson()).toList(),
        'excelPath': excelPath,
        'isExported': isExported,
      };

  factory AttendanceSession.fromJson(Map<String, dynamic> j) =>
      AttendanceSession(
        id: j['id'] as String,
        fileName: j['fileName'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        lastModified: DateTime.parse(j['lastModified'] as String),
        records: (j['records'] as List)
            .map((r) =>
                AttendanceRecord.fromJson(r as Map<String, dynamic>))
            .toList(),
        excelPath: j['excelPath'] as String?,
        isExported: j['isExported'] as bool? ?? false,
      );
}

// ═══════════════════════════════════════════════════════════════
// LOCAL STORAGE
// ═══════════════════════════════════════════════════════════════

class SessionStorage {
  static const _indexFile = 'sessions_index.json';

  static Future<String> getDirPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } catch (_) {
      final dir = await getTemporaryDirectory();
      return dir.path;
    }
  }

  static Future<File> _getFile() async {
    final path = await getDirPath();
    return File('$path/$_indexFile');
  }

  static Future<List<AttendanceSession>> loadAll() async {
    try {
      final f = await _getFile();
      if (!await f.exists()) return [];
      final raw = await f.readAsString();
      final list = jsonDecode(raw) as List;
      return list
          .map((e) =>
              AttendanceSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<AttendanceSession> sessions) async {
    try {
      final f = await _getFile();
      await f.writeAsString(
          jsonEncode(sessions.map((s) => s.toJson()).toList()));
    } catch (_) {}
  }

  static Future<void> upsert(AttendanceSession session) async {
    final all = await loadAll();
    final idx = all.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      all[idx] = session;
    } else {
      all.insert(0, session);
    }
    await _save(all);
  }

  static Future<void> delete(String sessionId) async {
    final all = await loadAll();
    final session = all.where((s) => s.id == sessionId).firstOrNull;
    if (session?.excelPath != null) {
      try {
        final f = File(session!.excelPath!);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    all.removeWhere((s) => s.id == sessionId);
    await _save(all);
  }
}

// ═══════════════════════════════════════════════════════════════
// NOTIFICATION MODEL — drives the animated overlay in the view
// ═══════════════════════════════════════════════════════════════

class ScanNotification {
  final String title;
  final String subtitle;
  final bool isSuccess; // true = green, false = orange/red

  const ScanNotification({
    required this.title,
    required this.subtitle,
    required this.isSuccess,
  });
}

// ═══════════════════════════════════════════════════════════════
// ACTIVE SCANNER CONTROLLER
// ═══════════════════════════════════════════════════════════════

class AttendanceScannerController extends GetxController {
  final _supabase = Supabase.instance.client;

  final records = <AttendanceRecord>[].obs;
  final isProcessing = false.obs;
  final fileReady = false.obs;
  final isSaving = false.obs;

  // ── Overlay notification (replaces Get.snackbar in scanner screen) ─────────
  final Rx<ScanNotification?> notification = Rx<ScanNotification?>(null);

  late AttendanceSession _session;

  String get fileName => _session.fileName;
  String? get savedFilePath => _session.excelPath;

  void initSession({AttendanceSession? existing, String? newFileName}) {
    if (existing != null) {
      _session = existing;
      records.assignAll(_session.records);
      if (_session.isExported) fileReady.value = true;
    } else {
      _session = AttendanceSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: newFileName ?? 'attendance',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        records: [],
      );
      SessionStorage.upsert(_session);
    }
  }

  Future<AttendanceRecord?> onQrScanned(String rawValue) async {
    if (rawValue.trim().isEmpty) return null;
    isProcessing.value = true;
    final record = await _fetchStudent(rawValue.trim());
    isProcessing.value = false;
    if (record == null) return null;

    if (_alreadyAdded(record.studentId)) {
      _notify('Already Scanned', record.studentName, isSuccess: false);
      return null;
    }

    records.add(record);
    _session.records = records.toList();
    _autoSave();
    _notify('✓  Attendance Recorded', record.studentName, isSuccess: true);
    return record;
  }

  Future<AttendanceRecord?> onManualEntry(String studentId) async {
    final id = studentId.trim();
    if (id.isEmpty) {
      _notify('Empty ID', 'Please enter a student ID.', isSuccess: false);
      return null;
    }
    if (!RegExp(r'^\d{6,10}$').hasMatch(id)) {
      _notify('Invalid ID', 'Student ID must be 6–10 digits.', isSuccess: false);
      return null;
    }

    isProcessing.value = true;
    final record = await _fetchStudent(id);
    isProcessing.value = false;
    if (record == null) return null;

    if (_alreadyAdded(record.studentId)) {
      _notify('Already Added', record.studentName, isSuccess: false);
      return null;
    }

    records.add(record);
    _session.records = records.toList();
    _autoSave();
    _notify('✓  Attendance Recorded', record.studentName, isSuccess: true);
    return record;
  }

  // ── Overlay trigger ────────────────────────────────────────────────────────
  void _notify(String title, String subtitle, {required bool isSuccess}) {
    notification.value =
        ScanNotification(title: title, subtitle: subtitle, isSuccess: isSuccess);
    Future.delayed(const Duration(seconds: 3), () {
      notification.value = null;
    });
  }

  // ── Export ─────────────────────────────────────────────────────────────────
  Future<void> exportToExcel() async {
    if (records.isEmpty) {
      Get.snackbar('No Records', 'There are no students to export yet.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12);
      return;
    }

    isProcessing.value = true;
    try {
      final excel = Excel.createExcel();
      excel.rename('Sheet1', 'Attendance');
      final sheet = excel['Attendance'];

      sheet.appendRow([
        TextCellValue('Student ID'),
        TextCellValue('Student Name'),
        TextCellValue('Time'),
        TextCellValue('Date'),
      ]);

      for (final r in records) {
        sheet.appendRow([
          TextCellValue(r.studentId),
          TextCellValue(r.studentName),
          TextCellValue(
              '${r.scannedAt.hour.toString().padLeft(2, '0')}:${r.scannedAt.minute.toString().padLeft(2, '0')}'),
          TextCellValue(
              '${r.scannedAt.day.toString().padLeft(2, '0')}/${r.scannedAt.month.toString().padLeft(2, '0')}/${r.scannedAt.year}'),
        ]);
      }

      final dirPath = await SessionStorage.getDirPath();
      final safe = _session.fileName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final path = '$dirPath/${safe}_${_session.id}.xlsx';

      final bytes = excel.save();
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Excel encoding produced no bytes.');
      }

      await File(path).writeAsBytes(bytes, flush: true);
      _session.excelPath = path;
      _session.isExported = true;
      _session.lastModified = DateTime.now();
      await SessionStorage.upsert(_session);

      fileReady.value = true;
    } catch (e) {
      Get.snackbar('Export Failed', 'Could not create Excel file. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> downloadFile() async {
    if (_session.excelPath == null) return;
    await Share.shareXFiles(
        [XFile(_session.excelPath!)],
        text: 'Attendance: ${_session.fileName}');
  }

  Future<void> shareFile() async {
    if (_session.excelPath == null) return;
    await Share.shareXFiles([XFile(_session.excelPath!)]);
  }

  void reset() {
    records.clear();
    fileReady.value = false;
    isProcessing.value = false;
  }

  Future<void> _autoSave() async {
    isSaving.value = true;
    _session.lastModified = DateTime.now();
    await SessionStorage.upsert(_session);
    await Future.delayed(const Duration(milliseconds: 600));
    isSaving.value = false;
  }

  bool _alreadyAdded(String id) => records.any((r) => r.studentId == id);

  Future<AttendanceRecord?> _fetchStudent(String studentId) async {
    try {
      final result = await _supabase
          .from('students')
          .select('student_id, full_name')
          .eq('student_id', studentId)
          .maybeSingle();

      if (result == null) {
        _notify('Student Not Found', 'No student with ID: $studentId',
            isSuccess: false);
        return null;
      }

      return AttendanceRecord(
        studentId: studentId,
        studentName: result['full_name'] as String? ?? studentId,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        _notify('No Connection', 'Check your internet and try again.',
            isSuccess: false);
      } else {
        _notify('Error', 'Could not fetch student data.', isSuccess: false);
      }
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// SAVED SESSIONS CONTROLLER
// ═══════════════════════════════════════════════════════════════

class SavedSessionsController extends GetxController {
  final sessions = <AttendanceSession>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  Future<void> loadSessions() async {
    isLoading.value = true;
    final all = await SessionStorage.loadAll();
    sessions.assignAll(all);
    isLoading.value = false;
  }

  Future<void> deleteSession(String id) async {
    await SessionStorage.delete(id);
    sessions.removeWhere((s) => s.id == id);
  }

  Future<void> shareSession(AttendanceSession session) async {
    if (session.excelPath == null) return;
    final file = File(session.excelPath!);
    if (!await file.exists()) return;
    await Share.shareXFiles([XFile(session.excelPath!)],
        text: 'Attendance: ${session.fileName}');
  }
}
