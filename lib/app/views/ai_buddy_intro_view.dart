import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIBuddyIntroView extends StatefulWidget {
  const AIBuddyIntroView({super.key});

  @override
  State<AIBuddyIntroView> createState() => _AIBuddyIntroViewState();
}

class _AIBuddyIntroViewState extends State<AIBuddyIntroView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  // Pass through whatever returnRoute was given to this screen
  late final String _returnRoute;

  @override
  void initState() {
    super.initState();

    _returnRoute =
        (Get.arguments as Map<String, dynamic>?)?['returnRoute'] ?? '/home';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    // After 2 seconds navigate to chat, passing the returnRoute along
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offNamed('/ai-buddy', arguments: {'returnRoute': _returnRoute});
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              Color(0xFF1A2F5E),
              Color(0xFF0A1628),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: AnimatedBuilder(
              animation: _slideUp,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: child,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    'meet_the'.tr,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF5B9EF5), Color(0xFF99C5FF)],
                    ).createShader(bounds),
                    child: const Text(
                      'Echo Mind!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/Robot banner.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  _LoadingDots(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = value < 0.5 ? value * 2 : (1.0 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2 + (opacity * 0.8)),
              ),
            );
          }),
        );
      },
    );
  }
}
