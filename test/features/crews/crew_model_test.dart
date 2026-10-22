import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';

CrewMember _member(String id, String role) =>
    CrewMember(characterId: id, name: id, role: role, bounty: '0');

void main() {
  group('CrewModel behaviour', () {
    test('counts a role as filled only while a member holds it', () {
      final crew = CrewModel(
        name: 'Straw Hats',
        userId: 'alice',
        rolesFilled: const ['captain', 'doctor'],
        members: [_member('luffy', 'captain')],
      );

      expect(crew.isRoleFilled('captain'), isTrue);
      expect(crew.isRoleFilled('doctor'), isFalse);
    });

    test('matches a held role written in another spelling', () {
      final crew = CrewModel(
        name: 'Straw Hats',
        userId: 'alice',
        members: [_member('zoro', 'vice-captain')],
      );

      expect(crew.isRoleFilled('viceCaptain'), isTrue);
    });
  });
}
