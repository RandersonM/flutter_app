import 'package:opfan/features/nami_finances/data/finance_math.dart';
import 'package:opfan/features/nami_finances/tools/get_finances_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';

/// Deterministically maps a user's chat message to the finances [ToolCall] to
/// run, extracting amounts and installment terms in Dart.
///
/// This exists because the small on-device model is unreliable at choosing and
/// emitting tool calls (it tends to *describe* using a tool without emitting a
/// real call, and to mangle numbers). Routing here — then feeding the tool's
/// pre-formatted result back for narration — is the reliable path. Pure and
/// unit-tested.
class NamiIntentRouter {
  const NamiIntentRouter();

  ToolCall resolve(String text) {
    final lower = text.toLowerCase();
    final term = extractTermMonths(text);
    final amounts = extractAmounts(text, excludeTermMonths: term);

    // Installment / financing a purchase.
    final installmentIntent = RegExp(
      r'parcel|presta[çc][aã]o|financi|\bvezes\b|\bcarro\b|comprar|\bmoto\b|\bcasa\b|\bapê\b|\bapartamento\b',
    ).hasMatch(lower);
    if (installmentIntent && amounts.isNotEmpty) {
      // "60 a 80 mil" → use the higher (worst case) as the price. The safe
      // installment itself is income-based and price-independent; price only
      // drives the term scenarios.
      final price = amounts.reduce((a, b) => a > b ? a : b);
      final args = <String, dynamic>{'price': price.toStringAsFixed(0)};
      if (RegExp(r'entrada|cons[óo]rcio|sinal').hasMatch(lower) &&
          amounts.length >= 2) {
        final down = amounts.reduce((a, b) => a < b ? a : b);
        args['downPayment'] = down.toStringAsFixed(0);
      }
      if (term != null) args['term'] = term.toString();
      return ToolCall(name: 'affordableInstallment', arguments: args);
    }

    // Savings goal.
    final goalIntent = RegExp(
      r'\bmeta\b|juntar|economizar|poupar|guardar para|objetivo|quero ter',
    ).hasMatch(lower);
    if (goalIntent && amounts.isNotEmpty) {
      final target = amounts.reduce((a, b) => a > b ? a : b);
      return ToolCall(
        name: 'simulateGoalPlan',
        arguments: {'targetAmount': target.toStringAsFixed(0)},
      );
    }

    // Budget rule.
    if (RegExp(r'or[çc]amento|50/30/20|budget|\bregra\b').hasMatch(lower)) {
      return ToolCall(name: 'budgetBreakdown', arguments: const {});
    }

    // Default: finances data for the relevant month/range.
    return _financesDataCall(text);
  }

  /// Extracts a financing term in months from phrases like "100 vezes",
  /// "em 48x", "24 meses". Returns null when none is stated.
  int? extractTermMonths(String text) {
    final m = RegExp(
      r'(\d{1,3})\s*(vezes|x\b|parcelas|meses)',
      caseSensitive: false,
    ).firstMatch(text.toLowerCase());
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  /// Extracts monetary amounts from free text, applying a trailing "mil"/"mi"
  /// scale to bare numbers (so "60 a 80 mil" → [60000, 80000]) and skipping the
  /// term count ("100 vezes") when [excludeTermMonths] is provided.
  List<double> extractAmounts(String text, {int? excludeTermMonths}) {
    final lower = text.toLowerCase();
    final hasMilhao = RegExp(r'milh|\bmi\b').hasMatch(lower);
    final hasMil =
        RegExp(r'mil').hasMatch(lower) || RegExp(r'\dk\b|\bk\b').hasMatch(lower);

    // Drop the term phrase so its count isn't read as an amount.
    final scrubbed = text.replaceAll(
      RegExp(r'\d{1,3}\s*(vezes|x\b|parcelas|meses)', caseSensitive: false),
      ' ',
    );

    final result = <double>[];
    for (final match in RegExp(r'\d[\d.,]*').allMatches(scrubbed)) {
      final parsed = FinanceMath.parseAmount(match.group(0));
      if (parsed == null) continue;
      var value = parsed;
      if (value < 1000) {
        if (hasMilhao) {
          value *= 1000000;
        } else if (hasMil) {
          value *= 1000;
        }
      }
      if (excludeTermMonths != null && value == excludeTermMonths.toDouble()) {
        continue;
      }
      result.add(value);
    }
    return result;
  }

  /// Default finances-data call, inferring the target month from the message.
  ToolCall _financesDataCall(String text) {
    final lower = text.toLowerCase();

    final ymd = RegExp(r'(\d{4})-(\d{1,2})').firstMatch(text);
    if (ymd != null) {
      final mm = ymd.group(2)!.padLeft(2, '0');
      return ToolCall(
        name: GetFinancesHandler.toolName,
        arguments: {'month': '${ymd.group(1)}-$mm'},
      );
    }

    final mdy = RegExp(r'(\d{1,2})/(\d{4})').firstMatch(text);
    if (mdy != null) {
      final mm = mdy.group(1)!.padLeft(2, '0');
      return ToolCall(
        name: GetFinancesHandler.toolName,
        arguments: {'month': '${mdy.group(2)}-$mm'},
      );
    }

    if (lower.contains('passad') ||
        lower.contains('anterior') ||
        lower.contains('last month') ||
        lower.contains('previous')) {
      return ToolCall(
        name: GetFinancesHandler.toolName,
        arguments: {'month': 'last'},
      );
    }

    // Recent months + accumulated reserves cover "this month", "how much have I
    // saved", trends, etc.
    return ToolCall(
      name: GetFinancesHandler.toolName,
      arguments: const {'monthsBack': '6'},
    );
  }
}
