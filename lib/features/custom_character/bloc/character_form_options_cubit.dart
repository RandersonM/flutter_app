import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/one_piece/i_devil_fruit_service.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

import 'character_form_options_state.dart';

class CharacterFormOptionsCubit extends Cubit<CharacterFormOptionsState> {
  CharacterFormOptionsCubit({
    required this._devilFruitService,
    required this._crewRepository,
  }) : super(const CharacterFormOptionsState());

  final IDevilFruitService _devilFruitService;
  final ICrewRepository _crewRepository;

  /// Each list falls back to empty on failure so the form stays usable.
  Future<void> load() async {
    final (devilFruits, crews) = await (_loadDevilFruits(), _loadCrews()).wait;
    if (isClosed) return;
    emit(
      CharacterFormOptionsState(
        devilFruits: devilFruits,
        crews: crews,
        isLoaded: true,
      ),
    );
  }

  Future<List<DevilFruit>> _loadDevilFruits() async {
    try {
      return await _devilFruitService.fetchAll();
    } catch (e) {
      debugPrint('CharacterFormOptionsCubit: devil fruits failed: $e');
      return const [];
    }
  }

  Future<List<CrewModel>> _loadCrews() async {
    try {
      return await _crewRepository.getUserCrews();
    } catch (e) {
      debugPrint('CharacterFormOptionsCubit: crews failed: $e');
      return const [];
    }
  }
}
