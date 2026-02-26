import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (c) {
        if (c.isLoading) {
          return Scaffold(
              backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          body: Column(
            children: [
              _header(c),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                  child: Column(
                    children: [
                      _infoCard(c),
                      const SizedBox(height: 24),
                      _editButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _bottomNavBar(),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _header(ProfileController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 36), // spacer to keep title centered
            ],
          ),
          const SizedBox(height: 16),
          Text('my_profile'.tr,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Stack(
            children: [
              GestureDetector(
                onTap: c.pickAndUploadAvatar,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: const Color(0xFFDDE6F0)),
                  child: ClipOval(
                    child: c.isSaving
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Color(0xFF0D3B66)))
                        : c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                            ? Image.network(c.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _defaultAvatar(c.fullName))
                            : _defaultAvatar(c.fullName),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: c.pickAndUploadAvatar,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: const Color(0xFF3E82F7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(c.fullName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              c.track.isEmpty ? 'no_track_set'.tr : c.track,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar(String fullName) {
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';
    return Container(
      color: const Color(0xFF1A4A8A),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32)),
      ),
    );
  }

  // ── Info card — no logout, no language (moved to settings) ─────────────────
  Widget _infoCard(ProfileController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.person_outline_rounded, 'full_name'.tr, c.fullName),
          _divider(),
          _infoRow(Icons.email_outlined, 'email'.tr, c.email),
          _divider(),
          _infoRow(Icons.badge_outlined, 'student_id'.tr, c.studentId),
          _divider(),
          _infoRow(Icons.school_outlined, 'track_specialization'.tr,
              c.track.isEmpty ? '—' : c.track),
          if (c.linkedin != null && c.linkedin!.isNotEmpty) ...[
            _divider(),
            _infoRow(Icons.link_rounded, 'linkedin'.tr, c.linkedin!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: const Color(0xFF0D3B66).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF0D3B66), size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(Get.context!).colorScheme.onSurface),
              )  ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey[100], height: 1);

  Widget _editButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B66),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0),
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: Text('edit_profile'.tr,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        onPressed: () => Get.toNamed('/edit-profile'),
      ),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────
  Widget _bottomNavBar() {
    return BottomAppBar(
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_outlined, 'home'.tr,
                onTap: () => Get.offAllNamed('/home')),
            _navItem(Icons.person_rounded, 'profile'.tr,
                isActive: true, onTap: () {}),
            _navItem(Icons.groups_outlined, 'community'.tr,
                onTap: () => Get.offAllNamed('/community')),
            _navItem(Icons.settings_outlined, 'settings'.tr,
                onTap: () => Get.offAllNamed('/settings',
                    arguments: {'isTA': false})),
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
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}
