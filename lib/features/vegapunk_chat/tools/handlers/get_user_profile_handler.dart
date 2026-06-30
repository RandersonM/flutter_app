import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/index.dart';

import '../models/tool_call.dart';
import '../models/tool_result.dart';
import '../tool_handler.dart';

/// [ToolHandler] that retrieves the current user's profile information.
///
/// Invoked when Gemma emits:
/// ```json
/// {"name": "getUserProfile", "arguments": {}}
/// ```
class GetUserProfileHandler implements ToolHandler {
  const GetUserProfileHandler({required this._authService});

  final IAuthService _authService;

  @override
  String get name => 'getUserProfile';

  @override
  String get description =>
      'MUST be called EVERY TIME the user asks for or references their personal information, profile data, or physical attributes. This includes retrieving their name, weight, height, age, gender, fitness goal, activity level, workout days, or any other data saved in their profile. Use this tool to get accurate user context before answering questions about their specific goals or stats.';

  @override
  String get descriptionPt =>
      'DEVE ser chamada SEMPRE que o usuário pedir ou fizer referência às suas informações pessoais, dados de perfil ou atributos físicos. Inclui nome, peso, altura, idade, gênero, objetivo fitness, nível de atividade, dias de treino ou quaisquer outros dados do perfil. Use para obter contexto preciso do usuário antes de responder sobre objetivos ou estatísticas específicas.';

  @override
  Map<String, String> get parameterDescriptions => {};

  @override
  Map<String, String> get parameterDescriptionsPt => {};

  @override
  Future<ToolResult> execute(ToolCall call) async {
    debugPrint('GetUserProfileHandler: fetching user profile');

    try {
      final user = _authService.currentUser;

      if (user == null) {
        return ToolResult.error(
          toolName: name,
          reason: 'User is not authenticated or profile not found.',
        );
      }

      final profileData = {
        'name': user.displayName,
        'email': user.email,
        'gender': user.gender,
        'age': user.age,
        'heightCm': user.heightCm,
        'weightKg': user.weightKg,
        'activityLevel': user.activityLevel,
        'goal': user.goal,
      };

      return ToolResult.success(
        toolName: name,
        content: jsonEncode(profileData),
      );
    } catch (e) {
      debugPrint('GetUserProfileHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }
}
