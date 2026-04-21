import 'package:flutter/animation.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);

  static const Curve emphasized = Curves.easeOutCubic;

  static Duration stagger(int index) {
    final clamped = index < 0 ? 0 : index;
    return Duration(milliseconds: 60 * clamped);
  }
}
