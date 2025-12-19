import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_wave_clipper.dart';
import '../widgets/custom_input.dart';

class StudentLoginView extends GetView<AuthController> {
  const StudentLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // We get the exact screen height to calculate animations
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define the branded colors
    final bnuBlue = const Color(0xFF003B73); // Darker BNU Navy
    final textDark = const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: Colors.white,
      // SingleChildScrollView WRAPS the Stack to prevent overflow when keyboard opens
      body: SingleChildScrollView(
        // Allow the splash to take full height initially
        child: SizedBox(
          height: screenHeight, // Force full height so the background looks right
          child: Obx(() => Stack(
            children: [
              
              // ------------------------------------------------
              // LAYER 1: THE FORM (Content)
              // ------------------------------------------------
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
                // When Splash: Push down off screen
                // When Login: Sit below the header (approx 280px down)
                top: controller.isSplashMode.value ? screenHeight : 280,
                left: 0,
                right: 0,
                bottom: 0, // Stretch to bottom
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: controller.showLoginInputs.value ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          // --- "Hello!" Section ---
                        Text("Hello!", style: TextStyle(
                          fontSize: 34, // Bigger font
                          fontWeight: FontWeight.w800, 
                          color: bnuBlue, // Navy color
                        )),
                        const SizedBox(height: 8),
                        const Text("Securely log in with your email and password.", style: TextStyle(
                          fontSize: 15, 
                          color: Colors.black54, // Softer grey
                          height: 1.4,
                        )),
                        
                        const SizedBox(height: 40),

                        // --- "Sign in" Header ---
                        Text("Sign in", style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.w700, 
                          color: textDark
                        )),
                        const SizedBox(height: 20),

                        // --- INPUTS (Icons on Right) ---
                        CustomInput(
                          hint: "Enter your email or ID", 
                          suffixIcon: Icons.mail_outline_rounded, // Right Side
                          controller: controller.loginEmail
                        ),
                        CustomInput(
                          hint: "Enter your password", 
                          suffixIcon: Icons.visibility_outlined, // Right Side
                          isPassword: true, 
                          controller: controller.loginPassword
                        ),

                        // --- SIGN IN BUTTON ---
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity, 
                          height: 56, // Taller button
                          child: ElevatedButton(
                            onPressed: () { /* login logic */ },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bnuBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Sign in", style: TextStyle(
                              color: Colors.white, 
                              fontSize: 17, 
                              fontWeight: FontWeight.bold
                            )),
                          )
                        ),
                        
                        // --- FORGOT PASSWORD ---
                        Align(
                          alignment: Alignment.centerRight, 
                          child: TextButton(
                            onPressed: (){}, 
                            child: const Text("Forgot password?", style: TextStyle(
                              color: Color(0xFF4F46E5), // Purple-ish blue link
                              fontWeight: FontWeight.w600
                            ))
                          )
                        ),

                        const Spacer(), // Pushes bottom links down

                        // --- BOTTOM LINKS ---
                        Center(
                          child: Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                                GestureDetector(
                                  onTap: () => Get.toNamed('/register'),
                                  child: Text("Sign up", style: TextStyle(
                                    color: bnuBlue, fontWeight: FontWeight.bold, fontSize: 15
                                  )),
                                ),
                              ]),
                              const SizedBox(height: 10),
                              const Text("Or", style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => Get.toNamed('/instructor-login'),
                                child: RichText(text: TextSpan(
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  children: [
                                    const TextSpan(text: "Are you teaching assistant? "),
                                    TextSpan(text: "Click here", style: TextStyle(
                                      color: bnuBlue, fontWeight: FontWeight.bold
                                    )),
                                  ]
                                )),
                              ),
                              const SizedBox(height: 30), // Bottom safe area
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // LAYER 2: BLUE HEADER (Splash -> Header)
              // ------------------------------------------------
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutCubic,
                top: 0, left: 0, right: 0,
                // Splash = Full Height. Login = 260px (Slightly shorter to match design)
                height: controller.isSplashMode.value ? screenHeight : 260, 
                child: ClipPath(
                  clipper: CustomWaveClipper(),
                  child: Container(
                    color: bnuBlue,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        // Move logo up significantly in Login mode
                        padding: EdgeInsets.only(
                          bottom: controller.isSplashMode.value ? 0 : 60
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Flexible(child: Image.asset(
                              'assets/logo.png', // Ensure this file exists in your folder!
                              width: 160, // Adjusted size for better visibility
                              height: 140,
                            ),),
                            
                            
                            const SizedBox(height: 15),
                            
                            // "BNU connect" Text
                            const Text("BNU connect", style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.w700, 
                              color: Colors.white,
                              letterSpacing: 0.5
                            )),
                            
                            // "Welcome" text (Fades out when Login starts)
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: controller.isSplashMode.value ? 1.0 : 0.0,
                              child: const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text("Benha National University", style: TextStyle(
                                  fontSize: 16, color: Colors.white70
                                )),
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
          )),
        ),
      ),
    );
  }
}