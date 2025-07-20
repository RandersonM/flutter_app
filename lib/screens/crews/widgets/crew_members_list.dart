// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/role_icon_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/theme.dart';

class CrewMembersList extends StatelessWidget {
  final CrewModel crew;
  final Function(CrewMember)? onMemberTap;

  const CrewMembersList({
    Key? key,
    required this.crew,
    this.onMemberTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (crew.members.isEmpty) {
      return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Constants.margin * 3),
          child: Column(
            children: [
              Icon(
                Icons.group_off,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: Constants.margin),
              Text(
                'Nenhum membro na tripulação',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.margin / 2),
              Text(
                'Adicione membros para começar sua jornada!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.group,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  '${crew.members.length} ${l10n.members(crew.members.length)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: crew.members.length,
              separatorBuilder: (context, index) => const SizedBox(height: Constants.margin),
              itemBuilder: (context, index) {
                final sortedMembers = _sortMembersByRole(crew.members);
                final member = sortedMembers[index];
                return _buildMemberCard(context, member, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, CrewMember member, int index) {
    final theme = Theme.of(context);
    final roleIcon = RoleIconMapper.getIconForRole(member.role);
    final roleColor = RoleIconMapper.getColorForRole(member.role, theme.colorScheme);
    final l10n = AppLocalizations.of(context)!;


    return InkWell(
      onTap: () => onMemberTap?.call(member),
      borderRadius: BorderRadius.circular(Constants.margin),
      child: Container(
        padding: const EdgeInsets.all(Constants.margin * 1.5),
        decoration: BoxDecoration(
          color: AppColors.grey[200],
          borderRadius: BorderRadius.circular(Constants.margin * 1.5),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: roleColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  roleIcon,
                  size: 28,
                  color: roleColor,
                ),
              ),
            ),
            const SizedBox(width: Constants.margin * 1.5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (member.role != null && member.role!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          CharacterLocalizationMapper.mapOccupationToLocalized( member.role!, l10n),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                          Row(
                          children: [
                            Text(
                              _formatBounty(member.bounty),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: Constants.margin/ 4),
                            Text(
                              '฿',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: Constants.margin / 2),
                  Text(
                    _formatMemberName(member),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CrewMember> _sortMembersByRole(List<CrewMember> members) {
    return List.from(members)..sort((a, b) {
      final roleA = a.role?.toLowerCase() ?? '';
      final roleB = b.role?.toLowerCase() ?? '';
      
      // Prioridade para capitão
      if (roleA.contains('capitão') || roleA.contains('capitao') || roleA.contains('captain')) return -1;
      if (roleB.contains('capitão') || roleB.contains('capitao') || roleB.contains('captain')) return 1;
      
      // Prioridade para vice-capitão
      if (roleA.contains('vice')) return -1;
      if (roleB.contains('vice')) return 1;
      
      // Ordem alfabética para os demais
      return roleA.compareTo(roleB);
    });
  }

  String _formatMemberName(CrewMember member) {
    final nickname = member.nickname?.trim();
    final name = member.name.trim();
    
    if (nickname != null && nickname.isNotEmpty) {
      return '"$nickname" $name';
    } else {
      return name;
    }
  }

  String _formatBounty(String bounty) {
    return Constants.formatBounty(bounty);
  }
} 