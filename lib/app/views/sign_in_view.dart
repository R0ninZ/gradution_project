import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/sign_in_controller.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 320.0;

    return GetBuilder<SignInController>(
      init: SignInController(),
      global: false,
      builder: (c) {
        return Scaffold(
          backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Stack(
                  children: [
                    Hero(
                      tag: 'blue_background',
                      child: ClipPath(
                        clipper: SubtleCurveClipper(),
                        child: Container(
                          height: headerHeight,
                          width: double.infinity,
                          color: const Color(0xFF003366),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: headerHeight - 40,
                      width: double.infinity,
                      child: Center(
                        child: Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'assets/logo.png',
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 258,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Form ─────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('sign_in'.tr,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: c.emailOrIdController,
                        hint: 'enter_email'.tr,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: c.passwordController,
                        hint: 'enter_password'.tr,
                        icon: c.isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        obscureText: !c.isPasswordVisible,
                        onIconPressed: c.togglePasswordVisibility,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: c.goToForgotPassword,
                          child: Text('forgot_password'.tr,
                              style: const TextStyle(
                                  color: Color(0xFF3F51B5), fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: c.isLoading ? null : c.signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: c.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : Text('sign_in'.tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Don't have an account? Sign up
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'dont_have_account'.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const TextSpan(text: ' '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: c.goToSignUp,
                                  child: Text('sign_up'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF3F51B5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: Colors.grey[300], thickness: 1)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or'.tr,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 13)),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.grey[300], thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Are you a teaching assistant? Click here
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'are_you_ta'.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const TextSpan(text: ' '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: c.goToTaLogin,
                                  child: Text('click_here'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF003366),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onIconPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xFF2A2A3E) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          suffixIcon: IconButton(
              icon: Icon(icon, color: Colors.grey[400]),
              onPressed: onIconPressed),
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
