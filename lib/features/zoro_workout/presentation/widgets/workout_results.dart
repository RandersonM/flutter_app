import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/workout_assessment_model.dart';
import 'package:opfan/core/models/workout_plan_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/gender_mapper.dart';
import 'package:opfan/shared/utils/workout_plan_resolver.dart';
import '../all_recommendations_screen.dart';
import '../../bloc/zoro_workout_bloc.dart';
import '../workout_constants.dart';
import '../workout_plan_editor_screen.dart';
import 'workout_calendar.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

class WorkoutResults extends StatelessWidget {
  final Map<String, dynamic> healthResults;
  final List<Map<String, dynamic>> recommendedExercises;
  final VoidCallback onBackToSetup;
  final WorkoutAssessmentModel? currentAssessment;

  const WorkoutResults({
    super.key,
    required this.healthResults,
    required this.recommendedExercises,
    required this.onBackToSetup,
    this.currentAssessment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgressAndStreak(context),
        const SizedBox(height: Constants.margin),
        _buildNextWorkout(context),
        const SizedBox(height: Constants.margin * 2),
        Text(
          AppLocalizations.of(context)!.assessmentResultsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildCompactMetrics(context),
        const SizedBox(height: Constants.margin * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.topRecommendationsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllRecommendationsScreen(
                    exercises: recommendedExercises,
                  ),
                ),
              ),
              variant: AppButtonVariant.text,
              label: AppLocalizations.of(context)!.seeAll,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildRecommendationsRow(context),
        const SizedBox(height: Constants.margin * 2),
        const WorkoutCalendar(),
        const SizedBox(height: 30),
        AppButton(
          onPressed: onBackToSetup,
          variant: AppButtonVariant.outline,
          label: AppLocalizations.of(context)!.workout_new_assessment,
          isFullWidth: true,
        ),
      ],
    );
  }

  // ---------- Streak: soma todos os dias do mês atual no calendário ----------
  int _getMonthlyStreak() {
    final days = (healthResults['workout_days'] as List<dynamic>?)
            ?.whereType<int>()
            .toList() ??
        [];
    return days.length;
  }

  Widget _buildProgressAndStreak(BuildContext context) {
    final goal = (healthResults['workout_days_goal'] as num?)?.toInt() ?? 0;
    final days = (healthResults['workout_days'] as List<dynamic>?)
            ?.whereType<int>()
            .toList() ??
        [];

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int weekWorkouts = 0;
    for (int i = 0; i < 7; i++) {
      final weekDay = startOfWeek.add(Duration(days: i));
      if (weekDay.isBefore(now.add(const Duration(days: 1))) &&
          days.contains(weekDay.day)) {
        weekWorkouts++;
      }
    }

    final monthStreak = _getMonthlyStreak();
    final progress = goal > 0 ? (weekWorkouts / goal).clamp(0.0, 1.0) : 0.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.weekProgressTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$weekWorkouts / $goal workouts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.streakTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.thisMonthSuffix,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        '$monthStreak',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                      ),
                    ],
                  ),
                  Text(
                    AppLocalizations.of(context)!.daysSuffix,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Next Workout abre modal ----------
  Widget _buildNextWorkout(BuildContext context) {
    final split = WorkoutPlanResolver.resolveTodaySplit(currentAssessment);
    final hasPlan = currentAssessment?.workoutPlan?.isNotEmpty ?? false;
    final isDone = WorkoutPlanResolver.isTodayWorkoutDone(currentAssessment);
    final primary = Theme.of(context).colorScheme.primary;

    if (!hasPlan) {
      return GestureDetector(
        onTap: () {
          final bloc = context.read<ZoroWorkoutBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const WorkoutPlanEditorScreen(),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: AppIcon(PhosphorIconsRegular.plus, color: primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.createWorkoutPlan,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold, color: primary)),
                    const SizedBox(height: 2),
                    Text(AppLocalizations.of(context)!.createCustomPlanTap,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6))),
                  ],
                ),
              ),
              AppIcon(PhosphorIconsRegular.caretRight,
                  color: primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      );
    }

    final exercises = split?.exercises ?? [];
    final splitName =
        split?.name ?? AppLocalizations.of(context)!.defaultWorkoutName;
    final preview = exercises.take(3).map((e) => e.name).join(', ');

    return GestureDetector(
      onTap: () => _showNextWorkoutModal(context, split),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.green.withValues(alpha: 0.12)
                    : primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone
                    ? PhosphorIconsRegular.checkCircle
                    : PhosphorIconsRegular.barbell,
                color: isDone
                    ? Colors.green.shade400
                    : primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      isDone
                          ? AppLocalizations.of(context)!.todayWorkoutCompleted
                          : AppLocalizations.of(context)!.todayWorkout,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7))),
                  const SizedBox(height: 2),
                  Text(splitName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      '${AppLocalizations.of(context)!.exerciseCount(exercises.length)} • $preview',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            AppIcon(PhosphorIconsRegular.caretRight,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showNextWorkoutModal(BuildContext context, WorkoutSplitModel? split) {
    final isDone = WorkoutPlanResolver.isTodayWorkoutDone(currentAssessment);
    final bloc = context.read<ZoroWorkoutBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _NextWorkoutModal(
          primaryColor: Theme.of(context).colorScheme.primary,
          split: split,
          isDone: isDone,
          currentAssessment: currentAssessment,
        ),
      ),
    );
  }

  // ---------- Métricas compactas com parse seguro ----------
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildCompactMetrics(BuildContext context) {
    final healthScore = _parseDouble(healthResults['health_score']);
    final bmi = _parseDouble(healthResults['bmi']);
    final bodyFat = _parseDouble(healthResults['body_fat_percentage']);
    final gender = healthResults['gender']?.toString() ?? 'male';

    return Column(
      children: [
        _buildMetricBar(
          context,
          AppLocalizations.of(context)!.workout_health_score,
          '${healthScore.toStringAsFixed(0)} / 100',
          _getHealthCategory(context, healthScore),
          healthScore / 100,
          Colors.green.shade400,
        ),
        _buildMetricBar(
          context,
          AppLocalizations.of(context)!.workout_bmi,
          bmi.toStringAsFixed(1),
          _getBMICategory(context, bmi),
          (bmi - 15) / 25,
          Colors.orange.shade400,
        ),
        _buildMetricBar(
          context,
          AppLocalizations.of(context)!.workout_body_fat,
          '${bodyFat.toStringAsFixed(1)}%',
          _getBodyFatCategory(context, bodyFat, gender),
          bodyFat / 40,
          Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildMetricBar(BuildContext context, String label, String value,
      String status, double progress, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  // ---------- Recomendações horizontais com navegação ----------
  Widget _buildRecommendationsRow(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount:
            recommendedExercises.length > 3 ? 3 : recommendedExercises.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final exercise = recommendedExercises[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AllRecommendationsScreen(
                  exercises: recommendedExercises,
                ),
              ),
            ),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      exercise['icon'] as IconData? ??
                          PhosphorIconsRegular.barbell,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exercise['name'] as String? ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- Categorias ----------
  String _getBMICategory(BuildContext context, double bmi) {
    const thresholds = WorkoutConstants.bmiThresholds;
    final loc = AppLocalizations.of(context)!;
    if (bmi < thresholds['underweight']!)
      return loc.workout_category_underweight;
    if (bmi < thresholds['normal']!) return loc.workout_category_normal;
    if (bmi < thresholds['overweight']!) return loc.workout_category_overweight;
    if (bmi < thresholds['obesity_1']!) return loc.workout_category_obesity_1;
    if (bmi < thresholds['obesity_2']!) return loc.workout_category_obesity_2;
    return loc.workout_category_obesity_3;
  }

  String _getBodyFatCategory(
      BuildContext context, double percentage, String gender) {
    const maleThresholds = WorkoutConstants.bodyFatThresholdsMale;
    const femaleThresholds = WorkoutConstants.bodyFatThresholdsFemale;
    final loc = AppLocalizations.of(context)!;
    final internalGender = GenderMapper.getInternalValue(gender, loc);

    final thresholds =
        internalGender == GenderMapper.male ? maleThresholds : femaleThresholds;
    if (percentage < thresholds['very_low']!)
      return loc.workout_category_very_low;
    if (percentage < thresholds['athletic']!)
      return loc.workout_category_athletic;
    if (percentage < thresholds['good']!) return loc.workout_category_good;
    if (percentage < thresholds['acceptable']!)
      return loc.workout_category_acceptable;
    return loc.workout_category_high;
  }

  String _getHealthCategory(BuildContext context, double score) {
    const thresholds = WorkoutConstants.healthScoreThresholds;
    final loc = AppLocalizations.of(context)!;
    if (score >= thresholds['excellent']!)
      return loc.workout_category_excellent;
    if (score >= thresholds['good']!) return loc.workout_category_good;
    if (score >= thresholds['regular']!) return loc.workout_category_regular;
    return loc.workout_category_needs_improvement;
  }
}

// ============================================================
// Modal do Próximo Treino
// ============================================================
class _NextWorkoutModal extends StatelessWidget {
  final Color primaryColor;
  final WorkoutSplitModel? split;
  final bool isDone;
  final WorkoutAssessmentModel? currentAssessment;

  const _NextWorkoutModal({
    required this.primaryColor,
    this.split,
    this.isDone = false,
    this.currentAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = split?.exercises ?? [];
    final splitName =
        split?.name ?? AppLocalizations.of(context)!.defaultWorkoutName;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.withValues(alpha: 0.12)
                            : primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDone
                            ? PhosphorIconsRegular.checkCircle
                            : PhosphorIconsRegular.barbell,
                        color: isDone ? Colors.green.shade400 : primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(splitName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                              AppLocalizations.of(context)!
                                  .exerciseCount(exercises.length),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    // Badge status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.withValues(alpha: 0.12)
                            : primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          isDone
                              ? AppLocalizations.of(context)!.completedWithCheck
                              : AppLocalizations.of(context)!.today,
                          style: TextStyle(
                            color:
                                isDone ? Colors.green.shade400 : primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _InfoChip(
                        icon: PhosphorIconsRegular.arrowsClockwise,
                        label: AppLocalizations.of(context)!
                            .exerciseCount(exercises.length),
                        primaryColor: primaryColor),
                    const SizedBox(width: 8),
                    _InfoChip(
                        icon: isDone
                            ? PhosphorIconsRegular.check
                            : PhosphorIconsRegular.circle,
                        label: isDone
                            ? AppLocalizations.of(context)!.doneTodayLabel
                            : AppLocalizations.of(context)!.pendingLabel,
                        primaryColor:
                            isDone ? Colors.green.shade400 : primaryColor),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.08)),
              const SizedBox(height: 8),
              // Lista de exercícios com status
              Expanded(
                child: exercises.isEmpty
                    ? Center(
                        child: Text(
                            AppLocalizations.of(context)!.noExercisesInSplit,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5))),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: exercises.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final ex = exercises[i];
                          return Row(
                            children: [
                              // Indicador ✅ / ⬜
                              Icon(
                                isDone
                                    ? PhosphorIconsRegular.checkCircle
                                    : PhosphorIconsRegular.circle,
                                color: isDone
                                    ? Colors.green.shade400
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.3),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${i + 1}',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(ex.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isDone
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5)
                                                : null)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(ex.volume,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              // Botões rodapé
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        onPressed: () {
                          final bloc = context.read<ZoroWorkoutBloc>();
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: bloc,
                                  child: WorkoutPlanEditorScreen(
                                      existingPlan:
                                          currentAssessment?.workoutPlan),
                                ),
                              ));
                        },
                        variant: AppButtonVariant.outline,
                        icon: const AppIcon(
                            PhosphorIconsRegular.pencilSimple,
                            size: 16),
                        label: AppLocalizations.of(context)!.editPlan,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        onPressed: () => Navigator.pop(context),
                        label: isDone
                            ? AppLocalizations.of(context)!.viewProgress
                            : AppLocalizations.of(context)!.startWorkout,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        borderRadius: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primaryColor;

  const _InfoChip(
      {required this.icon, required this.label, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: primaryColor),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
