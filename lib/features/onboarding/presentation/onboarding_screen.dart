// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
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
              content:
                  Text(AppLocalizations.of(context)!.onboardingBiologicalSex)),
        );
      }
    } else {
      _submitForm();
    }
  }

  void _submitForm() {
    if (_formKey2.currentState!.validate() &&
        _activityLevel != null &&
        _goal != null) {
      final user = _initialData ??
          context.read<AuthBloc>().state.props.first as UserModel;

      final updatedUser = user.copyWith(
        gender: _gender,
        age: int.tryParse(_ageController.text),
        heightCm: double.tryParse(_heightController.text),
        weightKg: double.tryParse(_weightController.text),
        activityLevel: _activityLevel,
        goal: _goal,
        waistCm: double.tryParse(_waistController.text),
        chestCm: double.tryParse(_chestController.text),
        armCm: double.tryParse(_armController.text),
        hipCm: double.tryParse(_hipController.text),
        thighCm: double.tryParse(_thighController.text),
      );

      context
          .read<AuthBloc>()
          .add(AuthProfileBodyUpdated(updatedUser: updatedUser));

      if (_isEditing) {
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.onboardingFillAllFields)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Atualizar Perfil' : 'Complete seu Perfil'),
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
                children: [
                  _buildStep1(),
                  _buildStep2(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Constants.margin * 2),
              child: AppButton(
                label: _currentStep == 0
                    ? 'Próximo'
                    : (_isEditing ? 'Salvar Alterações' : 'Concluir Cadastro'),
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                onPressed: _nextStep,
              ),
            ),
          ],
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
              'Dados Pessoais',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essas informações são essenciais para calcularmos seu plano nutricional de forma precisa.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 32),
            Text(AppLocalizations.of(context)!.biologicalSexLabel,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label:
                        Center(child: Text(AppLocalizations.of(context)!.male)),
                    selected: _gender == 'male',
                    onSelected: (selected) =>
                        setState(() => _gender = selected ? 'male' : _gender),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ChoiceChip(
                    label: Center(
                        child: Text(AppLocalizations.of(context)!.female)),
                    selected: _gender == 'female',
                    onSelected: (selected) =>
                        setState(() => _gender = selected ? 'female' : _gender),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildNumberField(
              controller: _ageController,
              label: AppLocalizations.of(context)!.ageLabel,
              suffix: 'anos',
              validatorMsg: AppLocalizations.of(context)!.ageValidator,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _heightController,
              label: AppLocalizations.of(context)!.heightLabel,
              suffix: 'cm',
              validatorMsg: AppLocalizations.of(context)!.heightValidator,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.goalsAndMeasuresSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 32),
            Text(AppLocalizations.of(context)!.objectiveTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildChoiceChip(
                    'lose_weight',
                    AppLocalizations.of(context)!.goalLoseWeight,
                    _goal,
                    (v) => setState(() => _goal = v)),
                _buildChoiceChip(
                    'maintain',
                    AppLocalizations.of(context)!.goalMaintain,
                    _goal,
                    (v) => setState(() => _goal = v)),
                _buildChoiceChip(
                    'gain_muscle',
                    AppLocalizations.of(context)!.goalGainMuscle,
                    _goal,
                    (v) => setState(() => _goal = v)),
              ],
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.activityLevelLabel,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildChoiceChip(
                    'sedentary',
                    AppLocalizations.of(context)!.activitySedentary,
                    _activityLevel,
                    (v) => setState(() => _activityLevel = v)),
                _buildChoiceChip(
                    'light',
                    AppLocalizations.of(context)!.activityLight,
                    _activityLevel,
                    (v) => setState(() => _activityLevel = v)),
                _buildChoiceChip(
                    'moderate',
                    AppLocalizations.of(context)!.activityModerate,
                    _activityLevel,
                    (v) => setState(() => _activityLevel = v)),
                _buildChoiceChip(
                    'intense',
                    AppLocalizations.of(context)!.activityIntense,
                    _activityLevel,
                    (v) => setState(() => _activityLevel = v)),
                _buildChoiceChip(
                    'very_intense',
                    AppLocalizations.of(context)!.activityVeryIntense,
                    _activityLevel,
                    (v) => setState(() => _activityLevel = v)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.circumferencesLabel,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(AppLocalizations.of(context)!.optionalLabel,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildNumberField(
                        controller: _waistController,
                        label: AppLocalizations.of(context)!.waistLabel,
                        suffix: 'cm',
                        isOptional: true)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildNumberField(
                        controller: _chestController,
                        label: AppLocalizations.of(context)!.chestLabel,
                        suffix: 'cm',
                        isOptional: true)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildNumberField(
                        controller: _armController,
                        label: AppLocalizations.of(context)!.armLabel,
                        suffix: 'cm',
                        isOptional: true)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildNumberField(
                        controller: _hipController,
                        label: AppLocalizations.of(context)!.hipLabel,
                        suffix: 'cm',
                        isOptional: true)),
              ],
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildNumberField(
                    controller: _thighController,
                    label: AppLocalizations.of(context)!.thighLabel,
                    suffix: 'cm',
                    isOptional: true),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String value, String label, String? groupValue,
      ValueChanged<String> onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: groupValue == value,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    bool isOptional = false,
    String? validatorMsg,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (isOptional) return null;
        if (value == null || value.isEmpty) return validatorMsg;
        if (double.tryParse(value) == null) return 'Valor inválido';
        return null;
      },
    );
  }
}
