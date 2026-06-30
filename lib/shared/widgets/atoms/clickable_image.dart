import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/shared/widgets/atoms/universal_image.dart';

class ClickableImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final String? title;
  final bool showTitleInDialog;
  final bool enableClick;

  const ClickableImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height = 300,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.boxShadow,
    this.title,
    this.showTitleInDialog = true,
    this.enableClick = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget imageWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: UniversalImage(
          imageUrl: imageUrl,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      PhosphorIconsRegular.warningCircle,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Erro ao carregar imagem',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (!enableClick) {
      return imageWidget;
    }

    return GestureDetector(
      onTap: () => _showImageDialog(context),
      child: imageWidget,
    );
  }

  void _showImageDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InteractiveViewer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: UniversalImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.transparent,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const AppIcon(
                                      PhosphorIconsRegular.warningCircle,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Erro ao carregar imagem',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon(
                      PhosphorIconsRegular.x,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              if (title != null && title!.isNotEmpty && showTitleInDialog)
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      title!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
