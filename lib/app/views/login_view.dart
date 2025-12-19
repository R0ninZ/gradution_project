// lib/app/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../widgets/custom_wave_clipper.dart';

// 1. Extend GetView<LoginController>
// This gives you access to 'controller' automatically without calling Get.put
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // REMOVE THIS LINE: final controller = Get.put(LoginController()); 
    // You can now just use 'controller' directly.
    
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // ... rest of your code stays exactly the same ...
      backgroundColor: Colors.white,
      body: Obx(
        () => Stack(
          children: [
            // -----------------------------------------------------------
            // LAYER 1: The Login Form (Bottom Layer)
            // -----------------------------------------------------------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              // If splash, push it down off-screen. If login, bring it up.
              top: controller.isSplashMode.value ? screenHeight : 320,
              left: 20,
              right: 20,
              bottom: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: controller.showLoginInputs.value ? 1.0 : 0.0,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello!",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF003B73)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Security log in with your email and password.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      
                      // Email Input
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter your email or ID",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Password Input
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003B73),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Sign in", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------
            // LAYER 2: The Blue Background (Top Layer - Morphs)
            // -----------------------------------------------------------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: 0,
              left: 0,
              right: 0,
              // The Magic: Full screen height vs Header height
              height: controller.isSplashMode.value ? screenHeight : 300,
              child: ClipPath(
                clipper: CustomWaveClipper(),
                child: Container(
                  color: const Color(0xFF003B73), // Your Brand Blue
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      // Move logo up slightly when becoming a header
                      margin: EdgeInsets.only(bottom: controller.isSplashMode.value ? 0 : 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // REPLACE WITH YOUR LOGO ASSET
                           const Icon(Icons.school, size: 80, color: Colors.white), 
                          // Image.asset('assets/images/logo.png', width: 100),
                          
                          const SizedBox(height: 10),
                          const Text(
                            "BNU connect",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            "Benha National University",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}