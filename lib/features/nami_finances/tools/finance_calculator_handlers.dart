import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/nami_finances/data/finance_math.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_result.dart';
import 'package:opfan/features/vegapunk_chat/tools/tool_handler.dart';

/// Number of recent months used to derive average income/expenses.
const _averageWindowMonths = 3;

Future<MonthlyAggregates> _recentAggregates(INamiFinancesService service) async {
  final months = await service.getLastMonthsFinances(_averageWindowMonths);
  return FinanceMath.aggregate(months);
}

/// Deterministic "can I afford this financed purchase?" calculator.
///
/// The model only needs to supply the price (and optionally the down
/// payment / consórcio); income and expenses come from the user's saved data,
/// and all math + formatting happen here — not in the LLM.
class AffordableInstallmentHandler extends ToolHandler {
  AffordableInstallmentHandler({required INamiFinancesService financesService})
    : _service = financesService;

  final INamiFinancesService _service;

  @override
  String get name => 'affordableInstallment';

  @override
  String get description =>
      'Calculate the affordable monthly installment for a financed purchase '
      '(e.g. a car), using the user\'s real average income and expenses. Returns '
      'the safe installment (default: at most 30% of income and never above '
      'available cash flow) and installment scenarios per term.';

  @override
  String get descriptionPt =>
      'Calcula a parcela mensal viável para uma compra financiada (ex: um carro), '
      'usando a renda e as despesas médias reais do usuário. Retorna a parcela '
      'segura (padrão: no máximo 30% da renda e nunca acima do fluxo de caixa '
      'disponível) e cenários de parcela por prazo.';

  @override
  Map<String, String> get parameterDescriptions => {
    'price': 'Total price of the item, e.g. "80000" or "80 mil". Required.',
    'downPayment':
        'Amount already available as down payment / consórcio, e.g. "60000". '
        'Optional (defaults to 0).',
    'maxIncomePct':
        'Max fraction of income for the installment, e.g. "0.3". Optional.',
    'term':
        'A specific number of installments to also evaluate, e.g. "100". Optional.',
  };

  @override
  Map<String, String> get parameterDescriptionsPt => {
    'price': 'Preço total do item, ex: "80000" ou "80 mil". Obrigatório.',
    'downPayment':
        'Valor já disponível como entrada / consórcio, ex: "60000". '
        'Opcional (padrão 0).',
    'maxIncomePct':
        'Fração máxima da renda para a parcela, ex: "0.3". Opcional.',
    'term':
        'Um número específico de parcelas a avaliar também, ex: "100". Opcional.',
  };

  @override
  List<String> get requiredParameters => const ['price'];

  @override
  Future<ToolResult> execute(ToolCall call) async {
    try {
      final price = FinanceMath.parseAmount(call.arguments['price']?.toString());
      if (price == null || price <= 0) {
        return ToolResult.error(
          toolName: name,
          reason: 'Missing or invalid "price".',
        );
      }
      final downPayment =
          FinanceMath.parseAmount(call.arguments['downPayment']?.toString()) ??
          0.0;
      final maxIncomePct =
          double.tryParse(
            (call.arguments['maxIncomePct']?.toString() ?? '').replaceAll(
              ',',
              '.',
            ),
          ) ??
          0.30;

      final agg = await _recentAggregates(_service);
      // Debt capacity uses income − expenses (reserves are discretionary and
      // could be redirected toward the purchase).
      final disposableForDebt = agg.avgIncome - agg.avgExpenses;

      // Include a user-requested term (e.g. "100 vezes") alongside the defaults.
      final requestedTerm = int.tryParse(
        (call.arguments['term']?.toString() ?? '').trim(),
      );
      final terms = <int>{
        12,
        24,
        36,
        48,
        60,
        if (requestedTerm != null && requestedTerm > 0) requestedTerm,
      }.toList()..sort();

      final plan = FinanceMath.affordableInstallment(
        price: price,
        downPayment: downPayment,
        monthlyIncome: agg.avgIncome,
        monthlyDisposable: disposableForDebt,
        maxIncomePct: maxIncomePct,
        terms: terms,
      );

      final payload = {
        'currency': 'BRL',
        'note':
            'Estimate excludes financing interest. Quote the *_formatted values '
            'verbatim; do not recompute.',
        'basedOnMonths': agg.monthsCount,
        'avgMonthlyIncome_formatted': FinanceMath.formatBrl(agg.avgIncome),
        'avgMonthlyExpenses_formatted': FinanceMath.formatBrl(agg.avgExpenses),
        'price_formatted': FinanceMath.formatBrl(plan.price),
        'downPayment_formatted': FinanceMath.formatBrl(plan.downPayment),
        'amountToFinance_formatted': FinanceMath.formatBrl(plan.financed),
        'maxByIncomeRule_formatted': FinanceMath.formatBrl(plan.safeByIncome),
        'maxByCashFlow_formatted': FinanceMath.formatBrl(plan.safeByDisposable),
        'recommendedMaxInstallment_formatted': FinanceMath.formatBrl(
          plan.recommendedMaxInstallment,
        ),
        'monthsAtRecommendedMax': plan.monthsAtRecommendedMax,
        'scenarios': [
          for (final s in plan.scenarios)
            {
              'termMonths': s.termMonths,
              'installment_formatted': FinanceMath.formatBrl(s.installment),
              'withinBudget': s.withinBudget,
            },
        ],
      };

      return ToolResult.success(toolName: name, content: jsonEncode(payload));
    } catch (e) {
      debugPrint('AffordableInstallmentHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }
}

/// Deterministic "how long to reach a savings goal?" calculator.
class SimulateGoalPlanHandler extends ToolHandler {
  SimulateGoalPlanHandler({required INamiFinancesService financesService})
    : _service = financesService;

  final INamiFinancesService _service;

  @override
  String get name => 'simulateGoalPlan';

  @override
  String get description =>
      'Plan how to reach a savings goal using the user\'s accumulated reserves '
      'and average monthly saving. Provide targetAmount; optionally a monthly '
      'contribution or a target number of months.';

  @override
  String get descriptionPt =>
      'Planeja como atingir uma meta de economia usando as reservas acumuladas e '
      'a média mensal poupada pelo usuário. Informe targetAmount; opcionalmente '
      'uma contribuição mensal ou um prazo em meses.';

  @override
  Map<String, String> get parameterDescriptions => {
    'targetAmount': 'Goal amount, e.g. "20000" or "20 mil". Required.',
    'monthlyContribution':
        'How much can be set aside per month. Optional (defaults to the '
        'average monthly reserve).',
    'targetMonths':
        'Desired number of months to reach the goal. Optional.',
  };

  @override
  Map<String, String> get parameterDescriptionsPt => {
    'targetAmount': 'Valor da meta, ex: "20000" ou "20 mil". Obrigatório.',
    'monthlyContribution':
        'Quanto pode guardar por mês. Opcional (padrão: média mensal poupada).',
    'targetMonths': 'Prazo desejado em meses para atingir a meta. Opcional.',
  };

  @override
  List<String> get requiredParameters => const ['targetAmount'];

  @override
  Future<ToolResult> execute(ToolCall call) async {
    try {
      final target = FinanceMath.parseAmount(
        call.arguments['targetAmount']?.toString(),
      );
      if (target == null || target <= 0) {
        return ToolResult.error(
          toolName: name,
          reason: 'Missing or invalid "targetAmount".',
        );
      }

      final agg = await _recentAggregates(_service);
      final currentReserves = await _service.getTotalSavings();
      final contribution =
          FinanceMath.parseAmount(
            call.arguments['monthlyContribution']?.toString(),
          ) ??
          (agg.avgReserves > 0 ? agg.avgReserves : agg.avgDisposable);
      final targetMonths = int.tryParse(
        (call.arguments['targetMonths']?.toString() ?? '').trim(),
      );

      final plan = FinanceMath.goalPlan(
        targetAmount: target,
        currentReserves: currentReserves,
        monthlyContribution: contribution.clamp(0, double.infinity).toDouble(),
        targetMonths: targetMonths,
      );

      final payload = {
        'currency': 'BRL',
        'note': 'Quote the *_formatted values verbatim; do not recompute.',
        'target_formatted': FinanceMath.formatBrl(plan.targetAmount),
        'currentReserves_formatted': FinanceMath.formatBrl(plan.currentReserves),
        'remaining_formatted': FinanceMath.formatBrl(plan.remaining),
        'monthlyContribution_formatted': FinanceMath.formatBrl(
          plan.requiredMonthlyContribution,
        ),
        'monthsToReach': plan.monthsToReach,
        'reachable': plan.monthsToReach != null,
      };

      return ToolResult.success(toolName: name, content: jsonEncode(payload));
    } catch (e) {
      debugPrint('SimulateGoalPlanHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }
}

/// Deterministic 50/30/20 budget comparison against the user's recent averages.
class BudgetBreakdownHandler extends ToolHandler {
  BudgetBreakdownHandler({required INamiFinancesService financesService})
    : _service = financesService;

  final INamiFinancesService _service;

  @override
  String get name => 'budgetBreakdown';

  @override
  String get description =>
      'Compare the user\'s recent spending against the 50/30/20 budget rule '
      '(needs/wants/savings), using their real average income and expenses.';

  @override
  String get descriptionPt =>
      'Compara os gastos recentes do usuário com a regra de orçamento 50/30/20 '
      '(necessidades/desejos/poupança), usando a renda e as despesas médias reais.';

  @override
  Map<String, String> get parameterDescriptions => const {};

  @override
  Map<String, String> get parameterDescriptionsPt => const {};

  @override
  List<String> get requiredParameters => const [];

  @override
  Future<ToolResult> execute(ToolCall call) async {
    try {
      final months = await _service.getLastMonthsFinances(_averageWindowMonths);
      final agg = FinanceMath.aggregate(months);

      // Classify average expense categories into needs vs wants.
      var needs = 0.0, wants = 0.0;
      for (final m in months) {
        m.expensesByCategory.forEach((category, amount) {
          if (_isNeed(category)) {
            needs += amount;
          } else {
            wants += amount;
          }
        });
      }
      final n = months.isEmpty ? 1 : months.length;
      needs /= n;
      wants /= n;

      final breakdown = FinanceMath.budget5030020(
        income: agg.avgIncome,
        needs: needs,
        wants: wants,
        savings: agg.avgReserves,
      );

      final payload = {
        'currency': 'BRL',
        'note': 'Quote the *_formatted values verbatim; do not recompute.',
        'basedOnMonths': agg.monthsCount,
        'avgMonthlyIncome_formatted': FinanceMath.formatBrl(breakdown.income),
        'needs': {
          'actual_formatted': FinanceMath.formatBrl(breakdown.needs),
          'target50_formatted': FinanceMath.formatBrl(breakdown.needsTarget),
        },
        'wants': {
          'actual_formatted': FinanceMath.formatBrl(breakdown.wants),
          'target30_formatted': FinanceMath.formatBrl(breakdown.wantsTarget),
        },
        'savings': {
          'actual_formatted': FinanceMath.formatBrl(breakdown.savings),
          'target20_formatted': FinanceMath.formatBrl(breakdown.savingsTarget),
        },
      };

      return ToolResult.success(toolName: name, content: jsonEncode(payload));
    } catch (e) {
      debugPrint('BudgetBreakdownHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }

  bool _isNeed(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fixed:
      case ExpenseCategory.food:
      case ExpenseCategory.transport:
      case ExpenseCategory.health:
        return true;
      case ExpenseCategory.entertainment:
      case ExpenseCategory.other:
        return false;
    }
  }
}
