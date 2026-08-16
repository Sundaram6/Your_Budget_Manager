import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralized animation constants and helper extensions across the app.
class AppAnimation {
  // Standard Durations
  static const Duration durationMicro = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 450);
  static const Duration durationCinematic = Duration(milliseconds: 600);
  static const Duration durationStaggerStep = Duration(milliseconds: 35);

  // Standard Curves
  static const Curve curveStandard = Curves.easeOutCubic;
  static const Curve curveEntrance = Curves.easeOutQuad;
  static const Curve curveDecelerate = Curves.fastOutSlowIn;
  static const Curve curveSwiftOut = Curves.easeOutCubic;
  static const Curve curveSpringBounce = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Curve curveModalReveal = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Checks if user has requested reduced motion / disabled animations.
  static bool isReducedMotion(BuildContext context) {
    try {
      final mq = MediaQuery.maybeOf(context);
      if (mq == null) return false;
      return mq.disableAnimations || mq.accessibleNavigation;
    } catch (_) {
      return false;
    }
  }
}

/// Extension on Widget to easily apply standardized entrance animations
/// that strictly respect accessibility reduced-motion settings.
extension AppAnimationWidgetExtension on Widget {
  /// Applies a subtle fade + upward slide entrance animation.
  Widget animateEntrance(
    BuildContext context, {
    int index = 0,
    Duration? delay,
    Duration? duration,
    double slideOffsetY = 0.08,
  }) {
    if (AppAnimation.isReducedMotion(context)) {
      return this;
    }

    final calculatedDelay = delay ?? (AppAnimation.durationStaggerStep * index);
    final effectiveDuration = duration ?? AppAnimation.durationNormal;

    return animate(delay: calculatedDelay)
        .fade(
          duration: effectiveDuration,
          curve: AppAnimation.curveEntrance,
        )
        .slideY(
          begin: slideOffsetY,
          end: 0.0,
          duration: effectiveDuration,
          curve: AppAnimation.curveEntrance,
        );
  }
}

/// Extension on List<Widget> to stagger-animate children.
extension AppAnimationListExtension on List<Widget> {
  /// Applies staggered entrance animation to all widgets in the list.
  List<Widget> animateStaggered(
    BuildContext context, {
    Duration? startDelay,
    Duration? duration,
    Duration? interval,
    double slideOffsetY = 0.06,
  }) {
    if (AppAnimation.isReducedMotion(context)) {
      return this;
    }

    return animate(
      delay: startDelay ?? Duration.zero,
      interval: interval ?? AppAnimation.durationStaggerStep,
    )
        .fade(
          duration: duration ?? AppAnimation.durationNormal,
          curve: AppAnimation.curveEntrance,
        )
        .slideY(
          begin: slideOffsetY,
          end: 0.0,
          duration: duration ?? AppAnimation.durationNormal,
          curve: AppAnimation.curveEntrance,
        );
  }
}
