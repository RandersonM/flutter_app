import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/user_profile/models/body_profile.dart';

final _signedInUser = UserModel(
  uid: 'alice',
  email: 'alice@example.com',
  displayName: 'Alice',
  emailVerified: true,
  providerId: 'google.com',
  createdAt: DateTime(2024),
  lastSignIn: DateTime(2024),
);

const _profile = BodyProfile(
  gender: 'female',
  age: 30,
  heightCm: 165,
  weightKg: 60.5,
  activityLevel: 'moderate',
  goal: 'maintenance',
  waistCm: 70,
);

void main() {
  group('BodyProfile behaviour', () {
    test('reads the body-only document the app writes', () {
      final profile = BodyProfile.fromFirestore({
        'gender': 'female',
        'age': 30,
        'height_cm': 165,
        'weight_kg': 60.5,
        'activity_level': 'moderate',
        'goal': 'maintenance',
        'waist_cm': 70,
        'chest_cm': null,
        'updated_at': Object(),
      });

      expect(profile, _profile);
      expect(profile.applyTo(_signedInUser).isProfileComplete, isTrue);
    });

    test('reads a legacy document that also carries identity fields', () {
      final profile = BodyProfile.fromFirestore({
        ..._profile.toFirestore(),
        'uid': 'alice',
        'email': 'alice@example.com',
        'display_name': 'Alice',
        'created_at': DateTime(2024),
        'last_sign_in': '2024-01-01T00:00:00.000',
      });

      expect(profile, _profile);
    });

    test('ignores fields of the wrong type instead of failing', () {
      final profile = BodyProfile.fromFirestore({
        'gender': 1,
        'age': '30',
        'height_cm': 165,
      });

      expect(profile, const BodyProfile(heightCm: 165));
    });

    test('writes only the keys the rules allow', () {
      expect(_profile.toFirestore().keys, {
        'gender',
        'age',
        'height_cm',
        'weight_kg',
        'activity_level',
        'goal',
        'waist_cm',
        'chest_cm',
        'arm_cm',
        'hip_cm',
        'thigh_cm',
      });
    });

    test('keeps the user identity and the fields it does not have', () {
      final cachedUser = _profile.applyTo(_signedInUser);

      final user = const BodyProfile(weightKg: 58).applyTo(cachedUser);

      expect(user.uid, 'alice');
      expect(user.displayName, 'Alice');
      expect(user.weightKg, 58);
      expect(user.heightCm, 165);
      expect(BodyProfile.fromUser(cachedUser), _profile);
    });

    test('clears on the user the measures it replaces with nothing', () {
      final measured = _profile.applyTo(_signedInUser);

      final cleared = const BodyProfile(
        gender: 'female',
        age: 30,
        heightCm: 165,
        weightKg: 60.5,
        activityLevel: 'moderate',
        goal: 'maintenance',
      ).replaceIn(measured);

      expect(cleared.waistCm, isNull);
      expect(cleared.uid, 'alice');
      expect(cleared.isProfileComplete, isTrue);
    });

    test('saves only the fields it has and the ones the user cleared', () {
      const cleared = BodyProfile(
        gender: 'female',
        age: 30,
        heightCm: 165,
        weightKg: 60.5,
        activityLevel: 'moderate',
        goal: 'maintenance',
        chestCm: 90,
      );

      final changes = cleared.toFirestoreChanges(previous: _profile);

      expect(changes['chest_cm'], 90);
      expect(changes.containsKey('waist_cm'), isTrue);
      expect(changes['waist_cm'], isNull);
      expect(changes.containsKey('hip_cm'), isFalse);
      expect(cleared.toFirestoreChanges().containsKey('waist_cm'), isFalse);
    });
  });
}
