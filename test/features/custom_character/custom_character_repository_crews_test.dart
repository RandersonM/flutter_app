import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository.dart';

class _MockFirestoreService extends Mock implements IFirestoreService {}

class _MockCrewRepository extends Mock implements ICrewRepository {}

void main() {
  late _MockFirestoreService firestore;
  late _MockCrewRepository crews;
  late CustomCharacterRepository repository;

  final captainLuffy = CrewMember(
    characterId: 'luffy',
    name: 'Luffy',
    nickname: 'Straw Hat',
    role: 'captain',
    bounty: '3,000,000,000',
  );
  final strawHats = CrewModel(
    id: 'c1',
    name: 'Straw Hats',
    userId: 'alice',
    captain: 'Luffy',
    rolesFilled: const ['captain'],
    members: [captainLuffy],
  );

  CustomCharacterModel luffyNamed(String name) => CustomCharacterModel(
    id: 'luffy',
    name: name,
    nickname: 'Straw Hat',
    affiliations: const [],
    image: '',
    occupation: const ['captain'],
    bounty: '3,000,000,000',
    crew: 'Straw Hats',
  );

  setUpAll(() => registerFallbackValue(captainLuffy));

  setUp(() {
    firestore = _MockFirestoreService();
    crews = _MockCrewRepository();
    repository = CustomCharacterRepository(crews, firestoreService: firestore);
    when(
      () => firestore.updateUserDocument(
        collection: any(named: 'collection'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => crews.getCrewsByMember('luffy'),
    ).thenAnswer((_) async => [strawHats]);
    when(
      () => crews.updateCrewMember(any(), any(), any()),
    ).thenAnswer((_) async {});
  });

  group('CustomCharacterRepository crew sync behaviour', () {
    test('renames the crew member when the character is renamed', () async {
      await repository.updateCustomCharacter('luffy', luffyNamed('Joy Boy'));

      final member =
          verify(
                () => crews.updateCrewMember('c1', 'luffy', captureAny()),
              ).captured.single
              as CrewMember;
      expect(member.name, 'Joy Boy');
      expect(member.role, 'captain');
      expect(member.nickname, 'Straw Hat');
    });

    test('leaves the crew alone when the member copy is current', () async {
      await repository.updateCustomCharacter('luffy', luffyNamed('Luffy'));

      verifyNever(() => crews.updateCrewMember(any(), any(), any()));
    });

    test('keeps the character saved when the crew sync fails', () async {
      when(
        () => crews.getCrewsByMember('luffy'),
      ).thenThrow(Exception('offline'));

      await repository.updateCustomCharacter('luffy', luffyNamed('Joy Boy'));

      verify(
        () => firestore.updateUserDocument(
          collection: 'custom_characters',
          documentId: 'luffy',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('deleting a captain leaves the captain title to the crew '
        'repository', () async {
      when(
        () => firestore.getDocument(
          collection: 'custom_characters',
          documentId: 'luffy',
        ),
      ).thenAnswer((_) async => {'name': 'Luffy', 'userId': 'alice'});
      when(
        () => firestore.deleteDocument(
          collection: any(named: 'collection'),
          documentId: any(named: 'documentId'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => crews.removeMemberFromCrew('c1', 'luffy'),
      ).thenAnswer((_) async {});

      await repository.deleteCustomCharacter('luffy');

      verify(() => crews.removeMemberFromCrew('c1', 'luffy')).called(1);
      verifyNever(() => crews.setCaptain(any(), any()));
      verifyNever(() => crews.setViceCaptain(any(), any()));
    });
  });
}
