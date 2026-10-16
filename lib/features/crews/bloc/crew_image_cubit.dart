import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/one_piece/i_crew_image_service.dart';

import 'crew_image_state.dart';

class CrewImageCubit extends Cubit<CrewImageState> {
  CrewImageCubit({
    required this._crewImageService,
    String? jollyRogerUrl,
    String? boatUrl,
  }) : super(CrewImageState(jollyRogerUrl: jollyRogerUrl, boatUrl: boatUrl));

  final ICrewImageService _crewImageService;

  Future<void> generate(
    CrewImageKind kind, {
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  }) async {
    if (state.isGenerating(kind)) return;
    emit(state.copyWith(generating: {...state.generating, kind}));

    try {
      final url = await switch (kind) {
        CrewImageKind.jollyRoger => _crewImageService.generateJollyRogerImage(
          crewName: crewName,
          prompt: prompt,
          tags: tags,
          description: description,
        ),
        CrewImageKind.boat => _crewImageService.generateBoatImage(
          crewName: crewName,
          prompt: prompt,
          tags: tags,
          description: description,
        ),
      };
      if (isClosed) return;
      if (url == null) {
        emit(state.copyWith(generating: _without(kind)));
        return;
      }
      emit(
        state.copyWith(
          jollyRogerUrl: kind == CrewImageKind.jollyRoger ? url : null,
          boatUrl: kind == CrewImageKind.boat ? url : null,
          generating: _without(kind),
          outcome: CrewImageGenerated(kind),
        ),
      );
    } catch (e) {
      debugPrint('CrewImageCubit: $kind generation failed: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          generating: _without(kind),
          outcome: CrewImageGenerationFailed(kind),
        ),
      );
    }
  }

  Set<CrewImageKind> _without(CrewImageKind kind) =>
      state.generating.difference({kind});
}
