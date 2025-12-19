import 'package:flutter/material.dart';

class CustomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    
    // 1. Start at the bottom-left corner
    //    This sets the "deepest" part of the blue header on the left side.
    path.lineTo(0, size.height);

    // 2. The Curve (Swoop Up)
    //    We use a single quadratic bezier curve.
    //    - Start: (0, height) -> Bottom Left
    //    - Control Point: (width * 0.6, height) -> Keeps the line flat/low for the first half
    //    - End Point: (width, height - 80) -> Curves up to the right side
    
    var controlPoint = Offset(size.width * 0.6, size.height);
    var endPoint = Offset(size.width, size.height - 80);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy,
        endPoint.dx, endPoint.dy);

    // 3. Close the path (Top Right -> Top Left)
    path.lineTo(size.width, 0); 
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 