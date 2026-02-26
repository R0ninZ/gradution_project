import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  bool isLoading = true;
  bool isSaving = false;

  String firstName = '';
  String lastName = '';
  String fullNameField = '';
  String email = '';
  String studentId = '';
  String track = '';
  String? avatarUrl;
  String? linkedin;

  late String editTrack;

  String get fullName => '$firstName $lastName';

  final List<String> trackOptions = ['AI', 'AIM', 'SAD', 'DAS'];

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading = true;
      update();

      final user = _supabase.auth.currentUser;
      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      final data = await _supabase
          .from('students')
          .select('first_name, last_name, full_name, student_id, track, avatar_url, linkedin')
          .eq('id', user.id)
          .single();

      firstName = data['first_name'] ?? '';
      lastName = data['last_name'] ?? '';
      fullNameField = data['full_name'] ?? '';
      email = user.email ?? '';
      studentId = data['student_id'] ?? '';
      track = data['track'] ?? '';
      linkedin = data['linkedin'];
      editTrack = track;

      final rawUrl = data['avatar_url'] as String?;
      if (rawUrl != null && rawUrl.isNotEmpty) {
        final base = rawUrl.contains('?') ? rawUrl.split('?').first : rawUrl;
        avatarUrl = '$base?t=${DateTime.now().millisecondsSinceEpoch}';
      } else {
        avatarUrl = null;
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Could not load profile. Check your internet.', isError: true);
      } else {
        _snack('Error', 'Failed to load profile. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> saveChanges({
    required String newFirstName,
    required String newLastName,
    required String newFullName,
    required String newStudentId,
    required String newTrack,
    required String newLinkedin,
  }) async {
    // Validate inputs before saving
    if (newFirstName.trim().isEmpty || newLastName.trim().isEmpty) {
      _snack('Missing Name', 'First and last name cannot be empty.', isError: true);
      return;
    }
    if (newStudentId.trim().isEmpty) {
      _snack('Missing Student ID', 'Student ID cannot be empty.', isError: true);
      return;
    }
    if (!RegExp(r'^\d{8}$').hasMatch(newStudentId.trim())) {
      _snack('Invalid Student ID', 'Student ID must be exactly 8 digits.', isError: true);
      return;
    }
    if (newLinkedin.trim().isNotEmpty &&
        !newLinkedin.trim().startsWith('https://linkedin.com/in/') &&
        !newLinkedin.trim().startsWith('https://www.linkedin.com/in/')) {
      _snack('Invalid LinkedIn URL', 'LinkedIn URL must start with https://linkedin.com/in/', isError: true);
      return;
    }

    try {
      isSaving = true;
      update();

      final user = _supabase.auth.currentUser;
      if (user == null) { Get.offAllNamed('/login'); return; }

      await _supabase.from('students').update({
        'first_name': newFirstName.trim(),
        'last_name': newLastName.trim(),
        'full_name': newFullName.trim().isEmpty ? null : newFullName.trim(),
        'student_id': newStudentId.trim(),
        'track': newTrack,
        'linkedin': newLinkedin.trim().isEmpty ? null : newLinkedin.trim(),
      }).eq('id', user.id);

      firstName = newFirstName.trim();
      lastName = newLastName.trim();
      fullNameField = newFullName.trim();
      studentId = newStudentId.trim();
      track = newTrack;
      linkedin = newLinkedin.trim().isEmpty ? null : newLinkedin.trim();

      _syncToHome();
      Get.back();
      _snack('Saved ✓', 'Your profile has been updated.', isError: false);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Could not save changes. Check your internet.', isError: true);
      } else {
        _snack('Save Failed', 'Something went wrong. Please try again.', isError: true);
      }
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> pickAndUploadAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      isSaving = true;
      update();

      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
      final path = 'avatars/${user.id}/avatar';

      try { await _supabase.storage.from('avatars').remove([path]); } catch (_) {}

      await _supabase.storage.from('avatars').uploadBinary(
        path, bytes,
        fileOptions: FileOptions(upsert: true, contentType: mime),
      );

      final baseUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      final cacheBustedUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      await _supabase.from('students').update({'avatar_url': cacheBustedUrl}).eq('id', user.id);

      avatarUrl = cacheBustedUrl;
      _syncToHome();
      _snack('Photo Updated ✓', 'Your profile picture has been updated.', isError: false);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Could not upload image. Check your internet.', isError: true);
      } else if (msg.contains('size') || msg.contains('large')) {
        _snack('Image Too Large', 'Please choose a smaller image.', isError: true);
      } else {
        _snack('Upload Failed', 'Could not upload image. Please try again.', isError: true);
      }
    } finally {
      isSaving = false;
      update();
    }
  }

  void _syncToHome() {
    try {
      final home = Get.find<HomeController>();
      home.firstName = firstName;
      home.fullName = fullName;
      home.avatarUrl = avatarUrl;
      home.hasFullName = fullNameField.isNotEmpty;
      home.update();
    } catch (_) {}
  }

  void _snack(String title, String message, {required bool isError}) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF4CAF50),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: Colors.white,
      ),
    );
  }
}
