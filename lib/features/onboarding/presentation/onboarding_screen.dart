// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/user_profile/models/body_profile.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/body_measure.dart';
import 'package:opfan/shared/utils/body_measure_validator.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _prefilled = false;
  UserModel? _initialData;

  // Step 1 - Personal Data
  String? _gender;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Step 2 - Goals & Measurements
  String? _activityLevel;
  String? _goal;

  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _armController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _thighController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs again whenever the route status changes; prefilling again would
    // wipe what the user already typed or picked.
    if (_prefilled) return;
    _prefilled = true;

    // Suporte a modo de edição via RouteSettings
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is UserModel && !_isEditing) {
      _isEditing = true;
      _initialData = args;
      _prefillData();
    } else if (!_isEditing) {
      // Se não vier do args, verifica o estado do Bloc (novo login sem perfil)
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthNeedsOnboarding) {
        _initialData = authState.user;
        _prefillData();
      } else if (authState is AuthAuthenticated) {
        _isEditing = true;
        _initialData = authState.user;
        _prefillData();
      }
    }
  }

  void _prefillData() {
    if (_initialData == null) return;

    _gender = _initialData!.gender;
    if (_initialData!.age != null) {
      _ageController.text = _initialData!.age.toString();
    }
    if (_initialData!.heightCm != null) {
      _heightController.text = _initialData!.heightCm.toString();
    }
    if (_initialData!.weightKg != null) {
      _weightController.text = _initialData!.weightKg.toString();
    }

    _activityLevel = _initialData!.activityLevel;
    _goal = _initialData!.goal;

    if (_initialData!.waistCm != null) {
      _waistController.text = _initialData!.waistCm.toString();
    }
    if (_initialData!.chestCm != null) {
      _chestController.text = _initialData!.chestCm.toString();
    }
    if (_initialData!.armCm != null) {
      _armController.text = _initialData!.armCm.toString();
    }
    if (_initialData!.hipCm != null) {
      _hipController.text = _initialData!.hipCm.toString();
    }
    if (_initialData!.thighCm != null) {
      _thighController.text = _initialData!.thighCm.toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _hipController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate() && _gender != null) {
        FocusScope.of(context).unfocus();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (_gender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.onboardingBiologicalSex,
            ),
          ),
        );
      }
    } else {
      _submitForm();
    }
  }

  UserModel? _signedInUser() => switch (context.read<AuthBloc>().state) {
    AuthNeedsOnboarding(:final user) => user,
    AuthAuthenticated(:final user) => user,
    _ => null,
  };

  void _submitForm() {
    if (_isSaving) return;
    if (_formKey2.currentState!.validate() &&
        _activityLevel != null &&
        _goal != null) {
      final user = _initialData ?? _signedInUser();
      if (user == null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        return;
      }

      // Replaced, not copied: an optional measure the user emptied is cleared.
      final updatedUser = BodyProfile(
        gender: _gender,
        age: BodyMeasure.age.parse(_ageController.text)?.toInt(),
        heightCm: BodyMeasure.heightCm.parse(_heightController.text),
        weightKg: BodyMeasure.weightKg.parse(_weightController.text),
        activityLevel: _activityLevel,
        goal: _goal,
        waistCm: BodyMeasure.waistCm.parse(_waistController.text),
        chestCm: BodyMeasure.chestCm.parse(_chestController.text),
        armCm: BodyMeasure.armCm.parse(_armController.text),
        hipCm: BodyMeasure.hipCm.parse(_hipController.text),
        thighCm: BodyMeasure.thighCm.parse(_thighController.text),
      ).replaceIn(user);

      context.read<AuthBloc>().add(
        AuthProfileBodyUpdated(updatedUser: updatedUser),
      );

      if (_isEditing) {
        Navigator.of(context).pop();
      } else {
        setState(() => _isSaving = true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.onboardingFillAllFields),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Edit mode pops right after saving, so the profile screen reports its
    // failure instead.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, state) =>
          !_isEditing &&
          (state is AuthAuthenticated || state is AuthProfileUpdateFailed),
      listener: (context, state) {
        if (state is AuthProfileUpdateFailed) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.profileUpdateFailed)));
          return;
        }
        // Under AppWrapper the root switches to Home itself.
        if (ModalRoute.of(context)?.settings.name == AppRoutes.onboarding) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing
                ? l10n.onboardingUpdateProfileTitle
                : l10n.onboardingCompleteProfileTitle,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _isEditing ? const BackButton() : const SizedBox.shrink(),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OnboardingStepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 2,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [_buildStep1(), _buildStep2()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Constants.margin * 2),
                child: AppButton(
                  label: _currentStep == 0
                      ? l10n.onboardingNext
                      : (_isEditing
                            ? l10n.onboardingSaveChanges
                            : l10n.onboardingFinish),
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                  isLoading: _isSaving,
                  onPressed: _nextStep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Constants.margin * 2),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.personalData,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.onboardingPersonalDataDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.biologicalSexLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(
                      child: Text(AppLocalizations.of(context)!.male),
                    ),
                    selected: _gender == 'male',
                    onSelected: (selected) =>
                        setState(() => _gender = selected ? 'male' : _gender),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ChoiceChip(
                    label: Center(
                      child: Text(AppLocalizations.of(context)!.female),
                    ),
                    selected: _gender == 'female',
                    onSelected: (selected) =>
                        setState(() => _gender = selected ? 'female' : _gender),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildNumberField(
              measure: BodyMeasure.age,
              controller: _ageController,
              label: AppLocalizations.of(context)!.ageLabel,
              suffix: AppLocalizations.of(context)!.onboardingAgeSuffix,
              validatorMsg: AppLocalizations.of(context)!.ageValidator,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              measure: BodyMeasure.heightCm,
              controller: _heightController,
              label: AppLocalizations.of(context)!.heightLabel,
              suffix: 'cm',
              validatorMsg: AppLocalizations.of(context)!.heightValidator,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              measure: BodyMeasure.weightKg,
              controller: _weightController,
              label: AppLocalizations.of(context)!.currentWeightLabel,
              suffix: 'kg',
              validatorMsg: AppLocalizations.of(context)!.weightValidator,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Constants.margin * 2),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.goalsAndMeasuresTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.goalsAndMeasuresSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.objectiveTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildChoiceChip(
                  'weight_loss',
                  AppLocalizations.of(context)!.goalLoseWeight,
                  _goal,
                  (v) => setState(() => _goal = v),
                ),
                _buildChoiceChip(
                  'maintenance',
                  AppLocalizations.of(context)!.goalMaintain,
                  _goal,
                  (v) => setState(() => _goal = v),
                ),
                _buildChoiceChip(
                  'muscle_gain',
                  AppLocalizations.of(context)!.goalGainMuscle,
                  _goal,
                  (v) => setState(() => _goal = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.activityLevelLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildChoiceChip(
                  'sedentary',
                  AppLocalizations.of(context)!.activitySedentary,
                  _activityLevel,
                  (v) => setState(() => _activityLevel = v),
                ),
                _buildChoiceChip(
                  'light',
                  AppLocalizations.of(context)!.activityLight,
                  _activityLevel,
                  (v) => setState(() => _activityLevel = v),
                ),
                _buildChoiceChip(
                  'moderate',
                  AppLocalizations.of(context)!.activityModerate,
                  _activityLevel,
                  (v) => setState(() => _activityLevel = v),
                ),
                _buildChoiceChip(
                  'intense',
                  AppLocalizations.of(context)!.activityIntense,
                  _activityLevel,
                  (v) => setState(() => _activityLevel = v),
                ),
                _buildChoiceChip(
                  'very_intense',
                  AppLocalizations.of(context)!.activityVeryIntense,
                  _activityLevel,
                  (v) => setState(() => _activityLevel = v),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.circumferencesLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.optionalLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    measure: BodyMeasure.waistCm,
                    controller: _waistController,
                    label: AppLocalizations.of(context)!.waistLabel,
                    suffix: 'cm',
                    isOptional: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    measure: BodyMeasure.chestCm,
                    controller: _chestController,
                    label: AppLocalizations.of(context)!.chestLabel,
                    suffix: 'cm',
                    isOptional: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    measure: BodyMeasure.armCm,
                    controller: _armController,
                    label: AppLocalizations.of(context)!.armLabel,
                    suffix: 'cm',
                    isOptional: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    measure: BodyMeasure.hipCm,
                    controller: _hipController,
                    label: AppLocalizations.of(context)!.hipLabel,
                    suffix: 'cm',
                    isOptional: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildNumberField(
                  measure: BodyMeasure.thighCm,
                  controller: _thighController,
                  label: AppLocalizations.of(context)!.thighLabel,
                  suffix: 'cm',
                  isOptional: true,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String value,
    String label,
    String? groupValue,
    ValueChanged<String> onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: groupValue == value,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
    );
  }

  Widget _buildNumberField({
    required BodyMeasure measure,
    required TextEditingController controller,
    required String label,
    required String suffix,
    bool isOptional = false,
    String? validatorMsg,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final validator = bodyMeasureValidator(
      measure,
      l10n: l10n,
      missingMessage: validatorMsg ?? l10n.onboardingInvalidValue,
      invalidMessage: l10n.onboardingInvalidValue,
    );
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: !measure.wholeNumber,
      ),
      inputFormatters: [
        measure.wholeNumber
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        alignLabelWithHint: true,
      ),
      validator: (value) =>
          isOptional && (value == null || value.trim().isEmpty)
          ? null
          : validator(value),
    );
  }
}
