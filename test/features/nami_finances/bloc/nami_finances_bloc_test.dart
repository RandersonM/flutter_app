import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/nami_finances/bloc/index.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';

class _MockFinancesService extends Mock implements INamiFinancesService {}

class _MockRagService extends Mock implements INamiRagService {}

Matcher _failure(NamiFinancesFailure failure) =>
    isA<NamiFinancesError>().having((s) => s.failure, 'failure', failure);

void main() {
  late _MockFinancesService service;
  late _MockRagService rag;
  final month = DateTime(2026, 3);

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(
      NamiFinancesModel(
        id: 'fallback',
        month: DateTime(2000),
        monthlyIncomes: const [],
        expenses: const [],
        createdAt: DateTime(2000),
        updatedAt: DateTime(2000),
      ),
    );
  });

  setUp(() {
    service = _MockFinancesService();
    rag = _MockRagService();
  });

  NamiFinancesBloc build() => NamiFinancesBloc(service, rag);

  SaveFinances save() => SaveFinances(
    incomes: const [],
    expenses: const [],
    reserves: const [],
    month: month,
  );

  group('NamiFinancesBloc failures', () {
    blocTest<NamiFinancesBloc, NamiFinancesState>(
      'emits loadFailed when loading a month throws',
      setUp: () => when(
        () => service.getFinancesForMonth(any()),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(LoadFinances(month)),
      expect: () => [
        isA<NamiFinancesLoading>(),
        _failure(NamiFinancesFailure.loadFailed),
      ],
    );

    blocTest<NamiFinancesBloc, NamiFinancesState>(
      'emits loadFailed when loading the current month throws',
      setUp: () => when(
        () => service.getCurrentMonthFinances(),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(LoadCurrentMonthFinances()),
      expect: () => [
        isA<NamiFinancesLoading>(),
        _failure(NamiFinancesFailure.loadFailed),
      ],
    );

    blocTest<NamiFinancesBloc, NamiFinancesState>(
      'emits historyLoadFailed when loading the history throws',
      setUp: () => when(
        () => service.getLastMonthsFinances(any()),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(LoadFinancesHistory()),
      expect: () => [_failure(NamiFinancesFailure.historyLoadFailed)],
    );

    blocTest<NamiFinancesBloc, NamiFinancesState>(
      'emits futureMonthNotEditable and saves nothing for a future month',
      setUp: () =>
          when(() => service.canEditFinances(any())).thenAnswer((_) async {
            return false;
          }),
      build: build,
      act: (bloc) => bloc.add(save()),
      expect: () => [
        isA<NamiFinancesLoading>(),
        _failure(NamiFinancesFailure.futureMonthNotEditable),
      ],
      verify: (_) {
        verifyNever(() => service.saveFinances(any()));
        verifyNever(() => rag.syncMonth(any()));
      },
    );

    blocTest<NamiFinancesBloc, NamiFinancesState>(
      'emits saveFailed when saving throws',
      setUp: () {
        when(() => service.canEditFinances(any())).thenAnswer((_) async {
          return true;
        });
        when(
          () => service.getFinancesForMonth(any()),
        ).thenAnswer((_) async => null);
        when(
          () => service.saveFinances(any()),
        ).thenThrow(Exception('disk full'));
      },
      build: build,
      act: (bloc) => bloc.add(save()),
      expect: () => [
        isA<NamiFinancesLoading>(),
        _failure(NamiFinancesFailure.saveFailed),
      ],
    );

    blocTest<NamiFinancesBloc, NamiFinancesState>(
      'emits deleteFailed when deleting throws',
      setUp: () =>
          when(() => service.deleteFinances(any())).thenThrow(Exception('x')),
      build: build,
      act: (bloc) => bloc.add(DeleteFinances('id-1')),
      expect: () => [
        isA<NamiFinancesLoading>(),
        _failure(NamiFinancesFailure.deleteFailed),
      ],
    );
  });
}
