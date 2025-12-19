import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_wave_clipper.dart';
import '../widgets/custom_input.dart';
import '../controllers/auth_controller.dart';

class InstructorLoginView extends GetView<AuthController> {
  const InstructorLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final bnuBlue = const Color(0xFF003B73);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight, 
          child: Stack(
            children: [
              // 1. Static Header
              Positioned(top: 0, left: 0, right: 0, height: 280,
                child: ClipPath(clipper: CustomWaveClipper(),
                  child: Container(color: bnuBlue,
                    child: Center(child: Padding(padding: const EdgeInsets.only(bottom: 40),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                           Flexible(child: Image.asset(
                              'assets/logo.png', // Ensure this file exists in your folder!
                              width: 160, // Adjusted size for better visibility
                              height: 140,
                            ),),
                           const SizedBox(height: 10),
                           const Text("BNU connect", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Instructor Form
              Positioned.fill(
                top: 260, // Sits right under the wave
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: bnuBlue)),
                      const SizedBox(height: 30),
                      const Text("Sign in", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 20),

                      // Secret Code (Key Icon on LEFT)
                      CustomInput(
                        hint: "Enter your secret code", 
                        prefixIcon: Icons.vpn_key_outlined, 
                        controller: controller.instructorCode
                      ),
                      
                      // Password (Lock on Left, Eye on Right automatically handled by CustomInput)
                      CustomInput(
                        hint: "Enter your password", 
                        prefixIcon: Icons.lock_outline, 
                        isPassword: true, 
                        controller: controller.instructorPassword
                      ),

                      const SizedBox(height: 30),
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bnuBlue, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                          child: const Text("Sign in", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      )),

                      const Spacer(),
                      Center(child: TextButton(
                        onPressed: () => Get.back(), // Go back to student login
                        child: const Text("Back to Student Login", style: TextStyle(color: Colors.grey))
                      )),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}