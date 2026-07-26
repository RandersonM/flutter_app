import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/finances/i_nami_finances_service.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/tools/get_finances_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/l10n/app_localizations.dart';

/// Hand-written fake so the tests need no mockito codegen.
class _FakeFinancesService implements INamiFinancesService {
  _FakeFinancesService({this.byMonth = const {}, this.accumulated = const {}});

  final Map<String, NamiFinancesModel> byMonth;
  final Map<String, dynamic> accumulated;

  String _key(DateTime m) =>
      '${m.year}-${m.month.toString().padLeft(2, '0')}';

  @override
  Future<NamiFinancesModel?> getFinancesForMonth(DateTime month) async =>
      byMonth[_key(month)];

  @override
  Future<List<NamiFinancesModel>> getLastMonthsFinances(int months) async =>
      byMonth.values.toList();

  @override
  Future<Map<String, dynamic>> getAccumulatedSavingsInfo() async => accumulated;

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
  Future<double> getTotalSavings() async => 0;
  @override
  Future<Map<String, dynamic>> getAccumulatedSavingsInfoLocalized(
    AppLocalizations l10n,
  ) async => accumulated;
}

NamiFinancesModel _model(DateTime month) => NamiFinancesModel(
  id: 'id-${month.year}-${month.month}',
  month: month,
  monthlyIncomes: [
    MonthlyIncomeModel(id: 'i1', amount: 5000, description: 'Salary'),
  ],
  expenses: [
    ExpenseModel(
      id: 'e1',
      amount: 1200,
      category: ExpenseCategory.fixed,
      description: 'Rent',
    ),
  ],
  reserves: [
    ReserveModel(
      id: 'r1',
      amount: 200,
      purpose: ReservePurpose.emergency,
      note: 'buffer',
    ),
    ReserveModel(id: 'r2', amount: 300, purpose: ReservePurpose.travel),
  ],
  reserveGoal: 600,
  savings: 500,
  createdAt: month,
  updatedAt: month,
);

void main() {
  group('NamiFinancesModel reserves getters', () {
    test('totalReserves sums the list when present', () {
      final m = _model(DateTime(2026, 7));
      expect(m.totalReserves, 500);
      expect(m.availableAmount, 5000 - 1200 - 500);
      expect(m.reserveGoalProgress, closeTo(500 / 600, 0.0001));
      expect(m.reservesByPurpose[ReservePurpose.emergency], 200);
      expect(m.reservesByPurpose[ReservePurpose.travel], 300);
    });

    test('totalReserves falls back to legacy savings when list empty', () {
      final legacy = NamiFinancesModel(
        id: 'legacy',
        month: DateTime(2025, 1),
        monthlyIncomes: [
          MonthlyIncomeModel(id: 'i', amount: 1000, description: ''),
        ],
        expenses: [
          ExpenseModel(
            id: 'e',
            amount: 100,
            category: ExpenseCategory.other,
            description: '',
          ),
        ],
        savings: 250,
        createdAt: DateTime(2025, 1),
        updatedAt: DateTime(2025, 1),
      );
      expect(legacy.reserves, isEmpty);
      expect(legacy.totalReserves, 250);
      expect(legacy.reserveGoalProgress, isNull);
    });
  });

  group('GetFinancesHandler', () {
    test('returns structured JSON for a specific month', () async {
      final service = _FakeFinancesService(
        byMonth: {'2026-07': _model(DateTime(2026, 7))},
        accumulated: {
          'totalSavings': 500.0,
          'months': 1,
          'periodText': '1 mês',
        },
      );
      final handler = GetFinancesHandler(financesService: service);

      final result = await handler.execute(
        const ToolCall(name: 'getFinances', arguments: {'month': '2026-07'}),
      );

      expect(result.isError, isFalse);
      final json = jsonDecode(result.content) as Map<String, dynamic>;
      final month = (json['months'] as List).first as Map<String, dynamic>;

      expect(month['hasData'], isTrue);
      expect(month['totalIncome_formatted'], 'R\$ 5.000,00');
      expect(month['totalReserves_formatted'], 'R\$ 500,00');
      expect(month['reserveGoal_formatted'], 'R\$ 600,00');
      expect(month['reserveGoalProgress_formatted'], '83%');
      expect((month['reserves'] as List).length, 2);
      expect(json['accumulatedReserves']['total_formatted'], 'R\$ 500,00');
      // Cross-month summary is pre-computed and formatted.
      expect(json['summary']['totalIncome_formatted'], 'R\$ 5.000,00');
    });

    test('reports hasData:false for a month with no record', () async {
      final service = _FakeFinancesService(accumulated: {'totalSavings': 0.0});
      final handler = GetFinancesHandler(financesService: service);

      final result = await handler.execute(
        const ToolCall(name: 'getFinances', arguments: {'month': '2020-01'}),
      );

      final json = jsonDecode(result.content) as Map<String, dynamic>;
      final month = (json['months'] as List).first as Map<String, dynamic>;
      expect(month['hasData'], isFalse);
      expect(month['month'], '2020-01');
    });
  });
}
