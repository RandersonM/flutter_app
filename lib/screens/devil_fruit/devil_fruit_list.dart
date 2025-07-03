// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/core/services/service_locator.dart';

import 'package:simple_app/screens/devil_fruit/blocs/index.dart';
import 'package:simple_app/screens/devil_fruit/widgets/devil_fruit_card.dart';
import 'package:simple_app/screens/devil_fruit/widgets/devil_fruit_search_header.dart';

import 'package:simple_app/screens/devil_fruit/widgets/empty_devil_fruit_list.dart';
import 'package:simple_app/utils/constants.dart';
import 'package:simple_app/widgets/molecules/default_app_bar.dart';
import 'package:simple_app/widgets/organisms/bottom_navigation.dart';

class DevilFruitListScreen extends StatefulWidget {
  const DevilFruitListScreen({super.key});

  @override
  State<DevilFruitListScreen> createState() => _DevilFruitListScreenState();
}

class _DevilFruitListScreenState extends State<DevilFruitListScreen> {
  late DevilFruitBloc _devilFruitBloc;

  @override
  void initState() {
    super.initState();
    _devilFruitBloc = DevilFruitBloc(
      devilFruitService: getIt(),
    );
    _devilFruitBloc.add(const LoadDevilFruits());
  }

  @override
  void dispose() {
    _devilFruitBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _devilFruitBloc,
      child: Scaffold(
        appBar: DefaultAppBar(
          title: Text(
            'Akuma no Mi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: [
            BlocBuilder<DevilFruitBloc, DevilFruitState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state is DevilFruitLoading
                      ? null
                      : () => _devilFruitBloc.add(const RefreshDevilFruits()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<DevilFruitBloc, DevilFruitState>(
          builder: (context, state) {
            if (state is DevilFruitInitial || state is DevilFruitLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is DevilFruitError) {
              return _buildErrorState(state.message);
            }

            if (state is DevilFruitLoaded) {
              return _buildLoadedState(state);
            }

            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: const BottomNavigation(
          BottomNavigationPages.devilFruit,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: Constants.margin * 2),
            Text(
              'Erro ao carregar Akuma no Mi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin * 2),
            ElevatedButton.icon(
              onPressed: () => _devilFruitBloc.add(const LoadDevilFruits()),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(DevilFruitLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _devilFruitBloc.add(const RefreshDevilFruits());
      },
      child: CustomScrollView(
        slivers: [
          // Header com pesquisa
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Constants.margin),
              child: DevilFruitSearchHeader(),
            ),
          ),

          // Filtros
          SliverToBoxAdapter(
            child: _buildFiltersSection(state),
          ),

          // Loading indicator para busca
          if (state.isSearching)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Constants.margin),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Lista de frutas
          if (state.filteredFruits.isEmpty && !state.isSearching)
            SliverToBoxAdapter(
              child: EmptyDevilFruitList(
                hasFilters:
                    state.searchQuery.isNotEmpty || state.selectedType != null,
                onClearFilters: () {
                  _devilFruitBloc.add(const ClearDevilFruitFilters());
                },
              ),
            )
          else if (!state.isSearching)
            SliverPadding(
              padding: const EdgeInsets.all(Constants.margin),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: Constants.margin,
                  mainAxisSpacing: Constants.margin,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final fruit = state.filteredFruits[index];
                    return DevilFruitCard(
                      devilFruit: fruit,
                      onTap: () => _showDevilFruitDetails(fruit),
                    );
                  },
                  childCount: state.filteredFruits.length,
                ),
              ),
            ),

          // Espaçamento inferior
          const SliverToBoxAdapter(
            child: SizedBox(height: Constants.margin * 2),
          ),
        ],
      ),
    );
  }

  void _showDevilFruitDetails(fruit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fruit.romanName),
        content: SingleChildScrollView(
          child: Column(
            spacing: Constants.margin / 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tipo: ${fruit.type}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox.shrink(),
              Text(
                'Descrição:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                fruit.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(DevilFruitLoaded state) {
    if (state.availableTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar por tipo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (state.selectedType != null)
                TextButton(
                  onPressed: () {
                    _devilFruitBloc.add(const ClearDevilFruitFilters());
                  },
                  child: const Text('Limpar'),
                ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.availableTypes.map((type) {
                final isSelected = state.selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: Constants.margin),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) {
                      if (isSelected) {
                        _devilFruitBloc.add(const FilterDevilFruitsByType(''));
                      } else {
                        _devilFruitBloc.add(FilterDevilFruitsByType(type));
                      }
                    },
                    selectedColor: _getTypeColor(type).withValues(alpha: 0.2),
                    checkmarkColor: _getTypeColor(type),
                    avatar: isSelected
                        ? null
                        : Icon(
                            _getTypeIcon(type),
                            size: 18,
                            color: _getTypeColor(type),
                          ),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Constants.margin * 2),
                      side: BorderSide(
                        color: isSelected
                            ? _getTypeColor(type)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: Constants.margin),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'logia':
        return const Color(0xFF667eea);
      case 'paramecia':
        return const Color(0xFF11998e);
      case 'zoan':
        return const Color(0xFFf093fb);
      default:
        return const Color(0xFF667eea);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'logia':
        return Icons.water_drop;
      case 'paramecia':
        return Icons.auto_fix_high;
      case 'zoan':
        return Icons.pets;
      default:
        return Icons.help;
    }
  }
}
