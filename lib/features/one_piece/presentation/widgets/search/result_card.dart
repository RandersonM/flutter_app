import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart';

class ResultCard extends StatefulWidget {
  const ResultCard({super.key, required this.character});

  final CustomCharacterModel character;

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool _imageLoadError = false;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ListTile(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.characterDetails,
            arguments: widget.character,
          ),
          leading: _buildAvatar(),
          title: Text(widget.character.name),
          subtitle: Text(widget.character.nickname ??
              '฿${Constants.formatBounty(widget.character.bounty)}'),
        ),
      );

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[300],
      child: _imageLoadError
          ? AppIcon(
              PhosphorIconsRegular.user,
              size: 28,
              color: Colors.grey[600],
            )
          : ClipOval(
              child: Image.network(
                widget.character.image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _imageLoadError = true;
                      });
                    }
                  });
                  return AppIcon(
                    PhosphorIconsRegular.user,
                    size: 28,
                    color: Colors.grey[600],
                  );
                },
              ),
            ),
    );
  }
}
