import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends GetxController {
  static const String _langKey = 'selected_language';

  final RxString currentLang = 'en'.obs;

  bool get isArabic => currentLang.value == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_langKey) ?? 'en';
    currentLang.value = saved;
    _applyLocale(saved);
  }

  Future<void> switchToEnglish() async {
    await _switch('en');
  }

  Future<void> switchToArabic() async {
    await _switch('ar');
  }

  Future<void> toggle() async {
    await _switch(isArabic ? 'en' : 'ar');
  }

  Future<void> _switch(String lang) async {
    if (currentLang.value == lang) return;
    currentLang.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
    _applyLocale(lang);
  }

  void _applyLocale(String lang) {
    final locale =
        lang == 'ar' ? const Locale('ar', 'AR') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }
}
