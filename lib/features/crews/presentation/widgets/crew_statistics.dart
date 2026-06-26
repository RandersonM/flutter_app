import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/shared/widgets/molecules/statistics_grid.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class CrewStatistics extends StatelessWidget {
  final CrewModel crew;

  const CrewStatistics({
    super.key,
    required this.crew,
  });

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
        icon: PhosphorIconsRegular.users,
      ),
      StatisticData(
        label: l10n.berriesTotal,
        value: Constants.formatAbbreviateBounty(totalBounty),
        icon: PhosphorIconsRegular.coin,
      ),
      StatisticData(
        label: AppLocalizations.of(context)!.averageBountyLabel,
        value: Constants.formatAbbreviateBounty(double.parse(averageBounty)),
        icon: PhosphorIconsRegular.trendUp,
      ),
      StatisticData(
        label: AppLocalizations.of(context)!.rolesLabel,
        value: crew.rolesFilled.length.toString(),
        icon: PhosphorIconsRegular.briefcase,
      ),
    ];

    return StatisticsGrid(
      statistics: statistics,
      title: l10n.statistics,
      spacing: 12.0,
      padding: const EdgeInsets.all(32.0),
      borderRadius: 16.0,
      elevation: 2.0,
    );
  }

  double _calculateTotalBounty() {
    double total = 0;
    for (final member in crew.members) {
      final bounty =
          double.tryParse(member.bounty.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      total += bounty;
    }
    return total;
  }
}
