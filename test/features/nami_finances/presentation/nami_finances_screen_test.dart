import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/nami_finances/bloc/index.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'package:opfan/features/nami_finances/presentation/nami_finances_screen.dart';
import 'package:opfan/features/nami_finances/presentation/widgets/finances_setup_form.dart';

import '../../../testable_widget.dart';

class _MockFinancesService extends Mock implements INamiFinancesService {}

class _MockRagService extends Mock implements INamiRagService {}

final _now = DateTime.now();

final _month = NamiFinancesModel(
  id: 'month-id',
  month: DateTime(_now.year, _now.month),
  monthlyIncomes: [
    MonthlyIncomeModel(id: 'income-1', amount: 5000, description: 'Salary'),
  ],
  expenses: [
    ExpenseModel(
      id: 'expense-1',
      amount: 1200,
      category: ExpenseCategory.fixed,
      description: 'Rent',
    ),
  ],
  createdAt: DateTime(_now.year, _now.month),
  updatedAt: DateTime(_now.year, _now.month),
);

void main() {
  final getIt = GetIt.instance;
  late _MockFinancesService service;
  late _MockRagService rag;

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(_month);
  });

  setUp(() {
    service = _MockFinancesService();
    rag = _MockRagService();
    when(() => service.getFinancesForMonth(any())).thenAnswer((_) async {
      return _month;
    });
    when(() => service.canEditFinances(any())).thenAnswer((_) async => true);
    when(() => rag.syncMonth(any())).thenAnswer((_) async {});
    getIt.registerFactory<NamiFinancesBloc>(
      () => NamiFinancesBloc(service, rag),
    );
  });

  tearDown(() => getIt.reset());

  Future<void> openEditForm(WidgetTester tester) async {
    await tester.pumpWidget(getTestableWidget(const NamiFinancesScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit data'));
    await tester.tap(find.text('Edit data'));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  group('NamiFinancesScreen save behaviour', () {
    testWidgets('keeps the form and reports the failure when saving fails', (
      tester,
    ) async {
      when(() => service.getLastMonthsFinances(any())).thenAnswer((_) async {
        return [_month];
      });
      when(() => service.saveFinances(any())).thenThrow(Exception('disk full'));
      await openEditForm(tester);

      await tapSave(tester);

      expect(find.byType(FinancesSetupForm), findsOneWidget);
      expect(find.text("Couldn't save your finances."), findsOneWidget);
    });

    testWidgets('leaves the form once the month is saved', (tester) async {
      when(() => service.getLastMonthsFinances(any())).thenAnswer((_) async {
        return [_month];
      });
      when(() => service.saveFinances(any())).thenAnswer((_) async {});
      await openEditForm(tester);

      await tapSave(tester);

      expect(find.byType(FinancesSetupForm), findsNothing);
      expect(find.text('Edit data'), findsOneWidget);
    });
  });

  group('NamiFinancesScreen history behaviour', () {
    testWidgets('shows an error instead of loading forever', (tester) async {
      when(
        () => service.getLastMonthsFinances(any()),
      ).thenThrow(Exception('corrupt box'));

      await tester.pumpWidget(getTestableWidget(const NamiFinancesScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load your finance history."), findsOneWidget);
      expect(find.text('Loading history...'), findsNothing);
    });
  });
}
