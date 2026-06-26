
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/index.dart';

import '../models/tool_call.dart';
import '../models/tool_result.dart';
import '../tool_handler.dart';

/// [ToolHandler] that saves a workout session for the user for today.
///
/// Invoked when Gemma emits:
/// ```json
/// {"name": "saveWorkout", "arguments": {}}
/// ```
class SaveWorkoutHandler implements ToolHandler {
  const SaveWorkoutHandler({required this._workoutService});

  final IWorkoutAssessmentService _workoutService;

  @override
  String get name => 'saveWorkout';

  @override
  String get description =>
      'Save a workout session for the user for today. Use this when the user says they have completed a workout.';

  @override
  Map<String, String> get parameterDescriptions => {};

  @override
  Future<ToolResult> execute(ToolCall call) async {
    debugPrint('SaveWorkoutHandler: saving workout session');

    try {
      final currentAssessment = await _workoutService.getCurrentUserAssessment();
      
      if (currentAssessment == null) {
        return ToolResult.error(
          toolName: name,
          reason: 'No active workout assessment found for the current month. The user needs to setup their workout goal first.',
        );
      }

      final today = DateTime.now().day;
      final currentDays = List<int>.from(currentAssessment.workoutDays ?? []);

      if (currentDays.contains(today)) {
        return ToolResult.success(
          toolName: name,
          content: 'A workout session for today was already recorded.',
        );
      }

      currentDays.add(today);
      await _workoutService.updateWorkoutDays(currentDays);

      return ToolResult.success(
        toolName: name,
        content: 'Workout session saved successfully for today. Total workouts this month: ${currentDays.length}.',
      );
    } catch (e) {
      debugPrint('SaveWorkoutHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }
}
