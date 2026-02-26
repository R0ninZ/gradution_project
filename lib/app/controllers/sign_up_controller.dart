import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class SignUpController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  String? selectedAcademicYear;
  String? selectedSpecification;

  final List<String> academicYears = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
  ];
  final List<String> specifications = ['SAD', 'AIM', 'DAS'];

  late final AuthService _auth;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthService>();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    update();
  }

  void setAcademicYear(String? value) {
    selectedAcademicYear = value;
    update();
  }

  void setSpecification(String? value) {
    selectedSpecification = value;
    update();
  }

  // ── Validators ─────────────────────────────────────────────────────────────

  bool _isValidBnuEmail(String email) =>
      email.trim().toLowerCase().endsWith('@cs.bnu.edu.eg');

  bool _isValidName(String name) =>
      RegExp(r"^[a-zA-Z\u0600-\u06FF\s'-]{2,}$").hasMatch(name.trim());

  bool _isValidStudentId(String id) =>
      RegExp(r'^\d{8}$').hasMatch(id.trim());

  String? _validateAll() {
    final fn = firstNameController.text.trim();
    final ln = lastNameController.text.trim();
    final id = idController.text.trim();
    final em = emailController.text.trim();
    final pw = passwordController.text;
    final cf = confirmPasswordController.text;

    if (fn.isEmpty || ln.isEmpty || id.isEmpty || em.isEmpty ||
        pw.isEmpty || cf.isEmpty ||
        selectedAcademicYear == null || selectedSpecification == null) {
      return 'Please fill in all fields.';
    }
    if (!_isValidName(fn)) return 'First name must contain only letters (min. 2 characters).';
    if (!_isValidName(ln)) return 'Last name must contain only letters (min. 2 characters).';
    if (!_isValidStudentId(id)) return 'Student ID must be exactly 8 digits.';
    if (!_isValidBnuEmail(em)) {
      return 'Email must end with @cs.bnu.edu.eg\nExample: ahmed.ali@cs.bnu.edu.eg';
    }
    if (pw.length < 8) return 'Password must be at least 8 characters.';
    if (!pw.contains(RegExp(r'[A-Z]'))) return 'Password must contain at least one uppercase letter.';
    if (!pw.contains(RegExp(r'[a-z]'))) return 'Password must contain at least one lowercase letter.';
    if (!pw.contains(RegExp(r'[0-9]'))) return 'Password must contain at least one number.';
    if (!pw.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
    if (pw != cf) return 'Passwords do not match.';
    return null;
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────

  Future<void> signUp() async {
    if (isLoading) return;
    final error = _validateAll();
    if (error != null) { _snack('Invalid Input', error, isError: true); return; }

    try {
      isLoading = true;
      update();

      await _auth.signUpStudent(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        studentId: idController.text.trim(),
        universityYear: _mapAcademicYear(selectedAcademicYear!),
        track: selectedSpecification!,
      );

      _snack('Account Created! 🎉', 'Your account is ready. Please sign in.', isError: false);
      Get.offAllNamed('/login');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        _snack('Email Already Used', 'This email is already registered. Try signing in instead.', isError: true);
      } else if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else if (msg.contains('invalid email')) {
        _snack('Invalid Email', 'Please enter a valid university email address.', isError: true);
      } else {
        _snack('Sign Up Failed', 'Something went wrong. Please try again later.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  int _mapAcademicYear(String year) {
    switch (year) {
      case 'First Year': return 1;
      case 'Second Year': return 2;
      case 'Third Year': return 3;
      case 'Fourth Year': return 4;
      default: return 1;
    }
  }

  void _snack(String title, String message, {required bool isError}) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF4CAF50),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
