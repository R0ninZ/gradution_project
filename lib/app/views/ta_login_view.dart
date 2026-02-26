import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/ta_login_controller.dart';

class TaLoginView extends StatelessWidget {
  const TaLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double headerHeight = 320.0;

    return GetBuilder<TaLoginController>(
      init: TaLoginController(),
      global: false,
      builder: (c) {
        return Scaffold(
          // ── Dark-theme aware background ─────────────────────────────────
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header with curved clip ─────────────────────────────────
                Stack(
                  children: [
                    ClipPath(
                      clipper: SubtleCurveClipper(),
                      child: Container(
                        height: headerHeight,
                        width: double.infinity,
                        color: isDark
                            ? const Color(0xFF1A1A2E)
                            : const Color(0xFF003366),
                      ),
                    ),
                    SizedBox(
                      height: headerHeight - 40,
                      width: double.infinity,
                      child: SafeArea(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: IconButton(
                                  onPressed: Get.back,
                                  icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 20),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  'assets/logo.png',
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Form area ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('sign_in'.tr,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 24),
                      _buildTextField(
                        context: context,
                        controller: c.emailCtrl,
                        hint: 'enter_email'.tr,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context: context,
                        controller: c.passwordCtrl,
                        hint: 'enter_password'.tr,
                        icon: c.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        obscureText: c.obscurePassword,
                        onIconPressed: c.toggleObscure,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      // ── Sign in button ─────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: c.isLoading ? null : c.signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1A1A2E)
                                : const Color(0xFF003366),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: c.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text('sign_in'.tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Don't have account ─────────────────────────────────
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('dont_have_account'.tr,
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey)),
                            GestureDetector(
                              onTap: () => Get.toNamed('/ta-signup'),
                              child: Text('sign_up'.tr,
                                  style: const TextStyle(
                                      color: Color(0xFF3E82F7),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Are you a student ─────────────────────────────────
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('are_you_student'.tr,
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey)),
                            GestureDetector(
                              onTap: Get.back,
                              child: Text('sign_in_here'.tr,
                                  style: const TextStyle(
                                      color: Color(0xFF3E82F7),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    IconData? icon,
    bool obscureText = false,
    VoidCallback? onIconPressed,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: Colors.grey[700]!, width: 1)
            : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14),
          suffixIcon: icon != null
              ? IconButton(
                  icon: Icon(icon,
                      color: isDark ? Colors.grey[400] : Colors.grey),
                  onPressed: onIconPressed)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

class SubtleCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
