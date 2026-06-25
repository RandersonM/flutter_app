import 'package:phosphor_flutter/phosphor_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/devil_fruit.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class DevilFruitCard extends StatelessWidget {
  final DevilFruit devilFruit;
  final VoidCallback? onTap;

  const DevilFruitCard({
    Key? key,
    required this.devilFruit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Constants.margin * 2),
            gradient: _getTypeGradient(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Constants.margin),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.margin,
                          vertical: Constants.margin / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(Constants.margin),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(),
                              size: 16,
                              color: _getTypeColor(),
                            ),
                            const SizedBox(width: Constants.margin / 2),
                            Text(
                              devilFruit.type,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getTypeColor(),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Constants.margin),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(Constants.margin),
                          ),
                          child: devilFruit.filename != null &&
                                  devilFruit.filename!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(Constants.margin),
                                  child: Image.network(
                                    devilFruit.filename!,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage(context);
                                    },
                                  ),
                                )
                              : _buildPlaceholderImage(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Constants.margin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        devilFruit.romanName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Constants.margin / 2),
                      Text(
                        devilFruit.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.margin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(),
            color: Colors.white.withValues(alpha: 0.7),
            size: 32,
          ),
          const SizedBox(height: Constants.margin / 2),
          Text(
            l10n.devilFruit,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getTypeGradient() {
    switch (devilFruit.type.toLowerCase()) {
      case 'logia':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        );
      case 'paramecia':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF11998e),
            Color(0xFF38ef7d),
          ],
        );
      case 'zoan':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFf093fb),
            Color(0xFFf5576c),
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        );
    }
  }

  Color _getTypeColor() {
    switch (devilFruit.type.toLowerCase()) {
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

  IconData _getTypeIcon() {
    switch (devilFruit.type.toLowerCase()) {
      case 'logia':
        return PhosphorIconsRegular.drop;
      case 'paramecia':
        return PhosphorIconsRegular.magicWand;
      case 'zoan':
        return PhosphorIconsRegular.pawPrint;
      default:
        return PhosphorIconsRegular.question;
    }
  }
}
