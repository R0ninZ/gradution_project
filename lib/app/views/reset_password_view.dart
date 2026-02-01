import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/reset_password_controller.dart';


class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GetBuilder<ResetPasswordController>(
            builder: (c) => Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  'BNU CONNECT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00A7E1),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 60),

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A7E1),
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 45,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Reset password',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                _buildPasswordField(
                  controller: c.newPasswordController,
                  hint: 'New Password',
                  isVisible: c.isNewPasswordVisible,
                  onToggle: c.toggleNewPasswordVisibility,
                ),

                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: c.confirmPasswordController,
                  hint: 'Confirm New Password',
                  isVisible: c.isConfirmPasswordVisible,
                  onToggle: c.toggleConfirmPasswordVisibility,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequirement(
                          'At least 8 characters', c.hasMinLength),
                      const SizedBox(height: 8),
                      _buildRequirement(
                          'One uppercase letter', c.hasUpperCase),
                      const SizedBox(height: 8),
                      _buildRequirement(
                          'One lowercase letter', c.hasLowerCase),
                      const SizedBox(height: 8),
                      _buildRequirement('One number', c.hasDigit),
                      const SizedBox(height: 8),
                      _buildRequirement(
                          'One special character (!@#\$%^&*)',
                          c.hasSpecialChar),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (c.isPasswordValid && !c.isLoading) ? c.submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: c.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: TextStyle(
                              color: c.isPasswordValid
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F4F7),
                      side: BorderSide.none,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: isMet ? Colors.green : Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isMet ? Colors.green : Colors.grey[600],
            fontWeight:
                isMet ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
