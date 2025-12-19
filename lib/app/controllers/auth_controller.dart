import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  // --- SPLASH LOGIC ---
  var isSplashMode = true.obs;
  var showLoginInputs = false.obs;

  // --- INPUT CONTROLLERS ---
  final loginEmail = TextEditingController();
  final loginPassword = TextEditingController();
  final instructorCode = TextEditingController();
  final instructorPassword = TextEditingController();

  final regFirstName = TextEditingController();
  final regLastName = TextEditingController();
  final regId = TextEditingController();
  final regEmail = TextEditingController();
  final regPassword = TextEditingController();
  final regConfirmPassword = TextEditingController();

  @override
  void onReady() { // <--- CHANGED FROM onInit TO onReady
    super.onReady();
    // This ensures the animation only starts AFTER the screen is visible
    startSplashSequence();
  }

  void startSplashSequence() async {
    // 1. Show full blue screen for 3 seconds (Increased slightly)
    await Future.delayed(const Duration(seconds: 3));
    isSplashMode.value = false; // Shrink header
    
    // 2. Wait for shrink animation, then show inputs
    await Future.delayed(const Duration(milliseconds: 800));
    showLoginInputs.value = true;
  }
}