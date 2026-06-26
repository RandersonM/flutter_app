import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

class CookingTipsScreen extends StatefulWidget {
  final double? targetCalories;
  final String? goal;

  const CookingTipsScreen({
    super.key,
    this.targetCalories,
    this.goal,
  });

  @override
  State<CookingTipsScreen> createState() => _CookingTipsScreenState();
}

class _CookingTipsScreenState extends State<CookingTipsScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  String? _mealType;
  String? _dietaryRestrictions;
  late SanjiCookingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<SanjiCookingBloc>();
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _addIngredient(BuildContext context) {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      context
          .read<SanjiCookingBloc>()
          .add(AddIngredient(ingredient: ingredient));
      _ingredientController.clear();
    }
  }

  void _removeIngredient(BuildContext context, String ingredient) {
    context
        .read<SanjiCookingBloc>()
        .add(RemoveIngredient(ingredient: ingredient));
  }

  void _generatePersonalizedMeal(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentState = context.read<SanjiCookingBloc>().state;
    if (currentState is SanjiCookingTipsLoaded ||
        currentState is SanjiCookingPersonalizedMealLoaded) {
      final ingredients = currentState is SanjiCookingTipsLoaded
          ? currentState.ingredients
          : (currentState as SanjiCookingPersonalizedMealLoaded).ingredients;

      if (widget.targetCalories != null &&
          widget.goal != null &&
          _mealType != null) {
        context.read<SanjiCookingBloc>().add(GeneratePersonalizedMeal(
              ingredients: ingredients,
              mealType: _mealType!,
              targetCalories: widget.targetCalories!,
              goal: widget.goal!,
              dietaryRestrictions:
                  _dietaryRestrictions == localizations.dietaryRestrictionNone
                      ? null
                      : _dietaryRestrictions,
            ));
      }
    }
  }

  void _clearAll(BuildContext context) {
    context.read<SanjiCookingBloc>().add(const ClearCookingTips());
    setState(() {
      _mealType = null;
      _dietaryRestrictions = null;
      _ingredientController.clear();
    });
  }

  String _getLocalizedGoal(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'maintenance':
        return l10n.cookingGoalMaintenance;
      case 'weight_loss':
        return l10n.cookingGoalWeightLoss;
      case 'muscle_gain':
        return l10n.cookingGoalMuscleGain;
      default:
        return goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    final mealTypes = [
      localizations.mealTypeBreakfast,
      localizations.mealTypeMorningSnack,
      localizations.mealTypeLunch,
      localizations.mealTypeAfternoonSnack,
      localizations.mealTypeDinner,
      localizations.mealTypeDessert,
      localizations.mealTypeNightSnack,
    ];

    final dietaryRestrictionsList = [
      localizations.dietaryRestrictionNone,
      localizations.dietaryRestrictionVegetarian,
      localizations.dietaryRestrictionVegan,
      localizations.dietaryRestrictionGlutenFree,
      localizations.dietaryRestrictionLactoseFree,
      localizations.dietaryRestrictionLowCarb,
      localizations.dietaryRestrictionHighProtein,
    ];

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<SanjiCookingBloc, SanjiCookingState>(
        builder: (context, state) {
          return Scaffold(
            appBar: DefaultAppBar(
              title: Text(localizations.cookingWithSanji),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(Constants.margin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppIcon(
                                PhosphorIconsRegular.bookOpenText,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.cookingPersonalizedMealTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.cookingPersonalizedMealSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients Input
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.cookingAvailableIngredients,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _ingredientController,
                                  decoration: InputDecoration(
                                    hintText: localizations.cookingTipsHint,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onSubmitted: (_) => _addIngredient(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppButton(
                                onPressed: () => _addIngredient(context),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                label: localizations.addAction,
                              ),
                            ],
                          ),
                          if (state is SanjiCookingTipsLoaded &&
                              state.ingredients.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.ingredients.map((ingredient) {
                                return Chip(
                                  label: Text(ingredient),
                                  onDeleted: () =>
                                      _removeIngredient(context, ingredient),
                                  deleteIcon: const AppIcon(
                                      PhosphorIconsRegular.x,
                                      size: 18),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personalized Meal Section (if nutrition data is available)
                  if (widget.targetCalories != null && widget.goal != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppIcon(
                                  PhosphorIconsRegular.bookOpenText,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.cookingPersonalizedMeal,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.cookingTargetCaloriesInfo(
                                widget.targetCalories!.toStringAsFixed(0),
                                _getLocalizedGoal(localizations, widget.goal!),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Meal Type Selection
                            DropdownButtonFormField<String>(
                              initialValue: _mealType,
                              decoration: InputDecoration(
                                labelText: localizations.mealType,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: mealTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _mealType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Dietary Restrictions
                            DropdownButtonFormField<String>(
                              initialValue: _dietaryRestrictions,
                              decoration: InputDecoration(
                                labelText: localizations.dietaryRestrictions,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: dietaryRestrictionsList.map((restriction) {
                                return DropdownMenuItem(
                                  value: restriction,
                                  child: Text(restriction),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _dietaryRestrictions = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AppButton(
                        onPressed: (state is SanjiCookingTipsLoaded ||
                                    state
                                        is SanjiCookingPersonalizedMealLoaded) &&
                                (state is SanjiCookingTipsLoaded
                                    ? state.ingredients.isNotEmpty
                                    : (state
                                            as SanjiCookingPersonalizedMealLoaded)
                                        .ingredients
                                        .isNotEmpty) &&
                                _mealType != null &&
                                !(state is SanjiCookingPersonalizedMealLoaded &&
                                    state.isLoading)
                            ? () => _generatePersonalizedMeal(context)
                            : null,
                        icon:
                            const AppIcon(PhosphorIconsRegular.bookOpenText),
                        isLoading:
                            state is SanjiCookingPersonalizedMealLoaded &&
                                state.isLoading,
                        label: (state is SanjiCookingPersonalizedMealLoaded &&
                                state.isLoading)
                            ? localizations.cookingGeneratingMeal
                            : localizations.cookingGenerateMeal,
                        padding: const EdgeInsets.symmetric(
                            vertical: Constants.margin * 2,
                            horizontal: Constants.margin * 4),
                      ),
                      AppButton(
                        onPressed: () => _clearAll(context),
                        variant: AppButtonVariant.outline,
                        icon: const AppIcon(PhosphorIconsRegular.x),
                        label: localizations.clearAction,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Error Message - Personalized Meal
                  if (state is SanjiCookingPersonalizedMealLoaded &&
                      state.errorMessage != null) ...[
                    Card(
                      color: colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            AppIcon(PhosphorIconsRegular.warningCircle,
                                color: colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: TextStyle(
                                    color: colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // AI Response - Personalized Meal
                  if (state is SanjiCookingPersonalizedMealLoaded &&
                      state.personalizedMeal != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppIcon(
                                  PhosphorIconsRegular.bookOpenText,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.cookingPersonalizedRecipeTitle(
                                      state.mealType),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.targetCalories.toStringAsFixed(0)} kcal | ${_getLocalizedGoal(localizations, state.goal)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.surface.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: MarkdownBlock(
                                data: state.personalizedMeal!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
