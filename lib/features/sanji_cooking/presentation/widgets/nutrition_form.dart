import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';
import 'package:opfan/shared/utils/gender_mapper.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';
import '../../bloc/index.dart';
import '../sanji_cooking_failure_message.dart';

class NutritionForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onCalculate;
  final Map<String, dynamic>? existingData;

  const NutritionForm({
    super.key,
    required this.onCalculate,
    this.existingData,
  });

  @override
  State<NutritionForm> createState() => _NutritionFormState();
}

class _NutritionFormState extends State<NutritionForm> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _waistController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedGoal;
  late SanjiCookingBloc _bloc;
  StreamSubscription<SanjiCookingState>? _errorSub;

  @override
  void initState() {
    super.initState();
    // Reuse the screen's existing bloc instance instead of pulling a fresh
    // one from GetIt — SanjiCookingBloc is a factory registration, so a
    // second `getIt.sanjiCookingBloc` call here created an orphaned bloc
    // (redundant work, and a stream subscription that was never canceled).
    _bloc = context.read<SanjiCookingBloc>();
    _errorSub = _bloc.stream.listen((state) {
      if (state is SanjiCookingError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                sanjiCookingFailureMessage(
                  AppLocalizations.of(context)!,
                  state.failure,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
  void didUpdateWidget(NutritionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.existingData != widget.existingData) {
      _fillWithExistingData();
    }
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _waistController.dispose();
    super.dispose();
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
      if (data['activityLevel'] != null) {
        _selectedActivityLevel = data['activityLevel'];
      }
      if (data['goal'] != null) {
        _selectedGoal = data['goal'];
      }
    }
  }

  void _calculateNutrition() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'age': int.parse(_ageController.text),
        'gender': GenderMapper.getInternalValue(
          _selectedGender!,
          AppLocalizations.of(context)!,
        ),
        'weight': double.parse(_weightController.text),
        'height': double.parse(_heightController.text),
        'waist': double.parse(_waistController.text),
        'activityLevel': _selectedActivityLevel!,
        'goal': _selectedGoal!,
      };

      _bloc.add(SaveNutritionData(nutritionData: data));

      widget.onCalculate(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.personalData,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            value: _selectedGender,
            label: AppLocalizations.of(context)!.gender,
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
                return AppLocalizations.of(context)!.selectGender;
              }
              return null;
            },
            itemToString: (gender) => gender,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _ageController,
            label: AppLocalizations.of(context)!.age,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.enterAge;
              }
              if (int.tryParse(value) == null) {
                return AppLocalizations.of(context)!.enterValidNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _weightController,
            label: AppLocalizations.of(context)!.weight,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.enterWeight;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(context)!.enterValidNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _heightController,
            label: AppLocalizations.of(context)!.height,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.enterHeight;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(context)!.enterValidNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _waistController,
            label: AppLocalizations.of(context)!.waistCircumference,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.enterWaist;
              }
              if (double.tryParse(value) == null) {
                return AppLocalizations.of(context)!.enterValidNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.activityLevel,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            value: _selectedActivityLevel,
            label: AppLocalizations.of(context)!.selectActivityLevel,
            items: NutritionOptions.activityLevels,
            onChanged: (value) {
              setState(() {
                _selectedActivityLevel = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return AppLocalizations.of(
                  context,
                )!.selectActivityLevelValidation;
              }
              return null;
            },
            itemToString: (level) =>
                _activityLevelLabel(AppLocalizations.of(context)!, level),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.goal,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            value: _selectedGoal,
            label: AppLocalizations.of(context)!.selectGoal,
            items: NutritionOptions.goals,
            onChanged: (value) {
              setState(() {
                _selectedGoal = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return AppLocalizations.of(context)!.selectGoalValidation;
              }
              return null;
            },
            itemToString: (goal) =>
                _goalLabel(AppLocalizations.of(context)!, goal),
          ),
          const SizedBox(height: 32),
          AppButton(
            onPressed: _calculateNutrition,
            label: AppLocalizations.of(context)!.calculateNutrition,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  String _activityLevelLabel(AppLocalizations l10n, String level) =>
      switch (level) {
        'sedentary' => l10n.sedentary,
        'light' => l10n.light,
        'moderate' => l10n.moderate,
        'active' => l10n.active,
        'very_active' => l10n.veryActive,
        _ => level,
      };

  String _goalLabel(AppLocalizations l10n, String goal) => switch (goal) {
    'weight_loss' => l10n.weightLoss,
    'maintenance' => l10n.maintenance,
    'muscle_gain' => l10n.muscleGain,
    _ => goal,
  };
}
