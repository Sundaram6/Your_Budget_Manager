import 'package:flutter/animation.dart';

class AppAnimation {
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationCinematic = Duration(milliseconds: 600);

  static const Curve curveSwiftOut = Curves.easeOutCubic;
  static const Curve curveSpringBounce = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Curve curveModalReveal = Cubic(0.05, 0.7, 0.1, 1.0);
}
