// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/screens/crews/blocs/index.dart';
import 'package:opfan/utils/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/crew_list.dart';

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

class _ListCrewsScreenContent extends StatelessWidget {
  const _ListCrewsScreenContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(l10n.myCrews),
        actions: [
          IconButton(
            onPressed: () => _navigateToCreateCrew(context),
            icon: const Icon(Icons.add),
            tooltip: l10n.createCrew,
          ),
        ],
      ),
      body: CrewList(
        onCrewTap: (crew) => _onCrewTap(context, crew),
        onCrewEdit: (crew) => _onCrewEdit(context, crew),
        onCrewDelete: (crew) => _onCrewDelete(context, crew),
        showEditDeleteButtons: (crew) => _canEditCrew(crew, currentUser?.uid),
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
        context.read<ListCrewsBloc>().add(LoadCrews());
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
        context.read<ListCrewsBloc>().add(LoadCrews());
      }
    }
  }

  void _onCrewEdit(BuildContext context, CrewModel crew) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.editingCrew(crew.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCrewDelete(BuildContext context, CrewModel crew) {
    context.read<ListCrewsBloc>().add(DeleteCrew(crew.id!));
    context.read<ListCrewsBloc>().add(LoadCrews());
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tripulação "${crew.name}" excluída'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 