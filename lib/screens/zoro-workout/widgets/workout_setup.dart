import 'package:flutter/material.dart';
import 'package:opfan/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/widgets/atoms/custom_text_field.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/services/service_locator.dart';
import '../blocs/index.dart';

class WorkoutSetup extends StatefulWidget {
  final Function(Map<String, dynamic>) onCalculate;

  const WorkoutSetup({
    super.key,
    required this.onCalculate,
  });

  @override
  State<WorkoutSetup> createState() => _WorkoutSetupState();
}

class _WorkoutSetupState extends State<WorkoutSetup> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  int? _selectedWorkoutDays;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculateHealthMetrics() async {
    if (_formKey.currentState!.validate()) {
      final height = double.parse(_heightController.text);
      final weight = double.parse(_weightController.text);
      final waist = double.parse(_waistController.text);
      final age = int.parse(_ageController.text);

      final bmi = weight / ((height / 100) * (height / 100));
      final waistToHeightRatio = waist / height;
      final bodyFatPercentage =
          _calculateBodyFatPercentage(weight, height, age, _selectedGender!);
      final healthScore =
          _calculateHealthScore(bmi, waistToHeightRatio, bodyFatPercentage);

      final results = {
        'bmi': bmi,
        'waistToHeightRatio': waistToHeightRatio,
        'bodyFatPercentage': bodyFatPercentage,
        'healthScore': healthScore,
        'workoutDaysGoal': _selectedWorkoutDays,
      };

      final bloc = getIt.zoroWorkoutBloc;
      bloc.add(SaveNewAssessment(
        healthResults: results,
        workoutDaysGoal: _selectedWorkoutDays ?? 0,
      ));

      widget.onCalculate(results);
    }
  }

  double _calculateBodyFatPercentage(
      double weight, double height, int age, String gender) {
    final bmi = weight / ((height / 100) * (height / 100));

    if (gender == 'Masculino') {
      return (1.2 * bmi) + (0.23 * age) - 16.2;
    } else {
      return (1.2 * bmi) + (0.23 * age) - 5.4;
    }
  }

  double _calculateHealthScore(
      double bmi, double waistToHeightRatio, double bodyFatPercentage) {
    double score = 100;

    if (bmi < 18.5 || bmi > 30) {
      score -= 20;
    } else if (bmi < 25) {
      score += 10;
    }

    if (waistToHeightRatio > 0.5) {
      score -= 25;
    } else if (waistToHeightRatio < 0.4) {
      score += 15;
    }

    if (bodyFatPercentage > 25 || bodyFatPercentage < 8) {
      score -= 20;
    } else if (bodyFatPercentage >= 10 && bodyFatPercentage <= 20) {
      score += 15;
    }

    return score.clamp(0, 100);
  }


  Widget _buildFormulaItem(String title, String formula) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          Expanded(
            child: Text(
              formula,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.workout_health_assessment,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.workout_health_assessment_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormulaItem('IMC', AppLocalizations.of(context)!.workout_formula_bmi),
              _buildFormulaItem('Relação Cintura/Altura',
                  AppLocalizations.of(context)!.workout_formula_waist_to_height),
              _buildFormulaItem('Percentual de Gordura',
                  AppLocalizations.of(context)!.workout_formula_body_fat),
            ],
          ),
          const SizedBox(height: 20),

          CustomDropdown<String>(
            value: _selectedGender,
            label: AppLocalizations.of(context)!.workout_gender,
            items: [
              AppLocalizations.of(context)!.workout_gender_male,
              AppLocalizations.of(context)!.workout_gender_female,
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) {
              if (value == null) return AppLocalizations.of(context)!.workout_validation_gender_required;
              return null;
            },
            itemToString: (status) => status,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _ageController,
            label: AppLocalizations.of(context)!.workout_age,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.workout_validation_age_required;
              }
              if (int.tryParse(value) == null) {
                return AppLocalizations.of(context)!.workout_validation_age_invalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _heightController,
            label: AppLocalizations.of(context)!.workout_height,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.workout_validation_height_required;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(context)!.workout_validation_height_invalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _weightController,
            label: AppLocalizations.of(context)!.workout_weight,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.workout_validation_weight_required;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(context)!.workout_validation_weight_invalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _waistController,
            label: AppLocalizations.of(context)!.workout_waist,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.workout_validation_waist_required;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(context)!.workout_validation_waist_invalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomDropdown<int>(
            value: _selectedWorkoutDays,
            label: AppLocalizations.of(context)!.workout_workout_days_goal,
            items: const [1, 2, 3, 4, 5, 6, 7],
            onChanged: (value) {
              setState(() {
                _selectedWorkoutDays = value;
              });
            },
            validator: (value) {
              if (value == null) return AppLocalizations.of(context)!.workout_validation_workout_days_required;
              return null;
            },
            itemToString: (days) => '$days ${days == 1 ? AppLocalizations.of(context)!.workout_day : AppLocalizations.of(context)!.workout_days}',
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculateHealthMetrics,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.workout_calculate_metrics),
            ),
          ),
        ],
      ),
    );
  }
}
