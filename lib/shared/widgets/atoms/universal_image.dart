import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget? placeholder;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return placeholder ?? _buildDefaultPlaceholder(context);
    }

    final trimmedUrl = imageUrl!.trim();

    // Check if it's base64 data URI
    if (trimmedUrl.startsWith('data:image/') &&
        trimmedUrl.contains(';base64,')) {
      try {
        final base64Content = trimmedUrl.split(';base64,').last;
        final bytes = base64Decode(base64Content);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder:
              errorBuilder ??
              (context, error, stackTrace) =>
                  placeholder ?? _buildDefaultPlaceholder(context),
        );
      } catch (e) {
        debugPrint('UniversalImage: Failed to decode base64 - $e');
        return placeholder ?? _buildDefaultPlaceholder(context);
      }
    }

    // Check if it's asset path
    if (trimmedUrl.startsWith('assets/')) {
      return Image.asset(
        trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder:
            errorBuilder ??
            (context, error, stackTrace) =>
                placeholder ?? _buildDefaultPlaceholder(context),
      );
    }

    // Otherwise, assume it's network URL
    return Image.network(
      trimmedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: loadingBuilder,
      errorBuilder:
          errorBuilder ??
          (context, error, stackTrace) =>
              placeholder ?? _buildDefaultPlaceholder(context),
    );
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: width,
      height: height,
      color: onSurface.withValues(alpha: 0.12),
      child: Center(
        child: AppIcon(
          PhosphorIconsRegular.image,
          color: onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
