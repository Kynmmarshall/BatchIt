// ============================================================================
// Tests for Batch model
// ============================================================================
import 'package:batchit/models/batch.dart';
import 'package:flutter_test/flutter_test.dart';

Batch makeBatch({
  String id = 'b1',
  String productName = 'Rice',
  double bulkSizeKg = 100,
  double currentQuantityKg = 50,
  String status = 'open',
  String? imageUrl,
  String? providerId,
}) =>
    Batch(
      id: id,
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      currentQuantityKg: currentQuantityKg,
      locationName: 'Mokolo',
      hubName: 'Hub A',
      status: status,
      imageUrl: imageUrl,
      providerId: providerId,
    );

void main() {
  group('Batch.progress', () {
    test('returns 0.5 when half full', () {
      final b = makeBatch(bulkSizeKg: 100, currentQuantityKg: 50);
      expect(b.progress, 0.5);
    });

    test('returns 0 when bulkSizeKg is 0', () {
      final b = makeBatch(bulkSizeKg: 0, currentQuantityKg: 0);
      expect(b.progress, 0.0);
    });

    test('clamps to 1.0 when overfilled', () {
      final b = makeBatch(bulkSizeKg: 50, currentQuantityKg: 200);
      expect(b.progress, 1.0);
    });

    test('returns 0.0 when empty', () {
      final b = makeBatch(bulkSizeKg: 100, currentQuantityKg: 0);
      expect(b.progress, 0.0);
    });

    test('returns 1.0 when exactly full', () {
      final b = makeBatch(bulkSizeKg: 100, currentQuantityKg: 100);
      expect(b.progress, 1.0);
    });
  });

  group('Batch.isFull', () {
    test('true when currentQuantityKg >= bulkSizeKg', () {
      expect(makeBatch(bulkSizeKg: 100, currentQuantityKg: 100).isFull, true);
      expect(makeBatch(bulkSizeKg: 100, currentQuantityKg: 120).isFull, true);
    });

    test('false when below capacity', () {
      expect(makeBatch(bulkSizeKg: 100, currentQuantityKg: 99).isFull, false);
    });
  });

  group('Batch.isOpen', () {
    test('true when status is open', () {
      expect(makeBatch(status: 'open').isOpen, true);
    });

    test('false for other statuses', () {
      expect(makeBatch(status: 'filled').isOpen, false);
      expect(makeBatch(status: 'closed').isOpen, false);
      expect(makeBatch(status: '').isOpen, false);
    });
  });

  group('Batch.canJoin', () {
    test('true when open and not full', () {
      final b = makeBatch(status: 'open', bulkSizeKg: 100, currentQuantityKg: 50);
      expect(b.canJoin, true);
    });

    test('false when full even if open', () {
      final b = makeBatch(status: 'open', bulkSizeKg: 100, currentQuantityKg: 100);
      expect(b.canJoin, false);
    });

    test('false when not open even if not full', () {
      final b = makeBatch(status: 'filled', bulkSizeKg: 100, currentQuantityKg: 50);
      expect(b.canJoin, false);
    });

    test('false when both closed and full', () {
      final b = makeBatch(status: 'closed', bulkSizeKg: 100, currentQuantityKg: 100);
      expect(b.canJoin, false);
    });
  });

  group('Batch.imageAssetPath', () {
    test('converts product name to asset path', () {
      final b = makeBatch(productName: 'Rice');
      expect(b.imageAssetPath, 'assets/batches/rice.jpg');
    });

    test('replaces spaces with underscores', () {
      final b = makeBatch(productName: 'Palm Oil');
      expect(b.imageAssetPath, 'assets/batches/palm_oil.jpg');
    });

    test('strips special characters', () {
      final b = makeBatch(productName: 'Bread & Butter');
      expect(b.imageAssetPath, 'assets/batches/bread_butter.jpg');
    });

    test('handles already lowercase name', () {
      final b = makeBatch(productName: 'sugar');
      expect(b.imageAssetPath, 'assets/batches/sugar.jpg');
    });
  });

  group('Batch constructor defaults', () {
    test('default unit is kg', () {
      expect(makeBatch().unit, 'kg');
    });

    test('default status is open', () {
      final b = Batch(
        id: 'x',
        productName: 'Corn',
        bulkSizeKg: 50,
        currentQuantityKg: 0,
        locationName: 'L',
        hubName: 'H',
      );
      expect(b.status, 'open');
    });

    test('imageUrl can be null', () {
      expect(makeBatch(imageUrl: null).imageUrl, isNull);
    });
  });
}
