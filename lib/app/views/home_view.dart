import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // ================= REAL TIME DATE =================

  String getFormattedDate() {
    final now = DateTime.now();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return '${days[now.weekday - 1]}, '
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),

          // ================= BODY =================
          body: SingleChildScrollView(
            child: Column(
              children: [

                _header(c),

                const SizedBox(height: 20),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: _aiBuddyCard(c),
                ),

                const SizedBox(height: 28),

                _eventsSection(),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // ================= NAV BAR =================
          bottomNavigationBar: _bottomNavBar(),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to attendance/QR scanner page
              Get.toNamed('/attendance');
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: _qrButton(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _header(HomeController c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D3B66),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const CircleAvatar(
                radius: 22,
                backgroundImage:
                    AssetImage('assets/avatar.png'),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    'Hi, ${c.firstName} 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'Happy semester!',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [

              const Text(
                '2025/2026-1st Semester',
                style: TextStyle(color: Colors.white),
              ),

              Text(
                getFormattedDate(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // AI BUDDY CARD
  // =========================================================

  Widget _aiBuddyCard(HomeController c) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 600, // Prevents stretching on desktop
      ),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: AssetImage('assets/Robot banner.png'),
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
        ),

        child: Container(
          padding: const EdgeInsets.only(
            left: 0,
            right: 16,
            top: 14,
            bottom: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.75),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.25, 0.95],
            ),
          ),

          child: Row(
            children: [

              // LEFT SPACE FOR ROBOT (reduced to account for image padding)
              const Expanded(flex: 35, child: SizedBox()),

              // RIGHT CONTENT
              Expanded(
                flex: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // CHIP
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Personal AI Buddy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // TEXT
                    const Text(
                      'How may I help you\ntoday!',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // BUTTON
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3366BB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          elevation: 0,
                        ),
                        onPressed: c.goToChatbot,
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  // =========================================================
  // EVENTS
  // =========================================================

  Widget _eventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _eventCard(
          'Machine learning session',
          'Oct 21, 10:00 AM',
          'BNU, building f, floor 3',
          'assets/ml.png',
        ),

        _eventCard(
          'Speaker Session / Tech Talk',
          'Oct 30, 10:30 AM',
          'GDG on BNU-Obour, Egypt',
          'assets/tech.png',
        ),

        _eventCard(
          'Workshop / Study Group',
          'Nov 3, 10:30 AM',
          'GDG on BNU-Obour, Egypt',
          'assets/flutter.png',
        ),
      ],
    );
  }

  Widget _eventCard(
    String title,
    String date,
    String location,
    String image,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [

            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14),
                      const SizedBox(width: 4),
                      Text(date),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14),
                      const SizedBox(width: 4),
                      Expanded(child: Text(location)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // QR BUTTON
  // =========================================================

  Widget _qrButton() {
    return Container(
      height: 65,
      width: 65,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1E1B5E),
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
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [

            _navItem(
              icon: Icons.home,
              label: 'Home',
              isActive: true,
              onTap: () {},
            ),

            _navItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {
                Get.toNamed('/profile');
              },
            ),

            // ATTENDANCE (CENTER WITH QR)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Attendance',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),

            _navItem(
              icon: Icons.groups_outlined,
              label: 'Community',
              onTap: () {
                Get.toNamed('/community');
              },
            ),

            _navItem(
              icon: Icons.calendar_today_outlined,
              label: 'Events',
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
    final color =
        isActive ? const Color(0xFF0D3B66) : Colors.grey[600];

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Icon(icon, color: color, size: 28),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isActive
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}