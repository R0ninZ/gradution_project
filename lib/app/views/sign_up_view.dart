import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/sign_up_controller.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(
      init: SignUpController(),
      global: false,
      builder: (c) => Scaffold(
        backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: SimpleCurveClipper(),
                    child: Container(
                        height: 140, width: double.infinity, color: const Color(0xFF003366)),
                  ),
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: SafeArea(
                      child: Center(
                        child: Image.asset('assets/images/logo.png',
                            width: 80,
                            height: 80,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 40)),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('sign_up'.tr,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                controller: c.firstNameController,
                                hint: 'first_name'.tr)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextField(
                                controller: c.lastNameController,
                                hint: 'last_name'.tr)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: c.idController,
                      hint: 'enter_id'.tr,
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: c.emailController,
                      hint: 'enter_email'.tr,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            hint: 'year'.tr,
                            value: c.selectedAcademicYear,
                            items: c.academicYears,
                            onChanged: c.setAcademicYear,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            hint: 'specification'.tr,
                            value: c.selectedSpecification,
                            items: c.specifications,
                            onChanged: c.setSpecification,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: c.passwordController,
                      hint: 'enter_password'.tr,
                      icon: c.isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      isPassword: true,
                      isPasswordVisible: c.isPasswordVisible,
                      onIconPressed: c.togglePasswordVisibility,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: c.confirmPasswordController,
                      hint: 'confirm_password'.tr,
                      icon: c.isConfirmPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      isPassword: true,
                      isPasswordVisible: c.isConfirmPasswordVisible,
                      onIconPressed: c.toggleConfirmPasswordVisibility,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: c.isLoading ? null : c.signUp,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366)),
                        child: c.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('sign_up'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('already_have_account'.tr,
                              style: const TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Text('sign_in'.tr,
                                style: const TextStyle(
                                    color: Color(0xFF3F51B5),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onIconPressed,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xFF2A2A3E) : const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: icon != null
              ? IconButton(
                  icon: Icon(icon, color: Colors.grey), onPressed: onIconPressed)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xFF2A2A3E) : const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
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
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
