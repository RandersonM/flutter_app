import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opfan/core/models/nutrition_calculation_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/theme.dart';
import 'package:opfan/utils/app_routes.dart';
import 'package:opfan/widgets/atoms/gomu_gomu_divider.dart';

class NutritionResults extends StatelessWidget {
  final NutritionCalculationModel results;

  const NutritionResults({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Constants.margin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.nutritionResultsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        
        _buildMetricCard(
          context,
          AppLocalizations.of(context)!.bmrTitle,
          AppLocalizations.of(context)!.kcalPerDay(results.bmr.toStringAsFixed(0)),
          AppLocalizations.of(context)!.bmrSubtitle,
          null,
        ),
        
        
        _buildMetricCard(
          context,
          AppLocalizations.of(context)!.tdeeTitle,
          AppLocalizations.of(context)!.kcalPerDay(results.tdee.toStringAsFixed(0)),
          AppLocalizations.of(context)!.tdeeSubtitle,
          AppColors.yellow[500]!,
        ),
        
        GomuGomuDivider(
          color: Theme.of(context).colorScheme.primary,
        ),
        
        Text(
          AppLocalizations.of(context)!.caloriesPerGoal,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        
        _buildCalorieCard(
          context,
          AppLocalizations.of(context)!.maintainWeight,
          AppLocalizations.of(context)!.kcalPerDay(results.maintenanceCalories.toStringAsFixed(0)),
        ),
        
        const SizedBox(height: 8),
        
        _buildCalorieCard(
          context,
          AppLocalizations.of(context)!.loseWeight,
          AppLocalizations.of(context)!.kcalPerDay(results.weightLossCalories.toStringAsFixed(0)),
        ),
        
        const SizedBox(height: 8),
        
        _buildCalorieCard(
          context,
          AppLocalizations.of(context)!.gainMuscle,
          AppLocalizations.of(context)!.kcalPerDay(results.muscleGainCalories.toStringAsFixed(0)),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          AppLocalizations.of(context)!.classifications,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildClassificationCard(
                context,
                AppLocalizations.of(context)!.bmi,
                _getLocalizedBMICategory(results.bmiCategory, context),
                _getBMIColor(results.bmiCategory),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildClassificationCard(
                context,
                AppLocalizations.of(context)!.waistToHeight,
                _getLocalizedWaistToHeightCategory(results.waistToHeightCategory, context),
                _getWaistToHeightColor(results.waistToHeightCategory),
              ),
            ),
          ],
        ),
        

        const SizedBox(height: Constants.margin),
        GomuGomuDivider(
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: Constants.margin * 2),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.yellow[500],
                    size: 24,
                  ),
                  const SizedBox(width: Constants.margin / 2),
                  Text(
                    AppLocalizations.of(context)!.sanjiTipTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.yellow[500],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.margin),
              Text(
                AppLocalizations.of(context)!.sanjiTipText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    ),
                    
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPlateGuideButton(context),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color? color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.margin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ),
              const SizedBox(width: Constants.margin),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color?.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCard(
    BuildContext context,
    String title,
    String calories,
  ) { 
    final isUserGoal = _isUserGoal(context, title);
    final color = isUserGoal ? AppColors.yellow[500]! : Theme.of(context).colorScheme.onTertiaryContainer;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.margin),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isUserGoal) ...[
                
                Transform.rotate(
                  angle: -30 * 3.14159 / 180,
                  child: SvgPicture.asset(
                    'assets/svg/sanji-jolly-roger.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
              ),
            ],
          ),
          Text(
            calories,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  bool _isUserGoal(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    final goalMapping = {
      l10n.maintainWeight: 'maintenance',
      l10n.loseWeight: 'weight_loss',
      l10n.gainMuscle: 'muscle_gain',
    };
    
    final mappedGoal = goalMapping[title];
    return mappedGoal == results.goal;
  }

  Widget _buildClassificationCard(
    BuildContext context,
    String title,
    String classification,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.margin),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            classification,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'underweight':
        return AppColors.grey[500]!;
      case 'normalWeight':
        return AppColors.purple[500]!;
      case 'overweight':
        return AppColors.orange[600]!;
      case 'obesityGrade1':
      case 'obesityGrade2':
      case 'obesityGrade3':
        return AppColors.red[500]!;
      default:
        return AppColors.grey[500]!;
    }
  }

  Color _getWaistToHeightColor(String category) {
    switch (category) {
      case 'excellent':
        return AppColors.purple[500]!;
      case 'good':
        return AppColors.blue[500]!;
      case 'attention':
        return AppColors.yellow[600]!;
      case 'highRisk':
        return AppColors.red[500]!;
      default:
        return AppColors.grey[500]!;
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

  String _getLocalizedWaistToHeightCategory(String category, BuildContext context) {
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

  Widget _buildPlateGuideButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: AppColors.yellow[500],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.plateGuideQuestion,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.yellow[500],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.plateGuideSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.plateGuide);
              },
              icon: const Icon(Icons.visibility),
              label: Text(AppLocalizations.of(context)!.viewPlateGuide),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
