import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

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

    Timer(const Duration(milliseconds: 2500), () {
      Get.offNamed('/login'); // ✅ SAFE
    });
  }

  @override
  void onClose() {
    fadeController.dispose();
    super.onClose();
  }
}
