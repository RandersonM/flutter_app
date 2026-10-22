import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/finances/i_nami_finances_service.dart';
import 'package:opfan/features/nami_finances/data/finance_math.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_result.dart';
import 'package:opfan/features/vegapunk_chat/tools/tool_handler.dart';

/// Answers "how much did I spend on `<thing>`" where the thing is something
/// the user described in their own words rather than a category.
///
/// This is the one finances question structured lookup cannot serve: a trip may
/// be spread across `transport`, `food` and `other`, over two months, and is
/// identifiable only from the descriptions the user typed. So retrieval picks
/// **which** expenses are meant, and this handler then does the arithmetic:
///
/// ```
/// query → INamiRagService.findExpenses → expense ids
///       → load records → sum in Dart → exact JSON
/// ```
///
/// The model never sees numbers it has to add up, only a computed total. Vector
/// similarity decides relevance; it never decides money.
///
/// Invoked when the router emits, e.g.:
/// ```json
/// {"name": "findExpenses", "arguments": {"query": "viagem pra praia"}}
/// ```
class FindExpensesHandler extends ToolHandler {
  FindExpensesHandler({
    required INamiRagService ragService,
    required INamiFinancesService financesService,
  }) : _rag = ragService,
       _service = financesService;

  final INamiRagService _rag;
  final INamiFinancesService _service;

  static const String toolName = 'findExpenses';

  /// Cap on how many matched expenses are described back to the model. The
  /// total is computed over all matches regardless — truncation affects only
  /// the itemised list, never the sum.
  static const int _maxItemsDescribed = 10;

  /// Until the backfill finishes (first run after an update, embedder still
  /// loading) older months may be missing from the index.
  static const String _partialIndexNote =
      'Some months are still being indexed, so this search may have missed '
      'expenses. Do not say the user spent nothing on this; say the total may '
      'be incomplete and to ask again later.';

  @override
  String get name => toolName;

  @override
  String get description =>
      'Find the user\'s saved expenses whose description matches a thing '
      'described in their own words (a trip, a gift, a repair), then return '
      'those expenses and their exact total. Use when the user asks how much '
      'they spent on something that is NOT one of the fixed categories and NOT '
      'a whole month — for a month or category total use getFinances instead.';

  @override
  String get descriptionPt =>
      'Encontra as despesas salvas do usuário cuja descrição corresponde a algo '
      'descrito com as palavras dele (uma viagem, um presente, um conserto) e '
      'retorna essas despesas com o total exato. Use quando o usuário perguntar '
      'quanto gastou com algo que NÃO é uma das categorias fixas e NÃO é um mês '
      'inteiro — para total de mês ou de categoria use getFinances.';

  @override
  Map<String, String> get parameterDescriptions => const {
    'query':
        'The thing to look for, in the user\'s own words (e.g. "viagem pra '
        'praia", "presente da minha mãe"). Do not include amounts or dates.',
  };

  @override
  Map<String, String> get parameterDescriptionsPt => const {
    'query':
        'O que procurar, nas palavras do usuário (ex: "viagem pra praia", '
        '"presente da minha mãe"). Não inclua valores nem datas.',
  };

  @override
  List<String> get requiredParameters => const ['query'];

  @override
  Future<ToolResult> execute(ToolCall call) async {
    final query = call.arguments['query']?.toString().trim() ?? '';
    if (query.isEmpty) {
      return ToolResult.error(
        toolName: name,
        reason: 'Missing required "query" argument.',
      );
    }

    try {
      final matches = await _rag.findExpenses(query);
      final partial = await _rag.isIndexComplete()
          ? const <String, Object>{}
          : const {'indexComplete': false, 'indexNote': _partialIndexNote};
      if (matches.isEmpty) {
        return ToolResult.success(
          toolName: name,
          content: jsonEncode({
            'query': query,
            'hasMatches': false,
            'matchCount': 0,
            ...partial,
          }),
        );
      }

      // One month load per distinct month, not one per match.
      final monthKeys = matches.map((m) => m.monthKey).toSet();
      final expensesById = <String, _LocatedExpense>{};
      for (final monthKey in monthKeys) {
        final month = _parseMonthKey(monthKey);
        if (month == null) continue;
        final record = await _service.getFinancesForMonth(month);
        if (record == null) continue;
        for (final expense in record.expenses) {
          expensesById[expense.id] = _LocatedExpense(expense, monthKey);
        }
      }

      // Only matches that still resolve to a stored expense count. A stale
      // index entry (expense edited away since indexing) must not contribute a
      // phantom amount to the total.
      final resolved = <_LocatedExpense>[];
      for (final match in matches) {
        final located = expensesById[match.expenseId];
        if (located != null) resolved.add(located);
      }

      if (resolved.isEmpty) {
        return ToolResult.success(
          toolName: name,
          content: jsonEncode({
            'query': query,
            'hasMatches': false,
            'matchCount': 0,
            'note': 'Matched index entries no longer exist in saved finances.',
            ...partial,
          }),
        );
      }

      final total = resolved.fold<double>(
        0,
        (sum, e) => sum + e.expense.amount,
      );

      return ToolResult.success(
        toolName: name,
        content: jsonEncode({
          'query': query,
          'hasMatches': true,
          'matchCount': resolved.length,
          'total_formatted': FinanceMath.formatBrl(total),
          'months': (resolved.map((e) => e.monthKey).toSet().toList()..sort()),
          'expenses': resolved
              .take(_maxItemsDescribed)
              .map(
                (e) => {
                  'description': e.expense.description,
                  'category': e.expense.category.name,
                  'month': e.monthKey,
                  'amount_formatted': FinanceMath.formatBrl(e.expense.amount),
                },
              )
              .toList(),
          if (resolved.length > _maxItemsDescribed)
            'truncatedItems': resolved.length - _maxItemsDescribed,
          ...partial,
        }),
      );
    } catch (e) {
      debugPrint('FindExpensesHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }

  static DateTime? _parseMonthKey(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) return null;
    return DateTime(year, month);
  }
}

/// An expense plus the month it was found in, so the itemised output can say
/// when each hit happened without a second lookup.
class _LocatedExpense {
  const _LocatedExpense(this.expense, this.monthKey);

  final ExpenseModel expense;
  final String monthKey;
}
