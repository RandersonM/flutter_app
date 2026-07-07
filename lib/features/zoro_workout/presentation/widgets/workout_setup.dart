import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/gender_mapper.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';
import '../../bloc/index.dart';

class WorkoutSetup extends StatefulWidget {
  final Function(Map<String, dynamic>) onCalculate;
  final Map<String, dynamic>? existingData;

  const WorkoutSetup({super.key, required this.onCalculate, this.existingData});

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
  late ZoroWorkoutBloc _bloc;
  List<int> _workoutDays = [];
  StreamSubscription<ZoroWorkoutState>? _errorSub;

  @override
  void initState() {
    super.initState();
    // Reuse the screen's existing bloc instance instead of pulling a fresh
    // one from GetIt — ZoroWorkoutBloc is a factory registration, so a
    // second `getIt.zoroWorkoutBloc` call here created an orphaned bloc
    // (redundant Firestore fetch, and a stream subscription that was never
    // canceled).
    _bloc = context.read<ZoroWorkoutBloc>();
    _errorSub = _bloc.stream.listen((state) {
      if (state is ZoroWorkoutError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fillWithExistingData();
  }

  @override
  void didUpdateWidget(WorkoutSetup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.existingData != widget.existingData) {
      _fillWithExistingData();
    }
  }

  void _fillWithExistingData() {
    if (widget.existingData != null) {
      final data = widget.existingData!;

      if (data['age'] != null) {
        _ageController.text = data['age'].toString();
      }
      if (data['weight'] != null) {
        _weightController.text = data['weight'].toString();
      }
      if (data['height'] != null) {
        _heightController.text = data['height'].toString();
      }
      if (data['waist'] != null) {
        _waistController.text = data['waist'].toString();
      }
      if (data['gender'] != null) {
        _selectedGender = GenderMapper.getLocalizedValue(
          data['gender'],
          AppLocalizations.of(context)!,
        );
      }
      if (data['workoutDaysGoal'] != null) {
        _selectedWorkoutDays = data['workoutDaysGoal'];
      }
      if (data['workoutDays'] != null) {
        _workoutDays = data['workoutDays'];
      }
    }
  }

  @override
  void dispose() {
    _errorSub?.cancel();
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
      final bodyFatPercentage = _calculateBodyFatPercentage(
        weight,
        height,
        age,
        _selectedGender!,
      );
      final healthScore = _calculateHealthScore(
        bmi,
        waistToHeightRatio,
        bodyFatPercentage,
      );

      final results = {
        'gender': GenderMapper.getInternalValue(
          _selectedGender!,
          AppLocalizations.of(context)!,
        ),
        'age': age,
        'height': height,
        'weight': weight,
        'waist': waist,
        'bmi': bmi,
        'waist_to_height_ratio': waistToHeightRatio,
        'body_fat_percentage': bodyFatPercentage,
        'health_score': healthScore,
        'workout_days_goal': _selectedWorkoutDays,
        'workout_days': _workoutDays,
      };

      _bloc.add(SaveNewAssessment(healthResults: results));

      widget.onCalculate(results);
    }
  }

  double _calculateBodyFatPercentage(
    double weight,
    double height,
    int age,
    String gender,
  ) {
    final bmi = weight / ((height / 100) * (height / 100));
    final internalGender = GenderMapper.getInternalValue(
      gender,
      AppLocalizations.of(context)!,
    );

    if (internalGender == GenderMapper.male) {
      return (1.2 * bmi) + (0.23 * age) - 16.2;
    } else {
      return (1.2 * bmi) + (0.23 * age) - 5.4;
    }
  }

  double _calculateHealthScore(
    double bmi,
    double waistToHeightRatio,
    double bodyFatPercentage,
  ) {
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.workout_health_assessment_subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormulaItem(
                'IMC',
                AppLocalizations.of(context)!.workout_formula_bmi,
              ),
              _buildFormulaItem(
                'Relação Cintura/Altura',
                AppLocalizations.of(context)!.workout_formula_waist_to_height,
              ),
              _buildFormulaItem(
                'Percentual de Gordura',
                AppLocalizations.of(context)!.workout_formula_body_fat,
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomDropdown<String>(
            value: _selectedGender,
            label: AppLocalizations.of(context)!.workout_gender,
            items: GenderMapper.getLocalizedOptions(
              AppLocalizations.of(context)!,
            ),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return AppLocalizations.of(
                  context,
                )!.workout_validation_gender_required;
              }
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
                return AppLocalizations.of(
                  context,
                )!.workout_validation_age_required;
              }
              if (int.tryParse(value) == null) {
                return AppLocalizations.of(
                  context,
                )!.workout_validation_age_invalid;
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
                return AppLocalizations.of(
                  context,
                )!.workout_validation_height_required;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(
                  context,
                )!.workout_validation_height_invalid;
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
                return AppLocalizations.of(
                  context,
                )!.workout_validation_weight_required;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(
                  context,
                )!.workout_validation_weight_invalid;
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
                return AppLocalizations.of(
                  context,
                )!.workout_validation_waist_required;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(
                  context,
                )!.workout_validation_waist_invalid;
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
              if (value == null) {
                return AppLocalizations.of(
                  context,
                )!.workout_validation_workout_days_required;
              }
              return null;
            },
            itemToString: (days) =>
                '$days ${days == 1 ? AppLocalizations.of(context)!.workout_day : AppLocalizations.of(context)!.workout_days}',
          ),
          const SizedBox(height: 20),
          AppButton(
            onPressed: _calculateHealthMetrics,
            label: AppLocalizations.of(context)!.workout_calculate_metrics,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
