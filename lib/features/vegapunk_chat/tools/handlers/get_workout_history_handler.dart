import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/ai/prompts/prompt_locale.dart';
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

      // Deliberately excludes `workoutPlan` — a nested splits/exercises blob
      // unrelated to "history" questions (weight, days trained). Including
      // it bloats the tool result the on-device model has to hold in its
      // fixed context budget while formatting a reply, which is what caused
      // it to garble simple fields (a month split across two broken rows,
      // a weight value truncated mid-digit).
      final months = history.map((assessment) {
        return {
          'monthYear': assessment.monthYear,
          'weight_formatted': '${assessment.weight.toStringAsFixed(1)} kg',
          'bodyFatPercentage_formatted': assessment.bodyFatPercentage != null
              ? '${assessment.bodyFatPercentage!.toStringAsFixed(1)}%'
              : 'not set',
          'workoutDaysCount': assessment.workoutDays?.length ?? 0,
          'workoutDaysGoal': assessment.workoutDaysGoal ?? 'not set',
          'activityLevel': assessment.activityLevel ?? 'not set',
          'goal': assessment.goal ?? 'not set',
        };
      }).toList();

      final payload = {
        'note':
            'The "table" field is a ready-made Markdown table. If a table '
            'fits the question, output it verbatim, character for '
            'character — do not rebuild, retype, or reformat it yourself. '
            'For a question about a single value (e.g. one month\'s '
            'weight), just state that value from "months" in a sentence '
            'instead; do not construct a table for it.',
        'months': months,
        'table': _buildMarkdownTable(months),
      };

      return ToolResult.success(toolName: name, content: jsonEncode(payload));
    } catch (e) {
      debugPrint('GetWorkoutHistoryHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }

  /// Renders the full history as a Markdown table in Dart — not by the
  /// model — so numbers and month labels can never be mistyped when a
  /// multi-row table is actually warranted.
  static String _buildMarkdownTable(List<Map<String, dynamic>> months) {
    final isPt = PromptLocale.isPortuguese();
    final headers = isPt
        ? const [
            'Mês',
            'Peso',
            'Gordura Corporal %',
            'Dias Treinados',
            'Meta de Dias',
            'Nível de Atividade',
            'Objetivo',
          ]
        : const [
            'Month',
            'Weight',
            'Body Fat %',
            'Days Trained',
            'Days Goal',
            'Activity Level',
            'Goal',
          ];

    final buffer = StringBuffer()
      ..writeln('| ${headers.join(' | ')} |')
      ..writeln('|${headers.map((_) => '---').join('|')}|');
    for (final m in months) {
      buffer.writeln(
        '| ${m['monthYear']} | ${m['weight_formatted']} | '
        '${m['bodyFatPercentage_formatted']} | ${m['workoutDaysCount']} | '
        '${m['workoutDaysGoal']} | ${m['activityLevel']} | ${m['goal']} |',
      );
    }
    return buffer.toString().trimRight();
  }
}
