import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/finances/i_nami_finances_service.dart';
import 'package:opfan/features/nami_finances/data/models/expense_match.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'package:opfan/features/nami_finances/tools/find_expenses_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/l10n/app_localizations.dart';

/// Hand-written fakes so the tests need neither mockito codegen nor the
/// flutter_gemma plugin (which requires a device).
class _FakeRag implements INamiRagService {
  _FakeRag(this.matches);

  final List<ExpenseMatch> matches;
  String? lastQuery;

  @override
  Future<List<ExpenseMatch>> findExpenses(
    String query, {
    int topK = 8,
    double threshold = 0.55,
  }) async {
    lastQuery = query;
    return matches;
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> syncMonth(NamiFinancesModel model) async {}
  @override
  Future<void> backfillIfNeeded(List<NamiFinancesModel> months) async {}
}

class _FakeFinancesService implements INamiFinancesService {
  _FakeFinancesService(this.byMonth);

  final Map<String, NamiFinancesModel> byMonth;
  final List<String> loadedMonths = [];

  String _key(DateTime m) => '${m.year}-${m.month.toString().padLeft(2, '0')}';

  @override
  Future<NamiFinancesModel?> getFinancesForMonth(DateTime month) async {
    loadedMonths.add(_key(month));
    return byMonth[_key(month)];
  }

  // ── Unused by the handler ──────────────────────────────────────────────────
  @override
  Future<NamiFinancesModel?> getCurrentMonthFinances() async => null;
  @override
  Future<void> saveFinances(NamiFinancesModel finances) async {}
  @override
  Future<bool> canEditFinances(DateTime month) async => true;
  @override
  Future<void> deleteFinances(String id) async {}
  @override
  Future<List<NamiFinancesModel>> getAllFinances() async => [];
  @override
  Future<List<NamiFinancesModel>> getFinancesForYear(int year) async => [];
  @override
  Future<List<NamiFinancesModel>> getLastMonthsFinances(int months) async => [];
  @override
  Future<double> getTotalSavings() async => 0;
  @override
  Future<Map<String, dynamic>> getAccumulatedSavingsInfo() async => {};
  @override
  Future<Map<String, dynamic>> getAccumulatedSavingsInfoLocalized(
    AppLocalizations l10n,
  ) async => {};
}

NamiFinancesModel _month(String key, List<ExpenseModel> expenses) {
  final parts = key.split('-');
  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
  return NamiFinancesModel(
    id: key,
    month: date,
    monthlyIncomes: const [],
    expenses: expenses,
    savings: 0,
    reserves: const [],
    createdAt: date,
    updatedAt: date,
  );
}

ExpenseModel _expense(String id, double amount, String description) =>
    ExpenseModel(
      id: id,
      amount: amount,
      category: ExpenseCategory.other,
      description: description,
    );

Future<Map<String, dynamic>> _run(
  FindExpensesHandler handler,
  String query,
) async {
  final result = await handler.execute(
    ToolCall(name: FindExpensesHandler.toolName, arguments: {'query': query}),
  );
  return jsonDecode(result.content) as Map<String, dynamic>;
}

void main() {
  group('FindExpensesHandler', () {
    test('sums matched expenses across months exactly', () async {
      final rag = _FakeRag(const [
        ExpenseMatch(expenseId: 'e1', monthKey: '2026-06', similarity: 0.91),
        ExpenseMatch(expenseId: 'e2', monthKey: '2026-06', similarity: 0.84),
        ExpenseMatch(expenseId: 'e3', monthKey: '2026-07', similarity: 0.72),
      ]);
      final finances = _FakeFinancesService({
        '2026-06': _month('2026-06', [
          _expense('e1', 480.50, 'hotel beira mar'),
          _expense('e2', 120.00, 'gasolina estrada'),
          _expense('x9', 999.00, 'nada a ver'),
        ]),
        '2026-07': _month('2026-07', [
          _expense('e3', 89.90, 'restaurante peixe'),
        ]),
      });

      final payload = await _run(
        FindExpensesHandler(ragService: rag, financesService: finances),
        'viagem pra praia',
      );

      expect(payload['hasMatches'], isTrue);
      expect(payload['matchCount'], 3);
      // 480.50 + 120.00 + 89.90 — the unmatched 999.00 must not leak in.
      expect(payload['total_formatted'], contains('690,40'));
      expect(payload['months'], ['2026-06', '2026-07']);
      expect(payload['query'], 'viagem pra praia');
    });

    test('loads each month once, not once per match', () async {
      final rag = _FakeRag(const [
        ExpenseMatch(expenseId: 'e1', monthKey: '2026-06', similarity: 0.9),
        ExpenseMatch(expenseId: 'e2', monthKey: '2026-06', similarity: 0.8),
        ExpenseMatch(expenseId: 'e3', monthKey: '2026-06', similarity: 0.7),
      ]);
      final finances = _FakeFinancesService({
        '2026-06': _month('2026-06', [
          _expense('e1', 10, 'a'),
          _expense('e2', 20, 'b'),
          _expense('e3', 30, 'c'),
        ]),
      });

      await _run(
        FindExpensesHandler(ragService: rag, financesService: finances),
        'algo',
      );

      expect(finances.loadedMonths, ['2026-06']);
    });

    test('reports no match when retrieval comes back empty', () async {
      final payload = await _run(
        FindExpensesHandler(
          ragService: _FakeRag(const []),
          financesService: _FakeFinancesService(const {}),
        ),
        'coisa inexistente',
      );

      expect(payload['hasMatches'], isFalse);
      expect(payload['matchCount'], 0);
      expect(payload.containsKey('total_formatted'), isFalse);
    });

    test(
      'ignores stale index entries instead of inventing an amount',
      () async {
        // The index still points at an expense the user has since deleted.
        final rag = _FakeRag(const [
          ExpenseMatch(
            expenseId: 'deleted',
            monthKey: '2026-06',
            similarity: 0.9,
          ),
          ExpenseMatch(expenseId: 'e1', monthKey: '2026-06', similarity: 0.8),
        ]);
        final finances = _FakeFinancesService({
          '2026-06': _month('2026-06', [_expense('e1', 50, 'ainda existe')]),
        });

        final payload = await _run(
          FindExpensesHandler(ragService: rag, financesService: finances),
          'algo',
        );

        expect(payload['matchCount'], 1);
        expect(payload['total_formatted'], contains('50,00'));
      },
    );

    test('reports no match when every hit is stale', () async {
      final rag = _FakeRag(const [
        ExpenseMatch(expenseId: 'gone', monthKey: '2026-06', similarity: 0.9),
      ]);
      final finances = _FakeFinancesService({
        '2026-06': _month('2026-06', const []),
      });

      final payload = await _run(
        FindExpensesHandler(ragService: rag, financesService: finances),
        'algo',
      );

      expect(payload['hasMatches'], isFalse);
      expect(payload['note'], isNotNull);
    });

    test('errors on a missing query instead of searching for ""', () async {
      final rag = _FakeRag(const []);
      final result =
          await FindExpensesHandler(
            ragService: rag,
            financesService: _FakeFinancesService(const {}),
          ).execute(
            ToolCall(name: FindExpensesHandler.toolName, arguments: const {}),
          );

      expect(result.isError, isTrue);
      expect(rag.lastQuery, isNull);
    });
  });
}
