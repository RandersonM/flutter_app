import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';

/// Deterministic finance formatting, parsing and calculations.
///
/// Everything numeric the Nami assistant shows should go through here so the
/// on-device LLM never has to parse, compute or format numbers itself — it
/// only narrates the ready-made strings. Pure functions, no I/O, unit-tested.
class FinanceMath {
  const FinanceMath._();

  // ── Formatting ─────────────────────────────────────────────────────────────

  /// Formats [value] as Brazilian currency, e.g. `60000` → `R$ 60.000,00`,
  /// or `R$ 60.000` when [withCents] is false (rounded to whole reais).
  /// Built manually (no locale-data init) so it is fully deterministic.
  static String formatBrl(num value, {bool withCents = true}) {
    final negative = value < 0;
    final totalCents = withCents
        ? (value.abs() * 100).round()
        : value.abs().round() * 100;
    final reais = totalCents ~/ 100;
    final cents = totalCents % 100;

    final reaisStr = reais.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < reaisStr.length; i++) {
      if (i > 0 && (reaisStr.length - i) % 3 == 0) buffer.write('.');
      buffer.write(reaisStr[i]);
    }

    final sign = negative ? '-' : '';
    if (!withCents) return '${sign}R\$ $buffer';
    return '${sign}R\$ $buffer,${cents.toString().padLeft(2, '0')}';
  }

  /// Formats a 0..1 ratio as a percentage string, e.g. `0.8333` → `83%`.
  static String formatPct(num ratio, {int decimals = 0}) =>
      '${(ratio * 100).toStringAsFixed(decimals)}%';

  // ── Parsing ────────────────────────────────────────────────────────────────

  /// Parses a loose amount string coming from LLM tool arguments or free text
  /// into a double. Handles pt-BR ("80.000,00"), plain ("80000"), currency
  /// prefixes ("R$ 80.000"), thousand shorthands ("80mil", "80k", "1,5 mi")
  /// and a leading minus sign ("-500").
  /// Returns null when nothing numeric can be extracted.
  static double? parseAmount(String? raw) {
    if (raw == null) return null;
    var s = raw.toLowerCase().trim();
    if (s.isEmpty) return null;

    s = s.replaceAll('r\$', '').replaceAll('reais', '').trim();

    final multiplier = amountScale(s);

    final match = RegExp(r'[\d.,]*\d[\d.,]*').firstMatch(s);
    if (match == null) return null;
    var numStr = match.group(0)!;

    // Normalize pt-BR/US separators to a plain double string.
    final hasComma = numStr.contains(',');
    final hasDot = numStr.contains('.');
    if (hasComma && hasDot) {
      // Assume '.' = thousands, ',' = decimals (pt-BR): 1.234,56 → 1234.56
      numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma) {
      numStr = numStr.replaceAll(',', '.');
    } else if (hasDot) {
      // Dots that group 3 digits are thousands separators (80.000); anything
      // else is a genuine decimal (1.5).
      final parts = numStr.split('.');
      final looksLikeThousands =
          parts.length > 1 && parts.sublist(1).every((p) => p.length == 3);
      if (looksLikeThousands) numStr = numStr.replaceAll('.', '');
    }

    final parsed = double.tryParse(numStr);
    if (parsed == null) return null;
    final sign = _isNegated(s.substring(0, match.start)) ? -1 : 1;
    return sign * parsed * multiplier;
  }

  /// The scale a free-text amount is written in: 1 000 000 for "mi", "mm",
  /// "milhão"/"milhões"; 1 000 for "mil", "k"; otherwise 1. The words must
  /// stand on their own (glued to a number is fine), so "similar", "militar",
  /// "milho" or "milímetros" scale nothing.
  ///
  /// Pass `mmMeansMillions: false` for chat text, where "8 mm" is far more
  /// often millimetres than the finance shorthand for millions.
  static double amountScale(String text, {bool mmMeansMillions = true}) {
    final lower = text.toLowerCase();
    if (_millionsWord.hasMatch(lower) ||
        (mmMeansMillions && _mmWord.hasMatch(lower))) {
      return 1000000;
    }
    if (_thousandsWord.hasMatch(lower)) return 1000;
    return 1;
  }

  static final _millionsWord = RegExp(
    r'(?<!\p{L})(milh(ão|ao|ões|oes)|mi)(?!\p{L})',
    unicode: true,
  );
  static final _mmWord = RegExp(r'(?<!\p{L})mm(?!\p{L})', unicode: true);
  static final _thousandsWord = RegExp(
    r'(?<!\p{L})(mil|k)(?!\p{L})',
    unicode: true,
  );

  /// A minus right before the number, at the start or after a space — not the
  /// hyphen of a word or range ("covid-19", "10-20").
  static bool _isNegated(String textBeforeNumber) =>
      RegExp(r'(^|\s)[-−]\s*$').hasMatch(textBeforeNumber);

  // ── Aggregates over a set of months ─────────────────────────────────────────

  /// Sums and averages income/expenses/reserves/disposable across [months].
  static MonthlyAggregates aggregate(List<NamiFinancesModel> months) {
    if (months.isEmpty) return const MonthlyAggregates.empty();

    var income = 0.0, expenses = 0.0, reserves = 0.0;
    for (final m in months) {
      income += m.totalIncome;
      expenses += m.totalExpenses;
      reserves += m.totalReserves;
    }
    final n = months.length;
    return MonthlyAggregates(
      monthsCount: n,
      totalIncome: income,
      totalExpenses: expenses,
      totalReserves: reserves,
      avgIncome: income / n,
      avgExpenses: expenses / n,
      avgReserves: reserves / n,
    );
  }

  /// Months covered from [firstMonth] through [now], both inclusive: records
  /// for January to March are 3 months. Never less than 1.
  static int monthsTracked(DateTime firstMonth, DateTime now) {
    final months =
        (now.year - firstMonth.year) * 12 + (now.month - firstMonth.month) + 1;
    return months < 1 ? 1 : months;
  }

  /// Top of the history chart's value axis: the largest bar or income of any
  /// month, so no bar overflows. Never 0, which the chart cannot scale.
  static double historyChartMaxY(List<NamiFinancesModel> months) {
    var maxY = 0.0;
    for (final m in months) {
      for (final value in [
        m.totalIncome,
        m.totalExpenses,
        m.availableAmount,
        m.totalReserves,
      ]) {
        if (value > maxY) maxY = value;
      }
    }
    return maxY > 0 ? maxY : 1;
  }

  // ── Calculators ─────────────────────────────────────────────────────────────

  /// Plan to reach [targetAmount] given [currentReserves] and how much can be
  /// set aside monthly ([monthlyContribution]). If [targetMonths] is given,
  /// computes the required monthly contribution instead.
  static GoalPlan goalPlan({
    required double targetAmount,
    required double currentReserves,
    required double monthlyContribution,
    int? targetMonths,
  }) {
    final remaining = (targetAmount - currentReserves).clamp(
      0,
      double.infinity,
    );

    if (targetMonths != null && targetMonths > 0) {
      return GoalPlan(
        targetAmount: targetAmount,
        currentReserves: currentReserves,
        remaining: remaining.toDouble(),
        requiredMonthlyContribution: remaining / targetMonths,
        monthsToReach: targetMonths,
      );
    }

    int? months;
    if (remaining <= 0) {
      months = 0;
    } else if (monthlyContribution > 0) {
      months = (remaining / monthlyContribution).ceil();
    }
    return GoalPlan(
      targetAmount: targetAmount,
      currentReserves: currentReserves,
      remaining: remaining.toDouble(),
      requiredMonthlyContribution: monthlyContribution,
      monthsToReach: months,
    );
  }

  /// Affordability of a purchase financed after a down payment / consórcio.
  ///
  /// [maxIncomePct] is the classic "installment ≤ X% of income" guideline;
  /// [monthlyDisposable] caps what is actually sustainable (income − expenses).
  /// Interest is intentionally excluded (simple estimate) — the caller should
  /// note that in the narrative.
  static InstallmentPlan affordableInstallment({
    required double price,
    required double downPayment,
    required double monthlyIncome,
    required double monthlyDisposable,
    double maxIncomePct = 0.30,
    List<int> terms = const [12, 24, 36, 48, 60],
  }) {
    final financed = (price - downPayment).clamp(0, double.infinity).toDouble();
    final safeByIncome = monthlyIncome * maxIncomePct;
    final safeByDisposable = monthlyDisposable
        .clamp(0, double.infinity)
        .toDouble();
    final recommendedMax = safeByIncome < safeByDisposable
        ? safeByIncome
        : safeByDisposable;

    final scenarios = <InstallmentScenario>[
      for (final t in terms)
        InstallmentScenario(
          termMonths: t,
          installment: t > 0 ? financed / t : 0,
          withinBudget: t > 0 && (financed / t) <= recommendedMax,
        ),
    ];

    final monthsAtRecommended = recommendedMax > 0
        ? (financed / recommendedMax).ceil()
        : null;

    return InstallmentPlan(
      price: price,
      downPayment: downPayment,
      financed: financed,
      safeByIncome: safeByIncome,
      safeByDisposable: safeByDisposable,
      recommendedMaxInstallment: recommendedMax,
      monthsAtRecommendedMax: monthsAtRecommended,
      scenarios: scenarios,
    );
  }

  /// 50/30/20 budget guideline vs. actuals (needs/wants/savings).
  static BudgetBreakdown budget5030020({
    required double income,
    required double needs,
    required double wants,
    required double savings,
  }) {
    return BudgetBreakdown(
      income: income,
      needs: needs,
      wants: wants,
      savings: savings,
      needsTarget: income * 0.50,
      wantsTarget: income * 0.30,
      savingsTarget: income * 0.20,
    );
  }
}

class MonthlyAggregates {
  final int monthsCount;
  final double totalIncome;
  final double totalExpenses;
  final double totalReserves;
  final double avgIncome;
  final double avgExpenses;
  final double avgReserves;

  const MonthlyAggregates({
    required this.monthsCount,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalReserves,
    required this.avgIncome,
    required this.avgExpenses,
    required this.avgReserves,
  });

  const MonthlyAggregates.empty()
    : monthsCount = 0,
      totalIncome = 0,
      totalExpenses = 0,
      totalReserves = 0,
      avgIncome = 0,
      avgExpenses = 0,
      avgReserves = 0;

  double get avgDisposable => avgIncome - avgExpenses - avgReserves;
  double get savingsRate => avgIncome > 0 ? avgReserves / avgIncome : 0;
}

class GoalPlan {
  final double targetAmount;
  final double currentReserves;
  final double remaining;
  final double requiredMonthlyContribution;

  /// Null when it can't be reached at the current pace (no contribution).
  final int? monthsToReach;

  const GoalPlan({
    required this.targetAmount,
    required this.currentReserves,
    required this.remaining,
    required this.requiredMonthlyContribution,
    required this.monthsToReach,
  });
}

class InstallmentScenario {
  final int termMonths;
  final double installment;
  final bool withinBudget;

  const InstallmentScenario({
    required this.termMonths,
    required this.installment,
    required this.withinBudget,
  });
}

class InstallmentPlan {
  final double price;
  final double downPayment;
  final double financed;
  final double safeByIncome;
  final double safeByDisposable;
  final double recommendedMaxInstallment;
  final int? monthsAtRecommendedMax;
  final List<InstallmentScenario> scenarios;

  const InstallmentPlan({
    required this.price,
    required this.downPayment,
    required this.financed,
    required this.safeByIncome,
    required this.safeByDisposable,
    required this.recommendedMaxInstallment,
    required this.monthsAtRecommendedMax,
    required this.scenarios,
  });
}

class BudgetBreakdown {
  final double income;
  final double needs;
  final double wants;
  final double savings;
  final double needsTarget;
  final double wantsTarget;
  final double savingsTarget;

  const BudgetBreakdown({
    required this.income,
    required this.needs,
    required this.wants,
    required this.savings,
    required this.needsTarget,
    required this.wantsTarget,
    required this.savingsTarget,
  });
}
