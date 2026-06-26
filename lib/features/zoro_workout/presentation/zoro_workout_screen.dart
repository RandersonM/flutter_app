import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/features/zoro_workout/presentation/widgets/index.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/models/workout_assessment_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import '../bloc/index.dart';
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
  late final ZoroWorkoutBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt.zoroWorkoutBloc;
    _initializeAssessment();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _initializeAssessment() async {
    final user = getIt<IAuthService>().currentUser;

    if (user != null) {
      _existingData = {
        'age': user.age,
        'gender': user.gender,
        'weight': user.weightKg,
        'height': user.heightCm,
        'waist': user.waistCm,
      };
    }

    _bloc.stream.listen((state) {
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

    _bloc.add(const InitializeWorkoutAssessment());
  }

  void _onCalculate(Map<String, dynamic> results) {
    setState(() {
      _isLoading = true;
    });

    // Auto-save global profile when calculating
    final user = getIt<IAuthService>().currentUser;
    if (user != null) {
      final updatedUser = user.copyWith(
        gender: results['gender'] as String?,
        age: results['age'] as int?,
        heightCm: results['height'] as double?,
        weightKg: results['weight'] as double?,
        waistCm: results['waist'] as double?,
        activityLevel:
            results['activity_level'] as String? ?? user.activityLevel,
        goal: results['goal'] as String? ?? user.goal,
      );
      getIt<AuthBloc>().add(AuthProfileBodyUpdated(updatedUser: updatedUser));
    }

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
          'icon': PhosphorIconsRegular.barbell,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_hiit,
          'icon': PhosphorIconsRegular.gauge,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_competitive_sports,
          'icon': PhosphorIconsRegular.soccerBall,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_complex_functional,
          'icon': PhosphorIconsRegular.personArmsSpread,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_flexibility,
          'icon': PhosphorIconsRegular.handsPraying,
        },
      ];
    } else if (healthScore >= goodThreshold) {
      exercises = [
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_strength_training,
          'icon': PhosphorIconsRegular.barbell,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_moderate_cardio,
          'icon': PhosphorIconsRegular.sneaker,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_functional,
          'icon': PhosphorIconsRegular.personArmsSpread,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_yoga_pilates,
          'icon': PhosphorIconsRegular.handsPraying,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_recreational_sports,
          'icon': PhosphorIconsRegular.basketball,
        },
      ];
    } else if (healthScore >= regularThreshold) {
      exercises = [
        {
          'name': AppLocalizations.of(context)!.workout_exercise_walking,
          'icon': PhosphorIconsRegular.personSimpleWalk,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_basic_strength,
          'icon': PhosphorIconsRegular.barbell,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_water_aerobics,
          'icon': PhosphorIconsRegular.waves,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_stretching,
          'icon': PhosphorIconsRegular.personArmsSpread,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_breathing,
          'icon': PhosphorIconsRegular.wind,
        },
      ];
    } else {
      exercises = [
        {
          'name': AppLocalizations.of(context)!.workout_exercise_light_walking,
          'icon': PhosphorIconsRegular.personSimpleWalk,
        },
        {
          'name':
              AppLocalizations.of(context)!.workout_exercise_light_stretching,
          'icon': PhosphorIconsRegular.personArmsSpread,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_soft_water_aerobics,
          'icon': PhosphorIconsRegular.waves,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_tai_chi_yoga,
          'icon': PhosphorIconsRegular.handsPraying,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_consult_professional,
          'icon': PhosphorIconsRegular.firstAid,
        },
      ];
    }

    if (waistToHeightRatio > goodWaistThreshold) {
      exercises.addAll([
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_cardiovascular_focus,
          'icon': PhosphorIconsRegular.heart,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_core_training,
          'icon': PhosphorIconsRegular.cornersOut,
        },
        {
          'name': AppLocalizations.of(context)!.workout_exercise_diet_control,
          'icon': PhosphorIconsRegular.bookOpenText,
        },
      ]);
    }

    if (bmi > overweightBmiThreshold) {
      exercises.addAll([
        {
          'name': AppLocalizations.of(context)!.workout_exercise_low_impact,
          'icon': PhosphorIconsRegular.trendDown,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_professional_supervision,
          'icon': PhosphorIconsRegular.userList,
        },
        {
          'name': AppLocalizations.of(context)!
              .workout_exercise_gradual_progression,
          'icon': PhosphorIconsRegular.trendUp,
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
      bottomNavigationBar:
          const BottomNavigation(BottomNavigationPages.workout),
      body: BlocProvider.value(
        value: _bloc,
        child: Container(
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
                    currentAssessment: _currentAssessment,
                  )
                else
                  WorkoutSetup(
                    onCalculate: _onCalculate,
                    existingData: _existingData,
                  ),
                const SizedBox(height: Constants.margin * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
