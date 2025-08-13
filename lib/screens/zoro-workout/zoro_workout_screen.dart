import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/screens/zoro-workout/widgets/index.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/core/models/workout_assessment_model.dart';
import 'blocs/index.dart';
import 'workout_constants.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Map<String, dynamic>? _healthResults;
  List<String> _recommendedExercises = [];
  bool _showResults = false;
  bool _isLoading = true;
  Map<String, dynamic>? _existingData;
  WorkoutAssessmentModel? _currentAssessment;

  @override
  void initState() {
    super.initState();
    _initializeAssessment();
  }

  Future<void> _initializeAssessment() async {
    final bloc = getIt.zoroWorkoutBloc;
    
    bloc.stream.listen((state) {
      if (state is ZoroWorkoutLoading) {
        setState(() {
          _isLoading = true;
        });
      } else if (state is ZoroWorkoutLoaded) {
        setState(() {
          _isLoading = false;
          _currentAssessment = state.currentAssessment;
          if (state.hasCurrentAssessment && state.currentAssessment != null) {
            final assessment = state.currentAssessment!;
            if (assessment.workoutDaysGoal != null) {
              _healthResults = assessment.toJson();
              _recommendedExercises =
                  _getRecommendedExercises(assessment.toJson());
              _showResults = true;
            }
          }
        });
      } else if (state is ZoroWorkoutError) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    
    bloc.add(const InitializeWorkoutAssessment());
  }

  void _onCalculate(Map<String, dynamic> results) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _healthResults = results;
          _recommendedExercises = _getRecommendedExercises(results);
          _showResults = true;
          _isLoading = false;
        });
      }
    });
  }

  void _onBackToSetup() {
    if (_currentAssessment != null) {
      setState(() {
        _healthResults = null;
        _recommendedExercises = [];
        _showResults = false;
        _existingData = {
          'age': _currentAssessment!.age,
          'gender': _currentAssessment!.gender,
          'weight': _currentAssessment!.weight,
          'height': _currentAssessment!.height,
          'waist': _currentAssessment!.waist,
          'workoutDaysGoal': _currentAssessment!.workoutDaysGoal,
          'workoutDays': _currentAssessment!.workoutDays,
        };
      });
    } else {
      setState(() {
        _healthResults = null;
        _recommendedExercises = [];
        _showResults = false;
        _existingData = null;
      });
    }
  }

  List<String> _getRecommendedExercises(Map<String, dynamic> results) {
    List<String> exercises = [];

    final healthScore = results['health_score'] as double? ?? 0.0;
    final bmi = results['bmi'] as double? ?? 0.0;
    final waistToHeightRatio =
        results['waist_to_height_ratio'] as double? ?? 0.0;

    final excellentThreshold =
        WorkoutConstants.healthScoreThresholds['excellent'] ?? 90.0;
    final goodThreshold =
        WorkoutConstants.healthScoreThresholds['good'] ?? 70.0;
    final regularThreshold =
        WorkoutConstants.healthScoreThresholds['regular'] ?? 50.0;
    final goodWaistThreshold =
        WorkoutConstants.waistToHeightThresholds['good'] ?? 0.5;
    final overweightBmiThreshold =
        WorkoutConstants.bmiThresholds['overweight'] ?? 25.0;
  
    if (healthScore >= excellentThreshold) {
      exercises = [
        AppLocalizations.of(context)!.workout_exercise_advanced_strength,
        AppLocalizations.of(context)!.workout_exercise_hiit,
        AppLocalizations.of(context)!.workout_exercise_competitive_sports,
        AppLocalizations.of(context)!.workout_exercise_complex_functional,
        AppLocalizations.of(context)!.workout_exercise_flexibility,
      ];
    } else if (healthScore >= goodThreshold) {
      exercises = [
        AppLocalizations.of(context)!.workout_exercise_strength_training,
        AppLocalizations.of(context)!.workout_exercise_moderate_cardio,
        AppLocalizations.of(context)!.workout_exercise_functional,
        AppLocalizations.of(context)!.workout_exercise_yoga_pilates,
        AppLocalizations.of(context)!.workout_exercise_recreational_sports,
      ];
    } else if (healthScore >= regularThreshold) {
      exercises = [
        AppLocalizations.of(context)!.workout_exercise_walking,
        AppLocalizations.of(context)!.workout_exercise_basic_strength,
        AppLocalizations.of(context)!.workout_exercise_water_aerobics,
        AppLocalizations.of(context)!.workout_exercise_stretching,
        AppLocalizations.of(context)!.workout_exercise_breathing,
      ];
    } else {
      exercises = [
        AppLocalizations.of(context)!.workout_exercise_light_walking,
        AppLocalizations.of(context)!.workout_exercise_light_stretching,
        AppLocalizations.of(context)!.workout_exercise_soft_water_aerobics,
        AppLocalizations.of(context)!.workout_exercise_tai_chi_yoga,
        AppLocalizations.of(context)!.workout_exercise_consult_professional,
      ];
    }

    if (waistToHeightRatio > goodWaistThreshold) {
      exercises.addAll([
        AppLocalizations.of(context)!.workout_exercise_cardiovascular_focus,
        AppLocalizations.of(context)!.workout_exercise_core_training,
        AppLocalizations.of(context)!.workout_exercise_diet_control,
      ]);
    }

    if (bmi > overweightBmiThreshold) {
      exercises.addAll([
        AppLocalizations.of(context)!.workout_exercise_low_impact,
        AppLocalizations.of(context)!.workout_exercise_professional_supervision,
        AppLocalizations.of(context)!.workout_exercise_gradual_progression,
      ]);
    }

    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.workout_title_screen),
      ),
      bottomNavigationBar: const BottomNavigation(BottomNavigationPages.workout),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
          child: Column(
            children: [
              WorkoutHeader(currentAssessment: _currentAssessment),
              const SizedBox(height: 20),
              if (_isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.loading),
                      
                    ],
                  ),
                )
              else if (_showResults && _healthResults != null)
                WorkoutResults(
                  healthResults: _healthResults!,
                  recommendedExercises: _recommendedExercises,
                  onBackToSetup: _onBackToSetup,
                )
              else
                WorkoutSetup(
                  onCalculate: _onCalculate,
                  existingData: _existingData,
                ),
            ],
          ),
        ),
      ),
    );
  }
}