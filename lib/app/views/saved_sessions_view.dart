import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/attendance_scanner_controller.dart';
import 'package:gradution_project/app/views/attendance_scanner_view.dart';

class SavedSessionsView extends StatelessWidget {
  const SavedSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SavedSessionsController());

    return Scaffold(
      backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBar(ctrl: ctrl),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D3B66)),
                  );
                }
                if (ctrl.sessions.isEmpty) {
                  return _EmptyState();
                }
                return RefreshIndicator(
                  color: const Color(0xFF0D3B66),
                  onRefresh: ctrl.loadSessions,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: ctrl.sessions.length,
                    itemBuilder: (_, i) => _SessionCard(
                      session: ctrl.sessions[i],
                      index: i,
                      ctrl: ctrl,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final SavedSessionsController ctrl;
  const _AppBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: Colors.white),
                ),
              ),
              const Spacer(),
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ctrl.sessions.length} ${'sessions'.tr}',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'saved_sessions'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'tap_to_resume'.tr,
            style:
                TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Session card with stagger-in animation + swipe to delete
// ─────────────────────────────────────────────────────────────

class _SessionCard extends StatefulWidget {
  final AttendanceSession session;
  final int index;
  final SavedSessionsController ctrl;

  const _SessionCard({
    required this.session,
    required this.index,
    required this.ctrl,
  });

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final hasExcel = s.excelPath != null;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: Key(s.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 14),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                SizedBox(height: 4),
                Text('delete'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (_) => _DeleteDialog(name: s.fileName),
                ) ??
                false;
          },
          onDismissed: (_) => widget.ctrl.deleteSession(s.id),
          child: GestureDetector(
            onTap: () {
              Get.to(
                () => AttendanceScannerView(resumeSession: s),
                transition: Transition.fadeIn,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Theme.of(Get.context!).brightness == Brightness.dark ? 0.3 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).brightness == Brightness.dark
                          ? (hasExcel ? const Color(0xFF1A2E1A) : const Color(0xFF1A2040))
                          : (hasExcel ? const Color(0xFFE8F5E9) : const Color(0xFFEFF4FF)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      hasExcel
                          ? Icons.table_chart_rounded
                          : Icons.pending_actions_rounded,
                      color: hasExcel
                          ? const Color(0xFF1D6F42)
                          : const Color(0xFF0D3B66),
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.fileName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.white : const Color(0xFF0D2B55),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Student count badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF4FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${s.records.length} ${'students'.tr}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF3E82F7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: hasExcel
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hasExcel ? 'exported'.tr : 'in_progress'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: hasExcel
                                      ? const Color(0xFF1D6F42)
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(s.lastModified),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),

                  // Right actions
                  Column(
                    children: [
                      if (hasExcel)
                        GestureDetector(
                          onTap: () => widget.ctrl.shareSession(s),
                          child: const Icon(Icons.share_rounded,
                              color: Color(0xFF3E82F7), size: 20),
                        ),
                      const SizedBox(height: 8),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey, size: 22),
                    ],
                  ),
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
// Delete confirmation dialog
// ─────────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  final String name;
  const _DeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('delete_session'.tr,
          style: TextStyle(fontWeight: FontWeight.bold)),
      content:
          Text('${'delete_confirm_prefix'.tr}$name${'delete_confirm_suffix'.tr}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child:
              Text('cancel'.tr, style: const TextStyle(color: Color(0xFF0D3B66))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text('delete'.tr),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty state with bounce-in animation
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatefulWidget {
  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.7, end: 1.05), weight: 70),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.05, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
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
      child: ScaleTransition(
        scale: _scale,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B66).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.folder_open_rounded,
                    color: Color(0xFF0D3B66), size: 50),
              ),
              const SizedBox(height: 20),
              Text('no_saved_sessions'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2B55),
                  )),
              const SizedBox(height: 8),
              Text(
                'sessions_auto_saved_hint'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
