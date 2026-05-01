import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x5A000000),
          blurRadius: 22,
          offset: Offset(0, 12),
        ),
      ];
    }

    return const [
      BoxShadow(
        color: Color(0x140B402A),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x0C0B402A),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> hero(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x66071C15),
          blurRadius: 28,
          offset: Offset(0, 14),
        ),
      ];
    }

    return const [
      BoxShadow(
        color: Color(0x332A9E79),
        blurRadius: 28,
        offset: Offset(0, 16),
      ),
    ];
  }
}
