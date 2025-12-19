import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_wave_clipper.dart';
import '../widgets/custom_input.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final bnuBlue = const Color(0xFF003B73);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Use a calculated height to ensure the white background fills the screen 
        // even on bounce/scroll, but allow scrolling for small screens.
        child: SizedBox(
          height: screenHeight > 900 ? screenHeight : null, 
          child: Stack(
            children: [
              
              // ------------------------------------------------
              // 1. HEADER (Static Wave)
              // ------------------------------------------------
              Positioned(
                top: 0, left: 0, right: 0, 
                height: 260, // Increased slightly to give the logo room
                child: ClipPath(
                  clipper: CustomWaveClipper(),
                  child: Container(
                    color: bnuBlue,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             // Fixed: Removed Flexible, used specific dimensions
                             Image.asset(
                               'assets/logo.png', // Make sure this path is correct!
                               width: 160, 
                               height: 140,
                             ), 
                             const SizedBox(height: 10),
                             const Text(
                               "BNU connect", 
                               style: TextStyle(
                                 color: Colors.white, 
                                 fontSize: 20, 
                                 fontWeight: FontWeight.bold
                               )
                             ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // 2. REGISTER FORM
              // ------------------------------------------------
              Container(
                // Fixed: Increased top margin so "Sign up" sits BELOW the wave
                margin: const EdgeInsets.only(top: 250), 
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign up", 
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.black87
                      )
                    ),
                    const SizedBox(height: 25),
                    
                    // First Name & Last Name Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            hint: "First Name", 
                            prefixIcon: Icons.person_outline, 
                            controller: controller.regFirstName
                          )
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: CustomInput(
                            hint: "Last Name", 
                            prefixIcon: Icons.person_outline, 
                            controller: controller.regLastName
                          )
                        ),
                      ],
                    ),

                    CustomInput(
                      hint: "Enter your ID", 
                      prefixIcon: Icons.badge_outlined, 
                      controller: controller.regId
                    ),
                    CustomInput(
                      hint: "Enter your email", 
                      prefixIcon: Icons.mail_outline, 
                      controller: controller.regEmail
                    ),
                    
                    // Dropdowns
                    CustomInput(
                      hint: "Academic Year", 
                      prefixIcon: Icons.calendar_today_outlined, 
                      isDropdown: true
                    ),
                    CustomInput(
                      hint: "Specification", 
                      prefixIcon: Icons.school_outlined, 
                      isDropdown: true
                    ),

                    CustomInput(
                      hint: "Enter your password", 
                      prefixIcon: Icons.lock_outline, 
                      isPassword: true, 
                      controller: controller.regPassword
                    ),
                    CustomInput(
                      hint: "Confirm your password", 
                      prefixIcon: Icons.lock_outline, 
                      isPassword: true, 
                      controller: controller.regConfirmPassword
                    ),

                    const SizedBox(height: 30),
                    
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity, 
                      height: 55, 
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bnuBlue, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Sign up", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      )
                    ),

                    const SizedBox(height: 25),
                    
                    // Bottom Link
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.back(), 
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              const TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Sign in", 
                                style: TextStyle(
                                  color: bnuBlue, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ]
                          )
                        ),
                      )
                    ),
                    const SizedBox(height: 50), // Bottom padding for scrolling
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}