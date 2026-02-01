import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/sign_in_controller.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 320.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
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

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign in',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    controller: controller.emailOrIdController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: controller.passwordController,
                    hint: 'Enter your password',
                    icon: controller.isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    obscureText: !controller.isPasswordVisible,
                    onIconPressed: controller.togglePasswordVisibility,
                  ),

                  TextButton(
                    onPressed: controller.goToForgotPassword,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Color(0xFF3F51B5),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading ? null : controller.signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                      ),
                      child: controller.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: controller.goToSignUp,
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Color(0xFF3F51B5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(icon, color: Colors.grey),
            onPressed: onIconPressed,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

// ---- Clipper ----

class SubtleCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
