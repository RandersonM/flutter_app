// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/crew_list.dart';

class ListCrewsScreen extends StatelessWidget {
  const ListCrewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListCrewsBloc(),
      child: const _ListCrewsScreenContent(),
    );
  }
}

class _ListCrewsScreenContent extends StatefulWidget {
  const _ListCrewsScreenContent();

  @override
  State<_ListCrewsScreenContent> createState() =>
      _ListCrewsScreenContentState();
}

class _ListCrewsScreenContentState extends State<_ListCrewsScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
        _loadCrewsForTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCrewsForTab(int tabIndex) {
    if (tabIndex == 0) {
      // Minhas Tripulações
      context.read<ListCrewsBloc>().add(LoadUserCrews());
    } else {
      // Todas as Tripulações
      context.read<ListCrewsBloc>().add(LoadCrews());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(l10n.crew(2)),
        actions: [
          IconButton(
            onPressed: () => _navigateToCreateCrew(context),
            icon: const Icon(Icons.add),
            tooltip: l10n.createCrew,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.myCrews),
            Tab(text: l10n.allCrews),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Minhas Tripulações
          CrewList(
            onCrewTap: (crew) => _onCrewTap(context, crew),
            onCrewEdit: (crew) => _onCrewEdit(context, crew),
            onCrewDelete: (crew) => _onCrewDelete(context, crew),
            showEditDeleteButtons: (crew) =>
                _canEditCrew(crew, currentUser?.uid),
            isUserCrews: true,
            onSearch: (query) {
              if (query.isEmpty) {
                context.read<ListCrewsBloc>().add(LoadUserCrews());
              } else {
                context.read<ListCrewsBloc>().add(SearchUserCrews(query));
              }
            },
          ),
          // Tab 2: Todas as Tripulações
          CrewList(
            onCrewTap: (crew) => _onCrewTap(context, crew),
            onCrewEdit: (crew) => _onCrewEdit(context, crew),
            onCrewDelete: (crew) => _onCrewDelete(context, crew),
            showEditDeleteButtons: (crew) =>
                _canEditCrew(crew, currentUser?.uid),
            isUserCrews: false,
            onSearch: (query) {
              if (query.isEmpty) {
                context.read<ListCrewsBloc>().add(LoadCrews());
              } else {
                context.read<ListCrewsBloc>().add(SearchCrews(query));
              }
            },
          ),
        ],
      ),
    );
  }

  bool _canEditCrew(CrewModel crew, String? currentUserId) {
    return crew.userId == currentUserId;
  }

  Future<void> _navigateToCreateCrew(BuildContext context) async {
    final result = await Navigator.pushNamed(context, AppRoutes.createCrew);
    
    if (result != null &&
        result is Map<String, dynamic> &&
        result['action'] == 'created') {
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        _loadCrewsForTab(_currentTabIndex);
      }
    }
  }

  Future<void> _onCrewTap(BuildContext context, CrewModel crew) async {
    final result = await Navigator.pushNamed(context, AppRoutes.crewDetails,
        arguments: crew);

    if (result != null &&
        result is Map<String, dynamic> &&
        result['action'] == 'deleted') {
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        _loadCrewsForTab(_currentTabIndex);
      }
    }
  }

  void _onCrewEdit(BuildContext context, CrewModel crew) {
    Navigator.pushNamed(context, AppRoutes.editCrew, arguments: crew);
  }

  void _onCrewDelete(BuildContext context, CrewModel crew) {
    context.read<ListCrewsBloc>().add(DeleteCrew(crew.id!));
    _loadCrewsForTab(_currentTabIndex);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tripulação "${crew.name}" excluída'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 