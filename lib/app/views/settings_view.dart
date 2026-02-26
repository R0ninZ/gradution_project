import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

/// SettingsView is now an independent navbar tab.
/// Pass `isTA: true` via Get.arguments when navigating from TA screens.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  bool get _isTA {
    final args = Get.arguments;
    if (args is Map) return args['isTA'] == true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Controller is permanent — just find it, never recreate it.
    final c = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FA);
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final sectionColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _header(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('preferences'.tr, sectionColor),
                  const SizedBox(height: 10),
                  _card(cardColor, isDark, [
                    _themeToggle(c, isDark),
                    _divider(isDark),
                    _languageToggle(c, isDark),
                  ]),

                  const SizedBox(height: 24),
                  _sectionLabel('support'.tr, sectionColor),
                  const SizedBox(height: 10),
                  _card(cardColor, isDark, [
                    _tappableRow(
                      icon: Icons.support_agent_rounded,
                      label: 'contact_support'.tr,
                      iconColor: const Color(0xFF25D366),
                      onTap: c.contactSupport,
                      isDark: isDark,
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _sectionLabel('account'.tr, sectionColor),
                  const SizedBox(height: 10),
                  _card(cardColor, isDark, [
                    _tappableRow(
                      icon: Icons.logout_rounded,
                      label: 'log_out'.tr,
                      iconColor: Colors.redAccent,
                      labelColor: Colors.redAccent,
                      onTap: c.logout,
                      isDark: isDark,
                    ),
                  ]),

                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'BNU Connect v1.0.0',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isTA ? _taNabBar() : _studentNavBar(),
    );
  }

  // ── Header (no back button — this is a main tab) ──────────────────────────
  Widget _header(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D3B66),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Text(
        'settings'.tr,
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────────────────
  Widget _card(Color cardColor, bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _sectionLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label.toUpperCase(),
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1)),
    );
  }

  Widget _divider(bool isDark) => Divider(
      color: isDark ? Colors.grey[800] : Colors.grey[100],
      height: 1,
      indent: 58,
      endIndent: 16);

  // ── Theme toggle ───────────────────────────────────────────────────────────
  Widget _themeToggle(SettingsController c, bool isDark) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _iconBox(
                c.isDarkMode.value
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                c.isDarkMode.value
                    ? const Color(0xFF5C6BC0)
                    : const Color(0xFFFFA726),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('appearance'.tr,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Text(
                      c.isDarkMode.value ? 'dark_mode'.tr : 'light_mode'.tr,
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: c.isDarkMode.value,
                onChanged: (_) => c.toggleTheme(),
                activeColor: const Color(0xFF3E82F7),
              ),
            ],
          ),
        ));
  }

  // ── Language toggle ────────────────────────────────────────────────────────
  Widget _languageToggle(SettingsController c, bool isDark) {
    return GetBuilder<SettingsController>(
      builder: (_) => GestureDetector(
        onTap: c.toggleLanguage,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _iconBox(Icons.language_rounded, const Color(0xFF0D3B66)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('language'.tr,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Text(
                      c.isArabic ? 'العربية' : 'English',
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              _langPill(c.isArabic),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tappable row ───────────────────────────────────────────────────────────
  Widget _tappableRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    Color iconColor = const Color(0xFF0D3B66),
    Color? labelColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            _iconBox(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: labelColor ??
                          (isDark ? Colors.white : const Color(0xFF1A1A2E)))),
            ),
            Icon(Icons.chevron_right_rounded,
                color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _langPill(bool isArabic) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 74,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B66).withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment:
                isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 37,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B66),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  isArabic ? 'AR' : 'EN',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
            ),
          ),
          Align(
            alignment:
                isArabic ? Alignment.centerLeft : Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                isArabic ? 'EN' : 'AR',
                style: TextStyle(
                    color: const Color(0xFF0D3B66).withOpacity(0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Student bottom navbar ─────────────────────────────────────────────────
  Widget _studentNavBar() {
    return _buildNavBar([
      _navItem(Icons.home_outlined, 'home'.tr,
          onTap: () => Get.offAllNamed('/home')),
      _navItem(Icons.person_outline, 'profile'.tr,
          onTap: () => Get.offAllNamed('/profile')),
      _navItem(Icons.groups_outlined, 'community'.tr,
          onTap: () => Get.offAllNamed('/community')),
      _navItem(Icons.settings_rounded, 'settings'.tr,
          isActive: true, onTap: () {}),
    ]);
  }

  // ── TA bottom navbar ──────────────────────────────────────────────────────
  Widget _taNabBar() {
    return _buildNavBar([
      _navItem(Icons.home_outlined, 'home'.tr,
          onTap: () => Get.offAllNamed('/ta-home')),
      _navItem(Icons.person_outline, 'profile'.tr,
          onTap: () => Get.offAllNamed('/ta-profile')),
      _navItem(Icons.settings_rounded, 'settings'.tr,
          isActive: true, onTap: () {}),
    ]);
  }

  Widget _buildNavBar(List<Widget> items) {
    return BottomAppBar(
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items,
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool isActive = false, required VoidCallback onTap}) {
    final color = isActive ? const Color(0xFF0D3B66) : Colors.grey[600];
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}
