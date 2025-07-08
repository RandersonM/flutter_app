// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/widgets/molecules/statistics_grid.dart';
import 'package:opfan/l10n/app_localizations.dart';

class CrewStatistics extends StatelessWidget {
  final CrewModel crew;

  const CrewStatistics({
    Key? key,
    required this.crew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final totalBounty = _calculateTotalBounty();
    final averageBounty = crew.members.isNotEmpty 
        ? (totalBounty / crew.members.length).toStringAsFixed(0)
        : '0';

    final statistics = [
      StatisticData(
        label: l10n.members(crew.members.length),
        value: crew.members.length.toString(),
        icon: Icons.group,
      ),
      StatisticData(
        label: l10n.berriesTotal,
        value: _formatBounty(totalBounty),
        icon: Icons.monetization_on,
      ),
      StatisticData(
        label: 'Bounty Média',
        value: _formatBounty(double.parse(averageBounty)),
        icon: Icons.trending_up,
      ),
      StatisticData(
        label: 'Funções',
        value: crew.rolesFilled.length.toString(),
        icon: Icons.work,
      ),
    ];

    return 
      
      StatisticsGrid(
        statistics: statistics,
        title: l10n.statistics,
        spacing: 12.0,
        padding: const EdgeInsets.all(32.0),
        backgroundColor: Colors.white,
        borderRadius: 16.0,
        elevation: 2.0,
      
    );
  }

  double _calculateTotalBounty() {
    double total = 0;
    for (final member in crew.members) {
      final bounty = double.tryParse(member.bounty.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      total += bounty;
    }
    return total;
  }

  String _formatBounty(double bounty) {
    if (bounty >= 1000000000) {
      return '${(bounty / 1000000000).toStringAsFixed(1)}B';
    } else if (bounty >= 1000000) {
      return '${(bounty / 1000000).toStringAsFixed(1)}M';
    } else if (bounty >= 1000) {
      return '${(bounty / 1000).toStringAsFixed(1)}K';
    } else {
      return bounty.toStringAsFixed(0);
    }
  }
} 