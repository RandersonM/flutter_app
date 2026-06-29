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
class GetWorkoutHistoryHandler implements ToolHandler {
  const GetWorkoutHistoryHandler({required this._workoutService});

  final IWorkoutAssessmentService _workoutService;

  @override
  String get name => 'getWorkoutHistory';

  @override
  String get description =>
      'Retrieve the user\'s comprehensive workout history and assessment data. Use this tool when asked about the user\'s workout plan or routine, how many days they have trained, which specific days they trained in a given month, body metric history over time (weight, body fat), activity level, and their fitness goals.';

  @override
  String get descriptionPt =>
      'Recupere o histórico completo de treinos e dados de avaliação do usuário. Use esta ferramenta quando perguntado sobre o plano ou rotina de treino, quantos dias treinou, quais dias específicos treinou em um mês, histórico de métricas corporais (peso, gordura), nível de atividade e objetivos fitness.';

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
