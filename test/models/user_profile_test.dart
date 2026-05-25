// ============================================================================
// Tests for UserProfile model
// ============================================================================
import 'package:batchit/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

UserProfile makeProfile({
  String id = 'u1',
  String username = 'jdoe',
  String email = 'j@example.com',
  String? firstName,
  String? lastName,
  String? avatarUrl,
  bool isStaff = false,
}) =>
    UserProfile(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      isStaff: isStaff,
    );

void main() {
  group('UserProfile.displayName', () {
    test('returns firstName + lastName when both provided', () {
      final p = makeProfile(firstName: 'John', lastName: 'Doe');
      expect(p.displayName, 'John Doe');
    });

    test('returns firstName when lastName is null', () {
      final p = makeProfile(firstName: 'Alice', lastName: null);
      expect(p.displayName, 'Alice');
    });

    test('returns firstName when lastName is empty', () {
      final p = makeProfile(firstName: 'Alice', lastName: '');
      expect(p.displayName, 'Alice');
    });

    test('returns lastName when firstName is null', () {
      final p = makeProfile(firstName: null, lastName: 'Smith');
      expect(p.displayName, 'Smith');
    });

    test('returns lastName when firstName is empty', () {
      final p = makeProfile(firstName: '', lastName: 'Smith');
      expect(p.displayName, 'Smith');
    });

    test('returns username when both names are null', () {
      final p = makeProfile(firstName: null, lastName: null, username: 'user123');
      expect(p.displayName, 'user123');
    });

    test('returns username when both names are empty', () {
      final p = makeProfile(firstName: '', lastName: '', username: 'fallback');
      expect(p.displayName, 'fallback');
    });
  });

  group('UserProfile.copyWith', () {
    test('preserves existing values when nothing overridden', () {
      final p = makeProfile(id: '42', username: 'base', email: 'base@x.com');
      final copy = p.copyWith();
      expect(copy.id, '42');
      expect(copy.username, 'base');
      expect(copy.email, 'base@x.com');
    });

    test('overrides only specified fields', () {
      final p = makeProfile(firstName: 'Old', lastName: 'Name');
      final copy = p.copyWith(firstName: 'New');
      expect(copy.firstName, 'New');
      expect(copy.lastName, 'Name'); // unchanged
    });

    test('can update email', () {
      final p = makeProfile(email: 'old@x.com');
      final copy = p.copyWith(email: 'new@x.com');
      expect(copy.email, 'new@x.com');
    });

    test('can set isStaff to true', () {
      final p = makeProfile(isStaff: false);
      final copy = p.copyWith(isStaff: true);
      expect(copy.isStaff, true);
    });

    test('can update avatarUrl', () {
      final p = makeProfile(avatarUrl: null);
      final copy = p.copyWith(avatarUrl: 'https://example.com/pic.jpg');
      expect(copy.avatarUrl, 'https://example.com/pic.jpg');
    });
  });

  group('UserProfile fields', () {
    test('isStaff defaults to false', () {
      final p = UserProfile(id: '1', username: 'u', email: 'e@x.com');
      expect(p.isStaff, false);
    });

    test('avatarUrl defaults to null', () {
      final p = UserProfile(id: '1', username: 'u', email: 'e@x.com');
      expect(p.avatarUrl, isNull);
    });
  });
}
