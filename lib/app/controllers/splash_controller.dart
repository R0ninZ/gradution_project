import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeInOut,
    );

    fadeController.forward();

    // Wait for splash animation, then check session
    Timer(const Duration(milliseconds: 2500), () async {
      await _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    final session = _supabase.auth.currentSession;

    // No saved session → go to login
    if (session == null) {
      Get.offNamed('/login');
      return;
    }

    final userId = session.user.id;

    try {
      // 1️⃣ Check if this user is a Teaching Assistant
      final ta = await _supabase
          .from('teaching_assistants')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (ta != null) {
        Get.offAllNamed('/ta-home');
        return;
      }

      // 2️⃣ Check if this user is a Student (regular or admin)
      final student = await _supabase
          .from('students')
          .select('is_admin')
          .eq('id', userId)
          .maybeSingle();

      if (student != null) {
        final isAdmin = student['is_admin'] == true;
        Get.offAllNamed(isAdmin ? '/admin-home' : '/home');
        return;
      }

      // 3️⃣ Unknown user — clear session and go to login
      await _supabase.auth.signOut();
      Get.offNamed('/login');
    } catch (_) {
      // Network or DB error — fall back to login safely
      Get.offNamed('/login');
    }
  }

  @override
  void onClose() {
    fadeController.dispose();
    super.onClose();
  }
}