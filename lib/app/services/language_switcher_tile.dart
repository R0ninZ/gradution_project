import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'language_service.dart';

class LanguageSwitcherTile extends StatelessWidget {
  const LanguageSwitcherTile({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageService>();

    return Obx(() {
      final isAr = lang.isArabic;

      return GestureDetector(
        onTap: lang.toggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Icon box (matches your other info rows)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B66).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Color(0xFF0D3B66),
                  size: 19,
                ),
              ),
              const SizedBox(width: 14),

              // Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'language'.tr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr ? 'العربية' : 'English',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),

              // EN / AR animated pill
              _LangPill(isArabic: isAr),
            ],
          ),
        ),
      );
    });
  }
}

class _LangPill extends StatelessWidget {
  final bool isArabic;
  const _LangPill({required this.isArabic});

  @override
  Widget build(BuildContext context) {
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
                    letterSpacing: 0.5,
                  ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
