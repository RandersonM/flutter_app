import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/cooking_header.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/nutrition_form.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/nutrition_results.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

class SanjiCookingScreen extends StatefulWidget {
  const SanjiCookingScreen({super.key});

  @override
  State<SanjiCookingScreen> createState() => _SanjiCookingScreenState();
}

class _SanjiCookingScreenState extends State<SanjiCookingScreen> {
  late SanjiCookingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt.sanjiCookingBloc;
    _bloc.add(const InitializeSanjiCooking());
  }

  void _onCalculateNutrition(Map<String, dynamic> data) {
    _bloc.add(CalculateNutrition(nutritionData: data));
  }

  void _onNewCalculation() {
    final user = getIt<IAuthService>().currentUser;
    Navigator.of(context)
        .pushNamed(
      AppRoutes.onboarding,
      arguments: user,
    )
        .then((_) {
      _bloc.add(const InitializeSanjiCooking());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocBuilder<SanjiCookingBloc, SanjiCookingState>(
        builder: (context, state) {
          return Scaffold(
            appBar: DefaultAppBar(
              title: Text(AppLocalizations.of(context)!.cookingWithSanji),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const CookingHeader(),
                  Padding(
                    padding: const EdgeInsets.all(Constants.margin),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        if (state is SanjiCookingLoading) ...[
                          Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context)!
                                    .calculatingNutrition),
                              ],
                            ),
                          ),
                        ] else if (state is SanjiCookingLoaded) ...[
                          if (state.showForm) ...[
                            NutritionForm(
                              onCalculate: _onCalculateNutrition,
                            ),
                          ] else if (state.nutritionResults != null) ...[
                            NutritionResults(results: state.nutritionResults!),
                            const SizedBox(height: 24),
                            AppButton(
                              onPressed: _onNewCalculation,
                              variant: AppButtonVariant.outline,
                              label: AppLocalizations.of(context)!
                                  .updateBodyCompositionLabel,
                              isFullWidth: true,
                            ),
                          ],
                        ] else if (state is SanjiCookingFormWithData) ...[
                          NutritionForm(
                            onCalculate: _onCalculateNutrition,
                            existingData: state.existingData,
                          ),
                        ] else if (state is SanjiCookingError) ...[
                          Center(
                            child: Column(
                              children: [
                                AppIcon(
                                    PhosphorIconsRegular.warningCircle,
                                    size: 48,
                                    color: Colors.red.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  onPressed: () =>
                                      _bloc.add(const InitializeSanjiCooking()),
                                  label: AppLocalizations.of(context)!.tryAgain,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const BottomNavigation(
              BottomNavigationPages.cooking,
            ),
          );
        },
      ),
    );
  }
}
