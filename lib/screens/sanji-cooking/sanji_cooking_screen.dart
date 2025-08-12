import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/screens/sanji-cooking/blocs/index.dart';
import 'package:opfan/screens/sanji-cooking/widgets/cooking_header.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/screens/sanji-cooking/widgets/nutrition_form.dart';
import 'package:opfan/screens/sanji-cooking/widgets/nutrition_results.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';

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
    _bloc.add(const NewCalculation());
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
                                Text(AppLocalizations.of(context)!.calculatingNutrition),
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
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _onNewCalculation,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(AppLocalizations.of(context)!.newCalculation),
                              ),
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
                                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _bloc.add(const InitializeSanjiCooking()),
                                  child: const Text('Tentar novamente'),
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