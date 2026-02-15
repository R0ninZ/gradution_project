import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/attendance_controller.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(
      builder: (c) {
        if (c.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D3B66),
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0D3B66),
          
          body: SafeArea(
            child: Column(
              children: [
                
                // BACK BUTTON
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),

                const Spacer(),

                // AVATAR
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFE8B4A0),
                    image: const DecorationImage(
                      image: AssetImage('assets/avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // NAME
                Text(
                  c.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // SUBTITLE
                const Text(
                  'Attendance QR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const Spacer(),

                // QR CODE
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: c.studentId,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // SCAN TEXT
                const Text(
                  '- Scan -',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),

          // BOTTOM NAV BAR
          bottomNavigationBar: _bottomNavBar(),
          floatingActionButton: _qrButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  // =========================================================
  // QR BUTTON (ACTIVE STATE)
  // =========================================================

  Widget _qrButton() {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1B5E),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B5E).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  // =========================================================
  // BOTTOM NAV BAR
  // =========================================================

  Widget _bottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            _navItem(
              icon: Icons.home_outlined,
              label: 'Home',
              isActive: false,
              onTap: () => Get.back(),
            ),

            _navItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: false,
              onTap: () {
                Get.toNamed('/profile');
              },
            ),

            // ATTENDANCE (CENTER WITH QR) - ACTIVE
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Attendance',
                  style: TextStyle(
                    color: const Color(0xFF1E1B5E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            _navItem(
              icon: Icons.groups_outlined,
              label: 'Community',
              isActive: false,
              onTap: () {
                Get.toNamed('/community');
              },
            ),

            _navItem(
              icon: Icons.calendar_today_outlined,
              label: 'Events',
              isActive: false,
              onTap: () {
                Get.toNamed('/events');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF0D3B66) : Colors.grey[600];

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}