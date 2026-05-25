// ============================================================================
// Tests for core/formatters.dart
// ============================================================================
import 'package:batchit/core/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatQty', () {
    test('formats whole-number value without decimal', () {
      expect(formatQty(50, 'kg'), '50 kg');
    });

    test('formats decimal value with one decimal place', () {
      expect(formatQty(25.5, 'kg'), '25.5 kg');
    });

    test('appends the supplied unit', () {
      expect(formatQty(1, 'L'), '1 L');
      expect(formatQty(500, 'mL'), '500 mL');
      expect(formatQty(3, 'units'), '3 units');
      expect(formatQty(2, 'boxes'), '2 boxes');
    });

    test('formats zero as "0 <unit>"', () {
      expect(formatQty(0, 'kg'), '0 kg');
    });

    test('formats large whole number without decimal', () {
      expect(formatQty(1000, 'g'), '1000 g');
    });

    test('formats value that has many decimal places to 1 d.p.', () {
      // 10.123 is not a whole number, so one decimal place expected
      expect(formatQty(10.123, 'kg'), '10.1 kg');
    });

    test('formats exact .0 double as integer', () {
      // 25.0.roundToDouble() == 25.0, so treated as whole number
      expect(formatQty(25.0, 'kg'), '25 kg');
    });
  });

  group('formatKg', () {
    test('always appends kg', () {
      expect(formatKg(10), '10 kg');
      expect(formatKg(0.5), '0.5 kg');
    });

    test('is consistent with formatQty(value, "kg")', () {
      for (final v in [0.0, 1.0, 12.5, 100.0]) {
        expect(formatKg(v), formatQty(v, 'kg'));
      }
    });
  });
}
