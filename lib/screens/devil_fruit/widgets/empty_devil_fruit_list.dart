// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/utils/constants.dart';

class EmptyDevilFruitList extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  const EmptyDevilFruitList({
    Key? key,
    this.hasFilters = false,
    this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.margin * 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(Constants.margin * 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.filter_list_off : Icons.sentiment_dissatisfied,
              size: 64,
              color: Colors.grey[400],
            ),
          ),

          const SizedBox(height: Constants.margin * 2),

          // Título
          Text(
            hasFilters
                ? 'Nenhuma fruta encontrada'
                : 'Nenhuma Akuma no Mi disponível',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: Constants.margin),

          // Descrição
          Text(
            hasFilters
                ? 'Tente ajustar os filtros ou buscar por outros termos'
                : 'Não há frutas do diabo para exibir no momento',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: Constants.margin * 2),

          // Botão de ação
          if (hasFilters && onClearFilters != null)
            ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Limpar Filtros'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.margin * 2,
                  vertical: Constants.margin,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.margin * 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
