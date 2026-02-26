import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  /// Returns a fully localized date string, e.g. "Friday, 20/02/2026"
  String _formattedDate() {
    final now = DateTime.now();
    final dayKey = 'day_${now.weekday}'; // day_1 … day_7
    return '$dayKey'.tr + ', '
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (c) {
        if (c.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _header(c, isDark),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _aiBuddyCard(c),
                ),
                const SizedBox(height: 28),
                _qrSection(c, context),
                const SizedBox(height: 30),
              ],
            ),
          ),
          bottomNavigationBar: _bottomNavBar(isDark),
        );
      },
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _header(HomeController c, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: date + academic year ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _pill(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 6),
                    Text(_formattedDate(),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              _pill(
                child: Text('academic_year'.tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Profile row ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.toNamed('/profile'),
                child: Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        color: const Color(0xFF1A4A8A),
                      ),
                      child: ClipOval(
                        child: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                            ? Image.network(c.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _defaultAvatar(c.fullName, 70))
                            : _defaultAvatar(c.fullName, 70),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E82F7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 'hi'.tr already contains 'Hi, ' / 'مرحبًا، '
                        Text(
                          '${'hi'.tr}${c.firstName}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'happy_semester'.tr,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      );

  Widget _defaultAvatar(String fullName, double size) {
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF1A4A8A),
      child: Center(
        child: Text(initials,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.33)),
      ),
    );
  }

  // =========================================================
  // AI BUDDY CARD
  // =========================================================

  Widget _aiBuddyCard(HomeController c) {
    const double cardHeight = 155.0;
    const double robotWidth = 175.0;
    const double robotHeight = 270.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SizedBox(
          height: cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D2B55), Color(0xFF1A4A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D3B66).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              // Decoration circles
              Positioned(
                top: -10, right: -10,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20, left: 140,
                child: Container(
                  width: 75, height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              // Robot image
              Positioned(
                left: 0, top: 0, bottom: 0,
                width: robotWidth,
                child: OverflowBox(
                  alignment: Alignment.center,
                  minHeight: robotHeight,
                  maxHeight: robotHeight,
                  child: Image.asset(
                    'assets/Robot banner.png',
                    width: robotWidth,
                    height: robotHeight,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              // Text content
              Positioned(
                left: robotWidth + 4, top: 0, right: 0, bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge — localized
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'personal_ai_buddy'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Tagline — localized
                      Text(
                        'how_may_i_help'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.3),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E82F7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: c.goToChatbot,
                          child: Text('get_started'.tr,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // QR SECTION
  // =========================================================

  Widget _qrSection(HomeController c, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2B55), Color(0xFF1A4A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D3B66).withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Badge — localized ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_rounded,
                          color: Colors.white, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'attendance_qr'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(c.fullName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 4),

            // ── Subtitle — localized ─────────────────────────────────────
            Text(
              c.hasFullName
                  ? 'show_qr_to_mark'.tr
                  : 'complete_profile_qr'.tr,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.65), fontSize: 12),
            ),

            const SizedBox(height: 24),

            // ── QR with optional blur overlay ────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: QrImageView(
                      data: c.studentId.isNotEmpty ? c.studentId : 'pending',
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0D3B66)),
                      dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0D3B66)),
                    ),
                  ),

                  // Blur overlay — only when full name is missing
                  if (!c.hasFullName)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            color: Colors.black.withOpacity(0.45),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.white,
                                      size: 32),
                                ),
                                const SizedBox(height: 12),
                                // ── Localized overlay text ────────────────
                                Text('qr_locked'.tr,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'qr_locked_subtitle'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        height: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                GestureDetector(
                                  onTap: () => Get.toNamed('/profile'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3E82F7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'go_to_profile_arrow'.tr,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Scan divider — only when QR is unlocked ──────────────────
            if (c.hasFullName)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 1,
                      width: 50,
                      color: Colors.white.withOpacity(0.3)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('scan_to_register'.tr,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 1)),
                  ),
                  Container(
                      height: 1,
                      width: 50,
                      color: Colors.white.withOpacity(0.3)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // BOTTOM NAV BAR
  // =========================================================

  Widget _bottomNavBar(bool isDark) {
    return BottomAppBar(
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_rounded, 'home'.tr,
                isActive: true, isDark: isDark, onTap: () {}),
            _navItem(Icons.person_outline, 'profile'.tr,
                isDark: isDark, onTap: () => Get.toNamed('/profile')),
            _navItem(Icons.groups_outlined, 'community'.tr,
                isDark: isDark, onTap: () => Get.offAllNamed('/community')),
            _navItem(Icons.settings_outlined, 'settings'.tr,
                isDark: isDark,
                onTap: () => Get.offAllNamed('/settings',
                    arguments: {'isTA': false})),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool isActive = false,
      required bool isDark,
      required VoidCallback onTap}) {
    final color = isActive
        ? (isDark ? const Color(0xFF3E82F7) : const Color(0xFF0D3B66))
        : (isDark ? Colors.grey[500]! : Colors.grey[600]!);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}
