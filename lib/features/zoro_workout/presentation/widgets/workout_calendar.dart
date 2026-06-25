import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/app/di/injection.dart';
import '../../bloc/index.dart';

class WorkoutCalendar extends StatefulWidget {
  const WorkoutCalendar({super.key});

  @override
  State<WorkoutCalendar> createState() => _WorkoutCalendarState();
}

class _WorkoutCalendarState extends State<WorkoutCalendar> {
  final Set<int> _workoutDays = <int>{};
  late DateTime _currentMonth;
  late ZoroWorkoutBloc _bloc;
  final Map<String, List<int>> _monthlyWorkoutDays = {};

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _bloc = getIt.zoroWorkoutBloc;
    _loadWorkoutDays();

    final currentState = _bloc.state;
    if (currentState is ZoroWorkoutLoaded) {
      _loadAssessmentData(currentState);
    } else {
      _bloc.add(const InitializeWorkoutAssessment());
    }
  }

  void _loadAssessmentData(ZoroWorkoutLoaded state) {
    setState(() {
      _monthlyWorkoutDays.clear();

      if (state.currentAssessment?.workoutDays != null) {
        final monthKey = state.currentAssessment!.monthYear;
        _monthlyWorkoutDays[monthKey] = state.currentAssessment!.workoutDays!;
      }

      for (final assessment in state.assessmentHistory) {
        if (assessment.workoutDays != null) {
          final monthKey = assessment.monthYear;
          _monthlyWorkoutDays[monthKey] = assessment.workoutDays!;
        }
      }

      _updateCurrentMonthDays();
    });
  }

  void _loadWorkoutDays() {
    _bloc.stream.listen((state) {
      if (state is ZoroWorkoutLoaded) {
        _loadAssessmentData(state);
      } else if (state is ZoroWorkoutError) {
        _updateCurrentMonthDays();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _updateCurrentMonthDays() {
    final monthKey =
        '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
    setState(() {
      _workoutDays.clear();
      if (_monthlyWorkoutDays.containsKey(monthKey)) {
        final days = _monthlyWorkoutDays[monthKey]!;
        _workoutDays.addAll(days);
      }
    });
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    final List<Widget> calendarDays = [];

    final adjustedFirstWeekday = firstWeekday == 7 ? 0 : firstWeekday;

    for (int i = 0; i < adjustedFirstWeekday; i++) {
      calendarDays.add(const SizedBox(height: 35));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isWorkoutDay = _workoutDays.contains(day);

      final isToday = day == DateTime.now().day &&
          _currentMonth.month == DateTime.now().month &&
          _currentMonth.year == DateTime.now().year;

      final now = DateTime.now();
      final isCurrentMonth =
          _currentMonth.month == now.month && _currentMonth.year == now.year;
      final isEditable = isCurrentMonth && day <= now.day;

      calendarDays.add(
        GestureDetector(
          onTap: isEditable
              ? () {
                  setState(() {
                    if (isWorkoutDay) {
                      _workoutDays.remove(day);
                    } else {
                      _workoutDays.add(day);
                    }
                  });

                  final monthKey =
                      '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
                  _monthlyWorkoutDays[monthKey] = _workoutDays.toList();

                  if (_isCurrentMonth()) {
                    _bloc.add(
                        UpdateWorkoutDays(workoutDays: _workoutDays.toList()));
                  }
                }
              : null,
          child: Container(
            width: 35,
            height: 35,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isWorkoutDay
                  ? Colors.green.shade600
                  : isToday
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1)
                      : isEditable
                          ? Colors.transparent
                          : AppColors.grey[700]!,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isToday
                    ? Theme.of(context).colorScheme.primary
                    : isEditable
                        ? AppColors.grey[300]!
                        : AppColors.grey[200]!,
                width: isToday ? 2 : 1,
              ),
            ),
            child: Center(
              child: isWorkoutDay
                  ? SvgPicture.asset(
                      'assets/svg/zoro-jolly-roger.svg',
                      width: 24,
                      height: 24,
                    )
                  : AppIcon(
                      PhosphorIconsRegular.barbell,
                      size: 24,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : isEditable
                              ? Theme.of(context).colorScheme.onSecondary
                              : Colors.grey.shade400,
                    ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppLocalizations.of(context)!.workout_calendar_sunday,
            AppLocalizations.of(context)!.workout_calendar_monday,
            AppLocalizations.of(context)!.workout_calendar_tuesday,
            AppLocalizations.of(context)!.workout_calendar_wednesday,
            AppLocalizations.of(context)!.workout_calendar_thursday,
            AppLocalizations.of(context)!.workout_calendar_friday,
            AppLocalizations.of(context)!.workout_calendar_saturday,
          ]
              .map((day) => SizedBox(
                    width: 35,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1.0,
          children: calendarDays,
        ),
      ],
    );
  }

  bool _isCurrentMonth() {
    return _currentMonth.month == DateTime.now().month &&
        _currentMonth.year == DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.workout_calendar_title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month - 1);
                      });
                      _updateCurrentMonthDays();
                    },
                    icon: const AppIcon(PhosphorIconsRegular.caretLeft),
                    iconSize: 20,
                  ),
                  Text(
                    '${_currentMonth.month}/${_currentMonth.year}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month + 1);
                      });
                      _updateCurrentMonthDays();
                    },
                    icon: const AppIcon(PhosphorIconsRegular.caretRight),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildCalendarGrid(context),
          if (!_isCurrentMonth()) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  AppIcon(PhosphorIconsRegular.info,
                      color: Colors.orange.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Apenas o mês atual permite edição dos dias de exercício',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade700,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
