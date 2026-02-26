import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:gradution_project/app/controllers/attendance_scanner_controller.dart';

// ═══════════════════════════════════════════════════════════════
// Animated page transition helper
// ═══════════════════════════════════════════════════════════════

class _FadeSlide extends PageRouteBuilder {
  final Widget child;
  _FadeSlide(this.child)
      : super(
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, anim, __, c) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: c,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 380),
        );
}

// ═══════════════════════════════════════════════════════════════
// ENTRY POINT
// ═══════════════════════════════════════════════════════════════

class AttendanceScannerView extends StatelessWidget {
  final AttendanceSession? resumeSession;
  const AttendanceScannerView({super.key, this.resumeSession});

  @override
  Widget build(BuildContext context) {
    if (resumeSession != null) {
      final ctrl =
          Get.put(AttendanceScannerController(), tag: resumeSession!.id);
      ctrl.initSession(existing: resumeSession);
      return _ScannerStep(controller: ctrl);
    }
    return const _NameStep();
  }
}

// ═══════════════════════════════════════════════════════════════
// STEP 0 — Name the file
// ═══════════════════════════════════════════════════════════════

class _NameStep extends StatefulWidget {
  const _NameStep();

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep>
    with SingleTickerProviderStateMixin {
  final _textCtrl = TextEditingController();
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _textCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _anim.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _next() {
    final name =
        _textCtrl.text.trim().isEmpty ? 'attendance' : _textCtrl.text.trim();
    final ctrl = Get.put(AttendanceScannerController());
    ctrl.initSession(newFileName: name);
    Navigator.of(context).push(_FadeSlide(_ScannerStep(controller: ctrl)));
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _textCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Color(0xFF0D3B66)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D3B66).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.drive_file_rename_outline_rounded,
                        color: Color(0xFF0D3B66), size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'choose_file_name'.tr,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2B55),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'file_name_subtitle'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 36),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: hasInput
                          ? [
                              BoxShadow(
                                color:
                                    const Color(0xFF3E82F7).withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: _textCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'enter_name'.tr,
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 15),
                        filled: true,
                        fillColor: Theme.of(Get.context!).cardColor,
                        prefixIcon: const Icon(Icons.folder_outlined,
                            color: Color(0xFF3E82F7), size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF3E82F7), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedScale(
                    scale: hasInput ? 1.0 : 0.97,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasInput
                              ? const Color(0xFF0D3B66)
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: hasInput ? 3 : 0,
                          shadowColor: const Color(0xFF0D3B66).withOpacity(0.4),
                        ),
                        onPressed: hasInput ? _next : null,
                        child: Text('next'.tr,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STEP 1 — Camera Scanner
// ═══════════════════════════════════════════════════════════════

class _ScannerStep extends StatefulWidget {
  final AttendanceScannerController controller;
  const _ScannerStep({required this.controller});

  @override
  State<_ScannerStep> createState() => _ScannerStepState();
}

class _ScannerStepState extends State<_ScannerStep>
    with TickerProviderStateMixin {
  final MobileScannerController _cam = MobileScannerController();
  bool _paused = false;
  bool _isDoneLoading = false;

  final _flashChips = <AttendanceRecord>[];

  late AnimationController _lineCtrl;
  late Animation<double> _lineAnim;
  late AnimationController _countCtrl;
  late Animation<double> _countScale;
  int _prevCount = 0;

  // Store the ever() worker so we can cancel it in dispose
  late final Worker _recordsWorker;

  @override
  void initState() {
    super.initState();

    _lineCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);

    _countCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _countScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));

    _recordsWorker = ever(widget.controller.records, (list) {
      if (!mounted) return;
      if (list.length > _prevCount) {
        _prevCount = list.length;
        _countCtrl.forward(from: 0);
        if (list.isNotEmpty) _addFlashChip(list.last);
      }
    });
  }

  void _addFlashChip(AttendanceRecord record) {
    if (!mounted) return;
    setState(() => _flashChips.insert(0, record));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _flashChips.remove(record));
    });
  }

  @override
  void dispose() {
    _recordsWorker.dispose();
    _cam.stop();
    _cam.dispose();
    _lineCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  // FIX: QR scan no longer shows a bottom sheet — success is shown
  // via top snackbar in the controller. Camera resumes immediately.
  void _onDetect(String code) async {
    if (_paused) return;
    _paused = true;
    await _cam.stop();

    await widget.controller.onQrScanned(code);

    // Small delay so the snackbar appears before camera restarts
    await Future.delayed(const Duration(milliseconds: 400));

    _paused = false;
    if (mounted) _cam.start();
  }

  Future<void> _done() async {
    if (_isDoneLoading) return;
    setState(() => _isDoneLoading = true);
    await _cam.stop();

    try {
      await widget.controller.exportToExcel();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          _FadeSlide(_FileReadyStep(controller: widget.controller)),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Export Failed',
          'Could not save the file: $e',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        _cam.start();
      }
    } finally {
      if (mounted) setState(() => _isDoneLoading = false);
    }
  }

  Future<void> _goBack() async {
    await _cam.stop();
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: _goBack,
        ),
        title: Text('scanner'.tr,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Obx(() => AnimatedOpacity(
                opacity: widget.controller.isSaving.value ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: Colors.white54),
                        ),
                        SizedBox(width: 4),
                        Text('saving'.tr,
                            style:
                                TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              )),
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: ScaleTransition(
                    scale: _countScale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.controller.records.isEmpty
                            ? Colors.white24
                            : const Color(0xFF3E82F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.controller.records.length} ${'scanned'.tr}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cam,
            onDetect: (capture) {
              final code = capture.barcodes.firstOrNull?.rawValue;
              if (code != null) _onDetect(code);
            },
          ),
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                children: [
                  ..._buildCorners(),
                  AnimatedBuilder(
                    animation: _lineAnim,
                    builder: (_, __) => Positioned(
                      top: 8 + (_lineAnim.value * 224),
                      left: 8,
                      right: 8,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF3E82F7).withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3E82F7).withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => widget.controller.isProcessing.value
              ? IgnorePointer(
                  child: Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.88),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Flash chips show at bottom as a secondary indicator
                  if (_flashChips.isNotEmpty) ...[
                    ..._flashChips.take(3).map((r) =>
                        _RecentScanChip(key: ValueKey(r.studentId), record: r)),
                    const SizedBox(height: 14),
                  ],
                  // Manual entry button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side:
                            const BorderSide(color: Colors.white54, width: 1.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () async {
                        await _cam.stop();
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _ManualEntrySheet(
                            onSubmit: (id) async {
                              // ever() worker handles the flash chip.
                              // Controller handles the top snackbar.
                              await widget.controller.onManualEntry(id);
                            },
                          ),
                        );
                        if (mounted) _cam.start();
                      },
                      child: Text('or_enter_code'.tr,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B66),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      onPressed: _isDoneLoading ? null : _done,
                      child: _isDoneLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text('done'.tr,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const c = Color(0xFF3E82F7);
    const t = 3.0;
    const l = 28.0;
    const r = Radius.circular(4);
    return [
      Positioned(
          top: 0,
          left: 0,
          child: _Corner(
              color: c,
              thickness: t,
              length: l,
              radius: r,
              top: true,
              left: true)),
      Positioned(
          top: 0,
          right: 0,
          child: _Corner(
              color: c,
              thickness: t,
              length: l,
              radius: r,
              top: true,
              left: false)),
      Positioned(
          bottom: 0,
          left: 0,
          child: _Corner(
              color: c,
              thickness: t,
              length: l,
              radius: r,
              top: false,
              left: true)),
      Positioned(
          bottom: 0,
          right: 0,
          child: _Corner(
              color: c,
              thickness: t,
              length: l,
              radius: r,
              top: false,
              left: false)),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// Corner bracket widget
// ─────────────────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  final Color color;
  final double thickness, length;
  final Radius radius;
  final bool top, left;

  const _Corner({
    required this.color,
    required this.thickness,
    required this.length,
    required this.radius,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: length,
      height: length,
      child: CustomPaint(
        painter: _CornerPainter(color, thickness, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top, left;

  _CornerPainter(this.color, this.thickness,
      {required this.top, required this.left});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = left ? 0.0 : s.width;
    final y = top ? 0.0 : s.height;
    final dx = left ? s.width : -s.width;
    final dy = top ? s.height : -s.height;

    c.drawLine(Offset(x, y), Offset(x + dx, y), p);
    c.drawLine(Offset(x, y), Offset(x, y + dy), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
// Recent scan chip — slides in at bottom, fades out after 3s
// ─────────────────────────────────────────────────────────────

class _RecentScanChip extends StatefulWidget {
  final AttendanceRecord record;
  const _RecentScanChip({super.key, required this.record});

  @override
  State<_RecentScanChip> createState() => _RecentScanChipState();
}

class _RecentScanChipState extends State<_RecentScanChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350))
      ..forward();
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _c.reverse();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.record.studentName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
              Text(widget.record.studentId,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.55), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Manual entry bottom sheet
// ═══════════════════════════════════════════════════════════════

class _ManualEntrySheet extends StatefulWidget {
  final Future<void> Function(String) onSubmit;
  const _ManualEntrySheet({required this.onSubmit});

  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _loading = false;
  late AnimationController _anim;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.badge_rounded,
                    color: Color(0xFF0D3B66), size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'enter_student_code'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2B55),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'enter_student_code_subtitle'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'student_id_label'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D3B66),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'student_id_placeholder'.tr,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  suffixIcon: const Icon(Icons.badge_outlined,
                      color: Color(0xFF3E82F7), size: 22),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FB),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF3E82F7), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B66),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_ctrl.text.trim().isEmpty) return;
                          setState(() => _loading = true);
                          await widget.onSubmit(_ctrl.text.trim());
                          if (mounted) Navigator.of(context).pop();
                        },
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('done'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STEP 2 — File Ready
// ═══════════════════════════════════════════════════════════════

class _FileReadyStep extends StatefulWidget {
  final AttendanceScannerController controller;
  const _FileReadyStep({required this.controller});

  @override
  State<_FileReadyStep> createState() => _FileReadyStepState();
}

class _FileReadyStepState extends State<_FileReadyStep>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      widget.controller.reset();
                      Get.back();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Color(0xFF0D3B66)),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _pulse,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3E82F7).withOpacity(0.12),
                            ),
                            child: Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF3E82F7),
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 44),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'your_file_is_ready'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D2B55),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'session_auto_saved'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.table_chart_rounded,
                                  color: Color(0xFF1D6F42), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.controller.fileName}.xlsx',
                                style: const TextStyle(
                                  color: Color(0xFF0D2B55),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() => Text(
                              '${widget.controller.records.length} ${'students_recorded'.tr}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3E82F7),
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _StaggerButton(
                    delay: 0,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B66),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        onPressed: widget.controller.downloadFile,
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: Text('download'.tr,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StaggerButton(
                    delay: 80,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E82F7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        onPressed: widget.controller.shareFile,
                        icon: const Icon(Icons.share_rounded, size: 20),
                        label: Text('share_file'.tr,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StaggerButton(
                    delay: 160,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          widget.controller.reset();
                          Get.back();
                        },
                        child: Text(
                          'back_to_home'.tr,
                          style: TextStyle(
                            color: Color(0xFF0D3B66),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stagger animation wrapper
// ─────────────────────────────────────────────────────────────

class _StaggerButton extends StatefulWidget {
  final Widget child;
  final int delay;
  const _StaggerButton({required this.child, required this.delay});

  @override
  State<_StaggerButton> createState() => _StaggerButtonState();
}

class _StaggerButtonState extends State<_StaggerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 300 + widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}
