import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class SignUpController extends GetxController {
  // ================= TEXT CONTROLLERS =================
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ================= UI STATE =================
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

  final AuthService _auth = Get.find();

  // ================= UI HELPERS =================
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

  // ================= SIGN UP =================
  Future<void> signUp() async {
  if (isLoading) return;

  final academicYear = selectedAcademicYear;
  final track = selectedSpecification;

  if (firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      idController.text.isEmpty ||
      emailController.text.isEmpty ||
      passwordController.text.isEmpty ||
      confirmPasswordController.text.isEmpty ||
      academicYear == null ||
      track == null) {
    Get.snackbar('Error', 'Please fill all fields');
    return;
  }

  if (passwordController.text != confirmPasswordController.text) {
    Get.snackbar('Error', 'Passwords do not match');
    return;
  }

  try {
    isLoading = true;
    update();

    await _auth.signUpStudent(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      studentId: idController.text.trim(),
      universityYear: _mapAcademicYear(academicYear),
      track: track,
    );

    Get.snackbar('Success', 'Account created successfully');
    Get.offAllNamed('/login');
  } catch (e) {
    Get.snackbar('Sign up failed', e.toString());
  } finally {
    isLoading = false;
    update();
  }
}


  int _mapAcademicYear(String year) {
    switch (year) {
      case 'First Year':
        return 1;
      case 'Second Year':
        return 2;
      case 'Third Year':
        return 3;
      case 'Fourth Year':
        return 4;
      default:
        return 1;
    }
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
