// ============================================================================
// Tests for UserSettings model
// ============================================================================
import 'package:batchit/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSettings defaults', () {
    test('language defaults to en', () {
      const s = UserSettings();
      expect(s.language, 'en');
    });

    test('theme defaults to system', () {
      const s = UserSettings();
      expect(s.theme, 'system');
    });

    test('all notification flags default to true', () {
      const s = UserSettings();
      expect(s.notifNewBatch, true);
      expect(s.notifBatchFull, true);
      expect(s.notifProviderApproval, true);
    });
  });

  group('UserSettings.fromJson', () {
    test('parses full JSON correctly', () {
      final s = UserSettings.fromJson({
        'language': 'fr',
        'theme': 'dark',
        'notif_new_batch': false,
        'notif_batch_full': false,
        'notif_provider_approval': false,
      });
      expect(s.language, 'fr');
      expect(s.theme, 'dark');
      expect(s.notifNewBatch, false);
      expect(s.notifBatchFull, false);
      expect(s.notifProviderApproval, false);
    });

    test('applies defaults for missing fields', () {
      final s = UserSettings.fromJson({});
      expect(s.language, 'en');
      expect(s.theme, 'system');
      expect(s.notifNewBatch, true);
      expect(s.notifBatchFull, true);
      expect(s.notifProviderApproval, true);
    });

    test('handles partial JSON', () {
      final s = UserSettings.fromJson({'language': 'fr'});
      expect(s.language, 'fr');
      expect(s.theme, 'system'); // default
    });

    test('handles null values in JSON by using defaults', () {
      final s = UserSettings.fromJson({
        'language': null,
        'theme': null,
        'notif_new_batch': null,
      });
      expect(s.language, 'en');
      expect(s.theme, 'system');
      expect(s.notifNewBatch, true);
    });
  });

  group('UserSettings.toJson', () {
    test('serialises all fields', () {
      const s = UserSettings(
        language: 'fr',
        theme: 'dark',
        notifNewBatch: false,
        notifBatchFull: false,
        notifProviderApproval: true,
      );
      final json = s.toJson();
      expect(json['language'], 'fr');
      expect(json['theme'], 'dark');
      expect(json['notif_new_batch'], false);
      expect(json['notif_batch_full'], false);
      expect(json['notif_provider_approval'], true);
    });

    test('roundtrip fromJson → toJson preserves values', () {
      final original = UserSettings.fromJson({
        'language': 'fr',
        'theme': 'light',
        'notif_new_batch': false,
        'notif_batch_full': true,
        'notif_provider_approval': false,
      });
      final roundtripped = UserSettings.fromJson(original.toJson());
      expect(roundtripped.language, original.language);
      expect(roundtripped.theme, original.theme);
      expect(roundtripped.notifNewBatch, original.notifNewBatch);
      expect(roundtripped.notifBatchFull, original.notifBatchFull);
      expect(roundtripped.notifProviderApproval, original.notifProviderApproval);
    });
  });

  group('UserSettings.copyWith', () {
    test('returns new instance preserving unchanged fields', () {
      const s = UserSettings(language: 'en', theme: 'light');
      final copy = s.copyWith(language: 'fr');
      expect(copy.language, 'fr');
      expect(copy.theme, 'light');
    });

    test('can update theme only', () {
      const s = UserSettings();
      final copy = s.copyWith(theme: 'dark');
      expect(copy.theme, 'dark');
      expect(copy.language, 'en');
    });

    test('can disable notification flags', () {
      const s = UserSettings();
      final copy = s.copyWith(notifNewBatch: false, notifBatchFull: false);
      expect(copy.notifNewBatch, false);
      expect(copy.notifBatchFull, false);
      expect(copy.notifProviderApproval, true); // unchanged
    });
  });
}
