import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return placeholder ?? _buildDefaultPlaceholder();
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
          errorBuilder: errorBuilder ??
              (context, error, stackTrace) =>
                  placeholder ?? _buildDefaultPlaceholder(),
        );
      } catch (e) {
        debugPrint('UniversalImage: Failed to decode base64 - $e');
        return placeholder ?? _buildDefaultPlaceholder();
      }
    }

    // Check if it's asset path
    if (trimmedUrl.startsWith('assets/')) {
      return Image.asset(
        trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ??
            (context, error, stackTrace) =>
                placeholder ?? _buildDefaultPlaceholder(),
      );
    }

    // Otherwise, assume it's network URL
    return Image.network(
      trimmedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder ??
          (context, error, stackTrace) =>
              placeholder ?? _buildDefaultPlaceholder(),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: AppIcon(
          PhosphorIconsRegular.image,
          color: Colors.grey,
        ),
      ),
    );
  }
}
