import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/ta_sign_up_controller.dart';

class TaSignUpView extends StatelessWidget {
  const TaSignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<TaSignUpController>(
      init: TaSignUpController(),
      global: false,
      builder: (c) {
        return WillPopScope(
          onWillPop: () async {
            if (c.currentStep == 2) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('cancel_registration_title'.tr),
                  content: Text('cancel_registration_msg'.tr),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('stay'.tr)),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('leave'.tr,
                            style: const TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await c.abandonRegistration();
                return true;
              }
              return false;
            }
            return true;
          },
          child: Scaffold(
            // ── Dark-theme aware background ───────────────────────────────
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: c.currentStep == 1
                ? _step1(context, c, isDark)
                : _step2(context, c, isDark),
          ),
        );
      },
    );
  }

  // =========================================================
  // STEP 1 — Registration form
  // =========================================================

  Widget _step1(BuildContext context, TaSignUpController c, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _curvedHeader(context, isDark, showBack: true),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ta_sign_up'.tr,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 6),
                Text('create_ta_account'.tr,
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600])),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            context: context,
                            controller: c.firstNameCtrl,
                            hint: 'first_name'.tr,
                            isDark: isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildTextField(
                            context: context,
                            controller: c.lastNameCtrl,
                            hint: 'last_name'.tr,
                            isDark: isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: c.emailCtrl,
                  hint: 'enter_email'.tr,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: c.passwordCtrl,
                  hint: 'enter_password'.tr,
                  icon: c.isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  isPassword: true,
                  isPasswordVisible: c.isPasswordVisible,
                  onIconPressed: c.togglePassword,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: c.confirmPasswordCtrl,
                  hint: 'confirm_password'.tr,
                  icon: c.isConfirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  isPassword: true,
                  isPasswordVisible: c.isConfirmPasswordVisible,
                  onIconPressed: c.toggleConfirmPassword,
                  isDark: isDark,
                ),
                const SizedBox(height: 32),
                _primaryButton(
                  isDark: isDark,
                  isLoading: c.isLoading,
                  label: 'continue_btn'.tr,
                  onPressed: c.submitRegistration,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('already_have_account'.tr,
                          style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey)),
                      GestureDetector(
                        onTap: Get.back,
                        child: Text('sign_in'.tr,
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
    );
  }

  // =========================================================
  // STEP 2 — Code verification
  // =========================================================

  Widget _step2(BuildContext context, TaSignUpController c, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _curvedHeader(context, isDark, showBack: false),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('enter_your_code'.tr,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 10),
                // ── Info banner ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A2A4A)
                        : const Color(0xFFEEF3FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF003366).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: isDark
                              ? const Color(0xFF3E82F7)
                              : const Color(0xFF003366),
                          size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('code_info'.tr,
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontSize: 13,
                                height: 1.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildTextField(
                  context: context,
                  controller: c.codeCtrl,
                  hint: 'enter_activation_code'.tr,
                  icon: Icons.vpn_key_outlined,
                  isDark: isDark,
                ),
                const SizedBox(height: 32),
                _primaryButton(
                  isDark: isDark,
                  isLoading: c.isLoading,
                  label: 'verify_activate'.tr,
                  onPressed: c.verifyCode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SHARED HELPERS
  // =========================================================

  /// Curved blue header with optional back arrow
  Widget _curvedHeader(BuildContext context, bool isDark,
      {required bool showBack}) {
    return Stack(
      children: [
        ClipPath(
          clipper: SimpleCurveClipper(),
          child: Container(
            height: 140,
            width: double.infinity,
            color:
                isDark ? const Color(0xFF1A1A2E) : const Color(0xFF003366),
          ),
        ),
        SizedBox(
          height: 100,
          width: double.infinity,
          child: SafeArea(
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20))
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: Image.asset('assets/logo.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 40)),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _primaryButton({
    required bool isDark,
    required bool isLoading,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0xFF1A1A2E) : const Color(0xFF003366),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    IconData? icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onIconPressed,
    TextInputType? keyboardType,
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
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            letterSpacing: 1.2),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
              letterSpacing: 0),
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

class SimpleCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
