import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gradution_project/app/routes/screens/login.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // controllers
  late final AnimationController _blobController;
  late final Animation<double> _blobScale;

  late final AnimationController _logoController;
  late final Animation<Offset> _logoOffset;
  late final Animation<double> _logoScale;

  late final AnimationController _welcomeController;
  late final Animation<double> _welcomeOpacity;
  late final Animation<Offset> _welcomeOffset;

  bool _showFinal = false;

  // tweak these to match the video timing or touchscreen feel
  static const int delayBeforeStartMs = 450;
  static const int blobDurationMs = 900;
  static const int logoDurationMs = 600;
  static const int welcomeDurationMs = 450;
  static const int holdBeforeNavMs = 3000;

  // final placement fractions (tweak to match exact layout)
  static const double logoTopFraction = 0.12;    // 12% from top
  static const double welcomeTopFraction = 0.62; // 62% from top

  @override
  void initState() {
    super.initState();

    // Blob controller uses a small overshoot sequence for that soft bounce seen in the video
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: blobDurationMs),
    );

    // TweenSequence: grow past target then settle back (gives overshoot bounce)
    _blobScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.45, end: 3.75).chain(CurveTween(curve: Curves.easeOut)), weight: 75),
      TweenSequenceItem(tween: Tween(begin: 3.75, end: 3.5).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_blobController);

    // Logo slides up and slightly bounces (scale)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: logoDurationMs),
    );
    _logoOffset = Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    // small scale bounce for logo arrival
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.08).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 40),
    ]).animate(_logoController);

    // Welcome: fade in + tiny slide up
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: welcomeDurationMs),
    );
    _welcomeOpacity = CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn);
    _welcomeOffset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _welcomeController, curve: Curves.easeOut));

    // start after small delay so user perceives initial blob
    Timer(Duration(milliseconds: delayBeforeStartMs), () => _blobController.forward());

    // when blob finished, reveal final layer and start logo + welcome animations
    _blobController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showFinal = true);

        // start logo animation, then welcome shortly after for a neat stagger
        _logoController.forward();
        Timer(const Duration(milliseconds: 120), () => _welcomeController.forward());

        // then navigate to login after hold
        Timer(Duration(milliseconds: holdBeforeNavMs + welcomeDurationMs), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _blobController.dispose();
    _logoController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final baseBlobSize = size.width * 0.70;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // pattern background. If you don't have it, replace with Container(color: Colors.white)
          Image.asset('assets/pattern.png', fit: BoxFit.cover),

          // Animated blob centered while expanding
          Center(
            child: AnimatedBuilder(
              animation: _blobScale,
              builder: (context, child) {
                final current = baseBlobSize * _blobScale.value;
                return SizedBox(
                  width: current,
                  height: current,
                  child: ClipPath(
                    clipper: _BlobClipper(),
                    child: Container(color: const Color(0xFF063C63), child: child),
                  ),
                );
              },
              // initial content inside the blob while it scales
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 120, height: 120, child: Image.asset('assets/logo.png', fit: BoxFit.contain)),
                  const SizedBox(height: 8),
                  const Text(
                    'BNUconnect',
                    style: TextStyle(color: Color(0xFF8FD2E2), fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // final full-screen layer (shows after blob animation). We position items explicitly to match video.
          IgnorePointer(
            ignoring: !_showFinal,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 320),
              opacity: _showFinal ? 1 : 0,
              child: Container(
                color: const Color(0xFF063C63),
                child: Stack(
                  children: [
                    // logo region positioned near top
                    Positioned(
                      top: size.height * logoTopFraction,
                      left: 0,
                      right: 0,
                      child: SlideTransition(
                        position: _logoOffset,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 140, height: 140, child: Image.asset('assets/logo.png', fit: BoxFit.contain)),
                              const SizedBox(height: 6),
                              const Text('Benha National University', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // big Welcome positioned lower
                    Positioned(
                      top: size.height * welcomeTopFraction,
                      left: 0,
                      right: 0,
                      child: SlideTransition(
                        position: _welcomeOffset,
                        child: FadeTransition(
                          opacity: _welcomeOpacity,
                          child: const Center(
                            child: Text('Welcome', style: TextStyle(color: Colors.white70, fontSize: 40, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// same blob clipper as before (adjust control points if you need exact shape)
class _BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final Path path = Path();
    path.moveTo(0.05 * w, 0.35 * h);
    path.cubicTo(0.0 * w, 0.0 * h, 0.15 * w, 0.0 * h, 0.32 * w, 0.06 * h);
    path.cubicTo(0.55 * w, 0.16 * h, 0.8 * w, 0.08 * h, 0.95 * w, 0.25 * h);
    path.cubicTo(1.02 * w, 0.35 * h, 0.98 * w, 0.55 * h, 0.86 * w, 0.69 * h);
    path.cubicTo(0.76 * w, 0.82 * h, 0.58 * w, 0.9 * h, 0.38 * w, 0.88 * h);
    path.cubicTo(0.20 * w, 0.86 * h, 0.12 * w, 0.64 * h, 0.05 * w, 0.52 * h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
