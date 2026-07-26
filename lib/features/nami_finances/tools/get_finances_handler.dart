import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/nami_finances/data/finance_math.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_result.dart';
import 'package:opfan/features/vegapunk_chat/tools/tool_handler.dart';

/// [ToolHandler] that exposes the user's saved Nami finances to the model.
///
/// Reusable across chats (implemented against the shared [ToolHandler] +
/// [INamiFinancesService]); currently registered only for the Nami chat.
///
/// Invoked when the model emits, e.g.:
/// ```json
/// {"name": "getFinances", "arguments": {"month": "2026-07"}}
/// {"name": "getFinances", "arguments": {"monthsBack": "3"}}
/// {"name": "getFinances", "arguments": {}}
/// ```
class GetFinancesHandler extends ToolHandler {
  GetFinancesHandler({required INamiFinancesService financesService})
    : _service = financesService;

  final INamiFinancesService _service;

  /// Stable tool name, exposed statically so callers (e.g. the proactive
  /// fallback in NamiChatBloc) can reference it without an instance.
  static const String toolName = 'getFinances';

  @override
  String get name => toolName;

  @override
  String get description =>
      'Retrieve the user\'s saved monthly finances: income, expenses (by '
      'category), reserves (with purpose and notes), reserve goal and progress, '
      'available balance, plus accumulated reserves across all months. Use for '
      'any question about the user\'s money, budget, savings or reserves.';

  @override
  String get descriptionPt =>
      'Recupera as finanças mensais salvas do usuário: receitas, despesas (por '
      'categoria), reservas (com finalidade e observações), meta de reserva e '
      'progresso, saldo disponível, além das reservas acumuladas em todos os '
      'meses. Use para qualquer pergunta sobre dinheiro, orçamento, economia ou '
      'reservas do usuário.';

  @override
  Map<String, String> get parameterDescriptions => {
    'month':
        'The month to fetch, as "YYYY-MM" (e.g. "2026-07"), or "current" for '
        'this month, or "last" for the previous month. Omit for the current month.',
    'monthsBack':
        'Instead of a single month, fetch this many most recent months as an '
        'integer string (e.g. "6"). Optional.',
  };

  @override
  Map<String, String> get parameterDescriptionsPt => {
    'month':
        'O mês a consultar, como "YYYY-MM" (ex: "2026-07"), ou "current" para o '
        'mês atual, ou "last" para o mês anterior. Omita para o mês atual.',
    'monthsBack':
        'Em vez de um único mês, buscar esta quantidade de meses mais recentes '
        'como inteiro em texto (ex: "6"). Opcional.',
  };

  @override
  List<String> get requiredParameters => const [];

  @override
  Future<ToolResult> execute(ToolCall call) async {
    try {
      final args = call.arguments;
      final monthsBackRaw = args['monthsBack']?.toString();
      final monthsBack = int.tryParse(monthsBackRaw ?? '');

      final List<Map<String, dynamic>> monthPayloads = [];
      final List<NamiFinancesModel> records = [];

      if (monthsBack != null && monthsBack > 0) {
        records.addAll(await _service.getLastMonthsFinances(monthsBack));
        for (final record in records) {
          monthPayloads.add(_serializeMonth(record.month, record));
        }
        if (records.isEmpty) {
          monthPayloads.add(_emptyMonth(DateTime.now()));
        }
      } else {
        final target = _resolveMonth(args['month']?.toString());
        final record = await _service.getFinancesForMonth(target);
        if (record != null) records.add(record);
        monthPayloads.add(
          record != null ? _serializeMonth(target, record) : _emptyMonth(target),
        );
      }

      final accumulated = await _service.getAccumulatedSavingsInfo();
      final accumulatedTotal = (accumulated['totalSavings'] as num?)?.toDouble() ?? 0.0;

      // Pre-compute cross-month aggregates so the model never has to sum.
      final agg = FinanceMath.aggregate(records);

      final payload = <String, dynamic>{
        'currency': 'BRL',
        'instructions':
            'All monetary values are provided pre-formatted in the "*_formatted" '
            'fields. Quote those strings verbatim. Do NOT recompute or reformat '
            'any numbers.',
        'months': monthPayloads,
        'summary': {
          'monthsCovered': agg.monthsCount,
          'totalIncome_formatted': FinanceMath.formatBrl(agg.totalIncome),
          'totalExpenses_formatted': FinanceMath.formatBrl(agg.totalExpenses),
          'totalReserves_formatted': FinanceMath.formatBrl(agg.totalReserves),
          'avgMonthlyIncome_formatted': FinanceMath.formatBrl(agg.avgIncome),
          'avgMonthlyExpenses_formatted': FinanceMath.formatBrl(agg.avgExpenses),
          'avgMonthlyReserves_formatted': FinanceMath.formatBrl(agg.avgReserves),
          'avgMonthlyDisposable_formatted': FinanceMath.formatBrl(
            agg.avgDisposable,
          ),
          'savingsRate_formatted': FinanceMath.formatPct(agg.savingsRate),
        },
        'accumulatedReserves': {
          'total_formatted': FinanceMath.formatBrl(accumulatedTotal),
          'monthsTracked': accumulated['months'] ?? 0,
          'periodText': accumulated['periodText'] ?? '',
        },
      };

      return ToolResult.success(toolName: name, content: jsonEncode(payload));
    } catch (e) {
      debugPrint('GetFinancesHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }

  /// Resolves the `month` argument to a concrete month DateTime.
  DateTime _resolveMonth(String? raw) {
    final now = DateTime.now();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'current') {
      return DateTime(now.year, now.month);
    }
    if (raw.toLowerCase() == 'last' || raw.toLowerCase() == 'previous') {
      return DateTime(now.year, now.month - 1);
    }
    // Try "YYYY-MM".
    final match = RegExp(r'^(\d{4})-(\d{1,2})').firstMatch(raw.trim());
    if (match != null) {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      return DateTime(year, month);
    }
    return DateTime(now.year, now.month);
  }

  String _monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  Map<String, dynamic> _emptyMonth(DateTime month) => {
    'month': _monthKey(month),
    'hasData': false,
  };

  Map<String, dynamic> _serializeMonth(
    DateTime month,
    NamiFinancesModel record,
  ) {
    return {
      'month': _monthKey(month),
      'hasData': true,
      'totalIncome_formatted': FinanceMath.formatBrl(record.totalIncome),
      'totalExpenses_formatted': FinanceMath.formatBrl(record.totalExpenses),
      'expensesByCategory': {
        for (final entry in record.expensesByCategory.entries)
          entry.key.name: FinanceMath.formatBrl(entry.value),
      },
      'reserves': record.reserves
          .map(
            (r) => {
              'amount_formatted': FinanceMath.formatBrl(r.amount),
              'purpose': r.purpose.name,
              if (r.note.isNotEmpty) 'note': r.note,
            },
          )
          .toList(),
      'totalReserves_formatted': FinanceMath.formatBrl(record.totalReserves),
      'reserveGoal_formatted': record.reserveGoal == null
          ? null
          : FinanceMath.formatBrl(record.reserveGoal!),
      'reserveGoalProgress_formatted': record.reserveGoalProgress == null
          ? null
          : FinanceMath.formatPct(record.reserveGoalProgress!),
      'availableAmount_formatted': FinanceMath.formatBrl(record.availableAmount),
    };
  }
}
