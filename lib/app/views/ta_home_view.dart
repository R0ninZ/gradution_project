import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/ta_home_controller.dart';

class TaHomeView extends StatelessWidget {
  const TaHomeView({super.key});

  String getFormattedDate() {
    final now = DateTime.now();
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${days[now.weekday - 1]}, '
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaHomeController>(
      builder: (c) {
        if (c.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _header(c),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _aiBuddyCard(c),
                ),
                const SizedBox(height: 28),
                _scannerSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          bottomNavigationBar: _bottomNavBar(),
        );
      },
    );
  }

  Widget _header(TaHomeController c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 6),
                    Text(getFormattedDate(),
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('academic_year'.tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.toNamed('/ta-profile'),
                child: Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          color: const Color(0xFF1A4A8A)),
                      child: ClipOval(
                        child: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                            ? Image.network(c.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _defaultAvatar(c.fullName, 70))
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
                            border: Border.all(color: Colors.white, width: 1.5)),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 11),
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
                        Text('${'hi'.tr}${c.firstName}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('teaching_assistant'.tr,
                        style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar(String fullName, double size) {
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
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

  Widget _aiBuddyCard(TaHomeController c) {
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
                          offset: const Offset(0, 8))
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: robotWidth,
                child: OverflowBox(
                  alignment: Alignment.center,
                  minHeight: robotHeight,
                  maxHeight: robotHeight,
                  child: Image.asset('assets/Robot banner.png',
                      width: robotWidth, height: robotHeight, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                left: robotWidth + 4,
                top: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('personal_ai_buddy'.tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 6),
                      Text('how_may_i_help'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              height: 1.3)),
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
                              elevation: 0),
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

  Widget _scannerSection() {
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
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  Text('attendance_scanner'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 20),
            Text('scan_student_qr'.tr,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('scan_qr_subtitle'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.5)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E82F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0),
                onPressed: () => Get.toNamed('/attendance-scanner'),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: Text('start_scanning'.tr,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(height: 1, width: 60, color: Colors.white.withOpacity(0.25)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or'.tr,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                ),
                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.25))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                onPressed: () => Get.toNamed('/attendance-sessions'),
                icon: const Icon(Icons.folder_outlined, size: 18),
                label: Text('view_saved_sessions'.tr,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomAppBar(
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_rounded, 'home'.tr, isActive: true, onTap: () {}),
            _navItem(Icons.person_outline, 'profile'.tr,
                onTap: () => Get.toNamed('/ta-profile')),
            _navItem(Icons.settings_outlined, 'settings'.tr,
                onTap: () => Get.offAllNamed('/settings',
                    arguments: {'isTA': true})),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool isActive = false, required VoidCallback onTap}) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final color = isActive ? (isDark ? const Color(0xFF3E82F7) : const Color(0xFF0D3B66)) : (isDark ? Colors.grey[500]! : Colors.grey[600]!);
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
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}
