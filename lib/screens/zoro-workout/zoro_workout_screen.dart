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
  List<Map<String, dynamic>> _recommendedExercises = [];
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

  List<Map<String, dynamic>> _getRecommendedExercises(
      Map<String, dynamic> results) {
    List<Map<String, dynamic>> exercises = [];

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
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_advanced_strength,
          'icon': Icons.fitness_center,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_hiit,
          'icon': Icons.speed,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_competitive_sports,
          'icon': Icons.sports_soccer,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_complex_functional,
          'icon': Icons.accessibility_new,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_flexibility,
          'icon': Icons.self_improvement,
        },
      ];
    } else if (healthScore >= goodThreshold) {
      exercises = [
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_strength_training,
          'icon': Icons.fitness_center,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_moderate_cardio,
          'icon': Icons.directions_run,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_functional,
          'icon': Icons.accessibility_new,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_yoga_pilates,
          'icon': Icons.self_improvement,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_recreational_sports,
          'icon': Icons.sports_basketball,
        },
      ];
    } else if (healthScore >= regularThreshold) {
      exercises = [
        {
          'name': AppLocalizations.of(context)!.workout_exercise_walking,
          'icon': Icons.directions_walk,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_basic_strength,
          'icon': Icons.fitness_center,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_water_aerobics,
          'icon': Icons.pool,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_stretching,
          'icon': Icons.accessibility_new,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_breathing,
          'icon': Icons.air,
        },
      ];
    } else {
      exercises = [
        {
          'name': AppLocalizations.of(context)!.workout_exercise_light_walking,
          'icon': Icons.directions_walk,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_light_stretching,
          'icon': Icons.accessibility_new,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_soft_water_aerobics,
          'icon': Icons.pool,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_tai_chi_yoga,
          'icon': Icons.self_improvement,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_consult_professional,
          'icon': Icons.medical_services,
        },
      ];
    }

    if (waistToHeightRatio > goodWaistThreshold) {
      exercises.addAll([
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_cardiovascular_focus,
          'icon': Icons.favorite,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_core_training,
          'icon': Icons.center_focus_strong,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_diet_control,
          'icon': Icons.restaurant_menu,
        },
      ]);
    }

    if (bmi > overweightBmiThreshold) {
      exercises.addAll([
        {
          'name': AppLocalizations.of(context)!.workout_exercise_low_impact,
          'icon': Icons.trending_down,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_professional_supervision,
          'icon': Icons.supervisor_account,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_gradual_progression,
          'icon': Icons.trending_up,
        },
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