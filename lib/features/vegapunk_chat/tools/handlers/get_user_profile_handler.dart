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
class GetUserProfileHandler extends ToolHandler {
  GetUserProfileHandler({required this._authService});

  final IAuthService _authService;

  @override
  String get name => 'getUserProfile';

  @override
  String get description =>
      'Retrieve the current user\'s personal profile (name, weight, height, age, goal, activity level).';

  @override
  String get descriptionPt =>
      'Recupera o perfil pessoal do usuário atual (nome, peso, altura, idade, objetivo, nível de atividade).';

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
