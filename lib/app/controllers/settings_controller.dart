import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/language_service.dart';

class SettingsController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _lang = Get.find<LanguageService>();

  static const _themeKey = 'is_dark_mode';

  final isDarkMode = false.obs;

  bool get isArabic => _lang.isArabic;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// Called once from main() before runApp so the theme is ready on first frame.
  void applyThemeOnStartup(bool dark) {
    isDarkMode.value = dark;
    _applyTheme(dark);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_themeKey) ?? false;
    _applyTheme(isDarkMode.value);
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);
    _applyTheme(isDarkMode.value);
  }

  void _applyTheme(bool dark) {
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleLanguage() async {
    await _lang.toggle();
    update();
  }

  Future<void> contactSupport() async {
    final uri = Uri.parse(
      'https://wa.me/201011280453?text=Hello%2C%20I%20need%20support%20with%20BNU%20Connect',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Cannot Open WhatsApp',
        'Please make sure WhatsApp is installed.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('log_out'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('log_out_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child:
                Text('cancel'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Get.back(result: true),
            child: Text('log_out'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _supabase.auth.signOut();
      Get.offAllNamed('/login');
    }
  }
}
