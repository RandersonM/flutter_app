import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:opfan/shared/utils/constants.dart';

class CharacterInfoCard extends StatelessWidget {
  const CharacterInfoCard({
    super.key,
    this.characterName = "Monkey D. Luffy",
    this.characterBounty = "฿3,000,000,000",
    this.characterImage =
        "https://static.wikia.nocookie.net/onepiece/images/6/6d/Monkey_D._Luffy_Anime_Post_Timeskip_Infobox.png",
    this.characterDescription,
    this.onTap,
  });

  final String characterName;
  final String characterBounty;
  final String characterImage;
  final String? characterDescription;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Constants.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _buildImage(),
                    ),
                  ),
                  const SizedBox(width: Constants.margin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          characterName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(
                                PhosphorIconsRegular.coin,
                                size: 14,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                characterBounty,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIcon(
                    PhosphorIconsRegular.caretRight,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
              if (characterDescription != null &&
                  characterDescription!.isNotEmpty) ...[
                const SizedBox(height: Constants.margin),
                Divider(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh),
                const SizedBox(height: Constants.margin / 2),
                Text(
                  characterDescription!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (characterImage.startsWith('assets/')) {
      return Image.asset(
        characterImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const AppIcon(
            PhosphorIconsRegular.user,
            size: 30,
            color: Colors.grey,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: characterImage,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const AppIcon(
          PhosphorIconsRegular.user,
          size: 30,
          color: Colors.grey,
        ),
      ),
    );
  }
}
