import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/index.dart';

import '../models/tool_call.dart';
import '../models/tool_result.dart';
import '../tool_handler.dart';

/// [ToolHandler] that retrieves the user's workout history (assessments).
///
/// Invoked when Gemma emits:
/// ```json
/// {"name": "getWorkoutHistory", "arguments": {}}
/// ```
class GetWorkoutHistoryHandler extends ToolHandler {
  GetWorkoutHistoryHandler({required this._workoutService});

  final IWorkoutAssessmentService _workoutService;

  @override
  String get name => 'getWorkoutHistory';

  @override
  String get description =>
      'Retrieve the user\'s workout history, past training days, and fitness progress over time.';

  @override
  String get descriptionPt =>
      'Recupera o histórico de treinos do usuário, dias treinados e progresso fitness ao longo do tempo.';

  @override
  Map<String, String> get parameterDescriptions => {};

  @override
  Map<String, String> get parameterDescriptionsPt => {};

  @override
  Future<ToolResult> execute(ToolCall call) async {
    debugPrint('GetWorkoutHistoryHandler: fetching workout history');

    try {
      final history = await _workoutService.getUserAssessmentHistory();

      if (history.isEmpty) {
        return ToolResult.success(
          toolName: name,
          content: 'No workout history found for the user.',
        );
      }

      final List<Map<String, dynamic>> serializedHistory = history.map((assessment) {
        return {
          'monthYear': assessment.monthYear,
          'weight': assessment.weight,
          'bodyFatPercentage': assessment.bodyFatPercentage,
          'workoutDaysGoal': assessment.workoutDaysGoal,
          'workoutDaysCount': assessment.workoutDays?.length ?? 0,
          'activityLevel': assessment.activityLevel,
          'goal': assessment.goal,
          'workoutPlan': assessment.workoutPlan
        };
      }).toList();

      return ToolResult.success(
        toolName: name,
        content: jsonEncode(serializedHistory),
      );
    } catch (e) {
      debugPrint('GetWorkoutHistoryHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }
}
