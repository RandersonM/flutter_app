import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opfan/features/sanji_cooking/data/models/nutrition_calculation_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
// 90% neutral + 8% violet + 2% amber
const Color _kViolet = Color(0xFF7C3AED);
const Color _kAmber = Color(0xFFFACC15);
const Color _kCardDark = Color(0xFF1D1D24);
const Color _kMuted = Color(0xFFA1A1AA);

// Alert colors — only used for health classification chips
const Color _kAlertRed = Color(0xFFEF4444);
const Color _kAlertOrange = Color(0xFFF97316);

// ──────────────────────────────────────────────────────────────────────────────

class NutritionResults extends StatelessWidget {
  final NutritionCalculationModel results;

  const NutritionResults({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? _kCardDark : const Color(0xFFFCFCFD);
    final textPrimary = isDark ? Colors.white : const Color(0xFF09090B);

    return Column(
      spacing: Constants.margin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.nutritionResultsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
        ),
        const SizedBox(height: 8),

        // T7 — Metric cards: neutral; TDEE value = amber
        _buildMetricCard(
          context,
          AppLocalizations.of(context)!.bmrTitle,
          AppLocalizations.of(context)!
              .kcalPerDay(results.bmr.toStringAsFixed(0)),
          AppLocalizations.of(context)!.bmrSubtitle,
          valueColor: null,
          cardColor: cardColor,
          textPrimary: textPrimary,
        ),
        _buildMetricCard(
          context,
          AppLocalizations.of(context)!.tdeeTitle,
          AppLocalizations.of(context)!
              .kcalPerDay(results.tdee.toStringAsFixed(0)),
          AppLocalizations.of(context)!.tdeeSubtitle,
          valueColor: _kAmber,
          cardColor: cardColor,
          textPrimary: textPrimary,
        ),

        const SizedBox(height: 8),

        Text(
          AppLocalizations.of(context)!.caloriesPerGoal,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
        ),
        const SizedBox(height: 4),

        // T3 — Calorie cards: selected goal = violet, others = neutral card
        _buildCalorieCard(
          context,
          AppLocalizations.of(context)!.maintainWeight,
          AppLocalizations.of(context)!
              .kcalPerDay(results.maintenanceCalories.toStringAsFixed(0)),
          cardColor: cardColor,
        ),
        _buildCalorieCard(
          context,
          AppLocalizations.of(context)!.loseWeight,
          AppLocalizations.of(context)!
              .kcalPerDay(results.weightLossCalories.toStringAsFixed(0)),
          cardColor: cardColor,
        ),
        _buildCalorieCard(
          context,
          AppLocalizations.of(context)!.gainMuscle,
          AppLocalizations.of(context)!
              .kcalPerDay(results.muscleGainCalories.toStringAsFixed(0)),
          cardColor: cardColor,
        ),

        const SizedBox(height: 8),

        Text(
          AppLocalizations.of(context)!.classifications,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
        ),
        const SizedBox(height: 4),

        // T4 — Classification chips in a neutral card
        _buildClassificationRow(context,
            cardColor: cardColor, textPrimary: textPrimary),

        const SizedBox(height: 24),

        // T5 — Receita Personalizada card
        _buildRecipeCard(context, cardColor: cardColor),

        const SizedBox(height: 16),

        // T6 — Plate Guide card
        _buildPlateGuideButton(context, cardColor: cardColor),
      ],
    );
  }

  // ─── T7: Metric card — neutral design ────────────────────────────────────
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle, {
    required Color? valueColor,
    required Color cardColor,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _kMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  // ─── T3: Calorie card — neutral / selected-violet ─────────────────────────
  Widget _buildCalorieCard(
    BuildContext context,
    String title,
    String calories, {
    required Color cardColor,
  }) {
    final isSelected = _isUserGoal(context, title);
    final bg = isSelected ? _kViolet : cardColor;
    final textColor = isSelected ? Colors.white : _kMuted;
    final caloriesColor = isSelected ? Colors.white : Colors.white70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isSelected) ...[
                Transform.rotate(
                  angle: -30 * 3.14159 / 180,
                  child: SvgPicture.asset('assets/svg/sanji-jolly-roger.svg',
                      width: 20, height: 20),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            ],
          ),
          Text(
            calories,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: caloriesColor,
                ),
          ),
        ],
      ),
    );
  }

  // ─── T4: Classification row — chip style ─────────────────────────────────
  Widget _buildClassificationRow(
    BuildContext context, {
    required Color cardColor,
    required Color textPrimary,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildClassificationChip(
            context,
            label: AppLocalizations.of(context)!.bmi,
            value: _getLocalizedBMICategory(results.bmiCategory, context),
            dotColor: _getBMIColor(results.bmiCategory),
            cardColor: cardColor,
            textPrimary: textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildClassificationChip(
            context,
            label: AppLocalizations.of(context)!.waistToHeight,
            value: _getLocalizedWaistToHeightCategory(
                results.waistToHeightCategory, context),
            dotColor: _getWaistToHeightColor(results.waistToHeightCategory),
            cardColor: cardColor,
            textPrimary: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color dotColor,
    required Color cardColor,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _kMuted,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── T5: Receita Personalizada card ──────────────────────────────────────
  Widget _buildRecipeCard(BuildContext context, {required Color cardColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAmber.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(PhosphorIconsRegular.bookOpenText,
                  color: _kAmber, size: 22),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.sanjiTipTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _kAmber,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.sanjiTipText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          AppButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.cookingTips,
                arguments: {
                  'targetCalories': _getTargetCalories(),
                  'goal': results.goal,
                },
              );
            },
            label: AppLocalizations.of(context)!.sanjiTipTitle,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  // ─── T6: Plate Guide card ─────────────────────────────────────────────────
  Widget _buildPlateGuideButton(BuildContext context,
      {required Color cardColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kViolet.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(PhosphorIconsRegular.bookOpenText,
                  color: _kViolet, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.plateGuideQuestion,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _kViolet,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.plateGuideSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _kMuted,
                ),
          ),
          const SizedBox(height: 16),
          AppButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.plateGuide);
            },
            icon: const AppIcon(PhosphorIconsRegular.eye, size: 18),
            label: AppLocalizations.of(context)!.viewPlateGuide,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  bool _isUserGoal(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    final goalMapping = <String, List<String>>{
      l10n.maintainWeight: ['maintenance', 'maintain'],
      l10n.loseWeight: ['weight_loss', 'lose_weight'],
      l10n.gainMuscle: ['muscle_gain', 'gain_muscle'],
    };
    return goalMapping[title]?.contains(results.goal) ?? false;
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'underweight':
        return _kMuted;
      case 'normalWeight':
        return _kViolet;
      case 'overweight':
        return _kAlertOrange;
      case 'obesityGrade1':
      case 'obesityGrade2':
      case 'obesityGrade3':
        return _kAlertRed;
      default:
        return _kMuted;
    }
  }

  Color _getWaistToHeightColor(String category) {
    switch (category) {
      case 'excellent':
        return _kViolet;
      case 'good':
        return _kViolet;
      case 'attention':
        return _kAlertOrange;
      case 'highRisk':
        return _kAlertRed;
      default:
        return _kMuted;
    }
  }

  String _getLocalizedBMICategory(String category, BuildContext context) {
    switch (category) {
      case 'underweight':
        return AppLocalizations.of(context)!.underweight;
      case 'normalWeight':
        return AppLocalizations.of(context)!.normalWeight;
      case 'overweight':
        return AppLocalizations.of(context)!.overweight;
      case 'obesityGrade1':
        return AppLocalizations.of(context)!.obesityGrade1;
      case 'obesityGrade2':
        return AppLocalizations.of(context)!.obesityGrade2;
      case 'obesityGrade3':
        return AppLocalizations.of(context)!.obesityGrade3;
      default:
        return category;
    }
  }

  String _getLocalizedWaistToHeightCategory(
      String category, BuildContext context) {
    switch (category) {
      case 'excellent':
        return AppLocalizations.of(context)!.excellent;
      case 'good':
        return AppLocalizations.of(context)!.good;
      case 'attention':
        return AppLocalizations.of(context)!.attention;
      case 'highRisk':
        return AppLocalizations.of(context)!.highRisk;
      default:
        return category;
    }
  }

  double _getTargetCalories() {
    switch (results.goal) {
      case 'maintenance':
        return results.maintenanceCalories;
      case 'weight_loss':
        return results.weightLossCalories;
      case 'muscle_gain':
        return results.muscleGainCalories;
      default:
        return results.maintenanceCalories;
    }
  }
}
