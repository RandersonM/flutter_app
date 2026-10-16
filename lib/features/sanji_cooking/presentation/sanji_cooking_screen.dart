import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/features/sanji_cooking/presentation/sanji_cooking_failure_message.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/cooking_header.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/nutrition_form.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/nutrition_results.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/shared/widgets/organisms/offline_blocker_overlay.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

class SanjiCookingScreen extends StatelessWidget {
  const SanjiCookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<SanjiCookingBloc>()..add(const InitializeSanjiCooking()),
        ),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
      ],
      child: const _SanjiCookingView(),
    );
  }
}

class _SanjiCookingView extends StatelessWidget {
  const _SanjiCookingView();

  void _onCalculateNutrition(BuildContext context, Map<String, dynamic> data) {
    context.read<SanjiCookingBloc>().add(
      CalculateNutrition(nutritionData: data),
    );
  }

  void _onNewCalculation(BuildContext context) {
    final bloc = context.read<SanjiCookingBloc>();
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    Navigator.of(context)
        .pushNamed(AppRoutes.onboarding, arguments: user)
        .then((_) => bloc.add(const InitializeSanjiCooking()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SanjiCookingBloc, SanjiCookingState>(
      builder: (context, state) {
        return Scaffold(
          appBar: DefaultAppBar(
            title: Text(AppLocalizations.of(context)!.cookingWithSanji),
          ),
          body: OfflineBlockerOverlay(
            child: SingleChildScrollView(
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
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.calculatingNutrition,
                                ),
                              ],
                            ),
                          ),
                        ] else if (state is SanjiCookingLoaded) ...[
                          if (state.showForm) ...[
                            NutritionForm(
                              onCalculate: (data) =>
                                  _onCalculateNutrition(context, data),
                            ),
                          ] else if (state.nutritionResults != null) ...[
                            NutritionResults(results: state.nutritionResults!),
                            const SizedBox(height: 24),
                            AppButton(
                              onPressed: () => _onNewCalculation(context),
                              variant: AppButtonVariant.outline,
                              label: AppLocalizations.of(
                                context,
                              )!.updateBodyCompositionLabel,
                              isFullWidth: true,
                            ),
                          ],
                        ] else if (state is SanjiCookingFormWithData) ...[
                          NutritionForm(
                            onCalculate: (data) =>
                                _onCalculateNutrition(context, data),
                            existingData: state.existingData,
                          ),
                        ] else if (state is SanjiCookingError) ...[
                          Center(
                            child: Column(
                              children: [
                                AppIcon(
                                  PhosphorIconsRegular.warningCircle,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  sanjiCookingFailureMessage(
                                    AppLocalizations.of(context)!,
                                    state.failure,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  onPressed: () => context
                                      .read<SanjiCookingBloc>()
                                      .add(const InitializeSanjiCooking()),
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
          ),
          bottomNavigationBar: const BottomNavigation(
            BottomNavigationPages.cooking,
          ),
        );
      },
    );
  }
}
