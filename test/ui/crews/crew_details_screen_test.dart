import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/features/crews/presentation/crew_details_screen.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../testable_widget.dart';

class _MockCrewRepository extends Mock implements ICrewRepository {}

class _MockCustomCharacterRepository extends Mock
    implements ICustomCharacterRepository {}

class _MockAuthService extends Mock implements IAuthService {}

void main() {
  final getIt = GetIt.instance;
  late _MockCrewRepository crews;
  late _MockCustomCharacterRepository characters;
  late _MockAuthService auth;

  final crew = CrewModel(id: 'c1', name: 'Straw Hats', userId: 'alice');
  final luffy = CustomCharacterModel(
    id: 'luffy',
    name: 'Monkey D. Luffy',
    affiliations: const [],
    image: '',
    occupation: const [],
    bounty: '3,000,000,000',
  );

  void signInAs(String uid) => when(() => auth.currentUser).thenReturn(
    UserModel(
      uid: uid,
      email: '$uid@example.com',
      displayName: uid,
      emailVerified: true,
      providerId: 'google.com',
      createdAt: DateTime(2024),
      lastSignIn: DateTime(2024),
    ),
  );

  setUpAll(() {
    registerFallbackValue(crew);
    registerFallbackValue(luffy);
  });

  setUp(() {
    crews = _MockCrewRepository();
    characters = _MockCustomCharacterRepository();
    auth = _MockAuthService();
    signInAs('alice');
    getIt.registerFactoryParam<CrewDetailsBloc, CrewModel, void>(
      (crew, _) => CrewDetailsBloc(
        crew: crew,
        crewRepository: crews,
        customCharacterRepository: characters,
        authService: auth,
      ),
    );
  });

  tearDown(() => getIt.reset());

  /// Pushes the screen over a home route so its pop result can be observed.
  Future<List<Object?>> pumpScreen(WidgetTester tester) async {
    final results = <Object?>[];
    await tester.pumpWidget(
      getTestableWidget(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await Navigator.of(context).push<Object?>(
                MaterialPageRoute<Object?>(
                  builder: (_) => CrewDetailsScreen(crew: crew),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  group('CrewDetailsScreen behaviour', () {
    testWidgets('hides owner actions from other users', (tester) async {
      signInAs('bob');
      await pumpScreen(tester);

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byTooltip('Delete'), findsNothing);
    });

    testWidgets('deletes the crew after confirmation and closes the screen', (
      tester,
    ) async {
      when(() => crews.deleteCrew('c1')).thenAnswer((_) async {});
      final results = await pumpScreen(tester);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => crews.deleteCrew('c1')).called(1);
      expect(find.byType(CrewDetailsScreen), findsNothing);
      expect(results.single, {'action': 'deleted', 'crewId': 'c1'});
    });

    testWidgets('adds a member picked in the dialog', (tester) async {
      when(
        () => characters.getUserCustomCharacters(),
      ).thenAnswer((_) async => [luffy]);
      when(() => crews.getUserCrews()).thenAnswer((_) async => []);
      when(() => crews.updateCrew(any(), any())).thenAnswer((_) async {});
      when(
        () => characters.updateCustomCharacter(any(), any()),
      ).thenAnswer((_) async {});
      await pumpScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(DropdownButtonFormField<CustomCharacterModel>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monkey D. Luffy').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Captain').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();

      final saved =
          verify(() => crews.updateCrew('c1', captureAny())).captured.single
              as CrewModel;
      expect(saved.members.single.characterId, 'luffy');
      expect(saved.rolesFilled, ['captain']);
      verify(() => characters.updateCustomCharacter('luffy', any())).called(1);
      expect(find.text('Monkey D. Luffy added as Captain'), findsOneWidget);
    });

    testWidgets('shows the empty state when every character has a crew', (
      tester,
    ) async {
      when(
        () => characters.getUserCustomCharacters(),
      ).thenAnswer((_) async => [luffy]);
      when(() => crews.getUserCrews()).thenAnswer(
        (_) async => [
          CrewModel(
            id: 'c2',
            name: 'Other',
            userId: 'alice',
            members: [
              CrewMember(characterId: 'luffy', name: 'Luffy', bounty: '0'),
            ],
          ),
        ],
      );
      await pumpScreen(tester);

      await tester.tap(find.byIcon(PhosphorIconsRegular.userPlus));
      await tester.pumpAndSettle();

      expect(find.text('No characters available to add'), findsOneWidget);
    });
  });
}
