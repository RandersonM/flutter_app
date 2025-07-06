import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'list_crews_event.dart';
import 'list_crews_state.dart';

class ListCrewsBloc extends Bloc<ListCrewsEvent, ListCrewsState> {
  final CrewRepository _crewRepository;

  ListCrewsBloc({CrewRepository? crewRepository})
      : _crewRepository = crewRepository ?? CrewRepository(),
        super(ListCrewsInitial()) {
    on<LoadCrews>(_onLoadCrews);
    on<SearchCrews>(_onSearchCrews);
    on<DeleteCrew>(_onDeleteCrew);
  }

  Future<void> _onLoadCrews(
    LoadCrews event,
    Emitter<ListCrewsState> emit,
  ) async {
    emit(ListCrewsLoading());
    
    try {
      final crews = await _crewRepository.getUserCrews();
      emit(ListCrewsLoaded(crews));
    } catch (e) {
      emit(ListCrewsError(e.toString()));
    }
  }

  Future<void> _onSearchCrews(
    SearchCrews event,
    Emitter<ListCrewsState> emit,
  ) async {
    emit(ListCrewsLoading());
    
    try {
      final crews = await _crewRepository.searchCrewsByName(event.query);
      emit(ListCrewsLoaded(crews));
    } catch (e) {
      emit(ListCrewsError(e.toString()));
    }
  }

  Future<void> _onDeleteCrew(
    DeleteCrew event,
    Emitter<ListCrewsState> emit,
  ) async {
    try {
      await _crewRepository.deleteCrew(event.crewId);
      // Recarregar a lista após deletar
      add(LoadCrews());
    } catch (e) {
      emit(ListCrewsError(e.toString()));
    }
  }
} 