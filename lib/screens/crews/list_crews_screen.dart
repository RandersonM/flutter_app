// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/screens/crews/blocs/index.dart';
import 'package:opfan/utils/app_routes.dart';

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
      ), 
    );
  }

  Future<void> _navigateToCreateCrew(BuildContext context) async {
    final result = await Navigator.pushNamed(context, AppRoutes.createCrew);
    
    // Se uma nova tripulação foi criada, recarregar a lista
    if (result != null && result is Map<String, dynamic> && result['action'] == 'created') {
      // Aguardar um pouco para garantir que os dados foram salvos
      await Future.delayed(const Duration(milliseconds: 500));
      // Recarregar a lista de tripulações
      if (context.mounted) {
        context.read<ListCrewsBloc>().add(LoadCrews());
      }
    }
  }

  void _onCrewTap(BuildContext context, CrewModel crew) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implementar navegação para detalhes da tripulação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.viewingCrew(crew.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCrewEdit(BuildContext context, CrewModel crew) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implementar navegação para edição da tripulação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.editingCrew(crew.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 