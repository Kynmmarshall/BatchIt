// ============================================================================
// Tests for AppMotion and AppShadows theme utilities
// ============================================================================
import 'package:batchit/themes/app_motion.dart';
import 'package:batchit/themes/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppMotion', () {
    test('stagger(0) returns zero duration', () {
      expect(AppMotion.stagger(0), Duration.zero);
    });

    test('stagger(positive) returns scaled duration', () {
      final d = AppMotion.stagger(3);
      expect(d.inMilliseconds, 180);
    });

    test('stagger(negative) is clamped to zero', () {
      expect(AppMotion.stagger(-5), Duration.zero);
    });
  });

  group('AppShadows.card', () {
    test('returns non-empty list for light brightness', () {
      final shadows = AppShadows.card(Brightness.light);
      expect(shadows, isNotEmpty);
    });

    test('returns non-empty list for dark brightness', () {
      final shadows = AppShadows.card(Brightness.dark);
      expect(shadows, isNotEmpty);
    });
  });

  group('AppShadows.hero', () {
    test('returns non-empty list for light brightness', () {
      final shadows = AppShadows.hero(Brightness.light);
      expect(shadows, isNotEmpty);
    });

    test('returns non-empty list for dark brightness', () {
      final shadows = AppShadows.hero(Brightness.dark);
      expect(shadows, isNotEmpty);
    });
  });
}
