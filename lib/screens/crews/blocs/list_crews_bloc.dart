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
    on<LoadUserCrews>(_onLoadUserCrews);
    on<SearchCrews>(_onSearchCrews);
    on<SearchUserCrews>(_onSearchUserCrews);
    on<DeleteCrew>(_onDeleteCrew);
  }

  Future<void> _onLoadCrews(
    LoadCrews event,
    Emitter<ListCrewsState> emit,
  ) async {
    emit(ListCrewsLoading());
    
    try {
      final crews = await _crewRepository.getAllCrews();
      emit(ListCrewsLoaded(crews));
    } catch (e) {
      emit(ListCrewsError(e.toString()));
    }
  }

  Future<void> _onLoadUserCrews(
    LoadUserCrews event,
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
      final allCrews = await _crewRepository.getAllCrews();
      final filteredCrews = allCrews
          .where((crew) =>
              crew.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(ListCrewsLoaded(filteredCrews));
    } catch (e) {
      emit(ListCrewsError(e.toString()));
    }
  }

  Future<void> _onSearchUserCrews(
    SearchUserCrews event,
    Emitter<ListCrewsState> emit,
  ) async {
    emit(ListCrewsLoading());

    try {
      final userCrews = await _crewRepository.getUserCrews();
      final filteredCrews = userCrews
          .where((crew) =>
              crew.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(ListCrewsLoaded(filteredCrews));
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