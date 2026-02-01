import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background icons
          const AnimatedIconsBackground(),

          // Blue curved background / vector
          Center(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 1.15,
                child: Image.asset(
                  'assets/Vector.png',
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width * 0.9,
                      MediaQuery.of(context).size.width * 0.9,
                    ),
                    painter: CurvedBackgroundPainter(),
                  ),
                ),
              ),
            ),
          ),

          // Logo (fade in only)
          Center(
            child: FadeTransition(
              opacity: controller.fadeAnimation,
              child: Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/logo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'BNUconnect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ==================== CURVED BACKGROUND PAINTER ====================
//

class CurvedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF003366)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.25,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      0,
      size.height * 0.75,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//
// ==================== ANIMATED ICONS BACKGROUND ====================
//

class AnimatedIconsBackground extends StatefulWidget {
  const AnimatedIconsBackground({super.key});

  @override
  State<AnimatedIconsBackground> createState() =>
      _AnimatedIconsBackgroundState();
}

class _AnimatedIconsBackgroundState extends State<AnimatedIconsBackground>
    with TickerProviderStateMixin {
  late List<AnimatedIconData> icons;

  @override
  void initState() {
    super.initState();
    icons = _generateIcons();
  }

  List<AnimatedIconData> _generateIcons() {
    final random = Random();
    final iconData = [
      Icons.school_outlined,
      Icons.science_outlined,
      Icons.computer_outlined,
      Icons.calculate_outlined,
      Icons.business_outlined,
      Icons.menu_book_outlined,
      Icons.architecture_outlined,
      Icons.medical_services_outlined,
      Icons.biotech_outlined,
      Icons.psychology_outlined,
    ];

    return List.generate(30, (_) {
      return AnimatedIconData(
        icon: iconData[random.nextInt(iconData.length)],
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        speed: 0.3 + random.nextDouble() * 0.5,
        delay: random.nextDouble() * 2,
        vsync: this,
      );
    });
  }

  @override
  void dispose() {
    for (var icon in icons) {
      icon.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: icons.map((animatedIcon) {
        return AnimatedBuilder(
          animation: animatedIcon.controller,
          builder: (context, child) {
            final size = MediaQuery.of(context).size;

            double y = animatedIcon.startY * size.height +
                (animatedIcon.controller.value * size.height * 0.3);

            if (y > size.height) {
              y = y % size.height;
            }

            return Positioned(
              left: animatedIcon.startX * size.width,
              top: y,
              child: Opacity(
                opacity: 0.3,
                child: Icon(
                  animatedIcon.icon,
                  size: 40,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class AnimatedIconData {
  final IconData icon;
  final double startX;
  final double startY;
  final double speed;
  final double delay;
  late AnimationController controller;

  AnimatedIconData({
    required this.icon,
    required this.startX,
    required this.startY,
    required this.speed,
    required this.delay,
    required TickerProvider vsync,
  }) {
    controller = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: (5000 / speed).round()),
    );

    Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
      controller.repeat();
    });
  }

  void dispose() => controller.dispose();
}
