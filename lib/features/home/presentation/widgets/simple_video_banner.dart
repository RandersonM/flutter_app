import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:opfan/features/youtube/data/models/youtube_video_model.dart';
import 'package:opfan/l10n/app_localizations.dart';

enum SimpleBannerType { gif, image, youtube }

// Media chrome stays dark in every theme: overlays contrast with the media.
const _mediaBackdrop = Colors.black; // harness:allow decorative
const _mediaPlaceholder = Color(0xFF212121); // harness:allow decorative
const _mediaShade = Colors.black87; // harness:allow decorative
const _onMedia = Colors.white; // harness:allow decorative
const _onMediaMuted = Colors.white70; // harness:allow decorative

class SimpleVideoBanner extends StatelessWidget {
  const SimpleVideoBanner({
    super.key,
    this.url,
    this.bannerType = SimpleBannerType.image,
    this.height = 250.0,
    this.title,
    this.subtitle,
    this.fallbackUrl,
    this.youTubeVideo,
    this.onTap,
  });

  final String? url;
  final SimpleBannerType bannerType;
  final double height;
  final String? title;
  final String? subtitle;
  final String? fallbackUrl;
  final YouTubeVideo? youTubeVideo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _mediaBackdrop,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildContent(context),
              if (title != null || subtitle != null) _buildOverlay(context),
              if (bannerType == SimpleBannerType.youtube)
                _buildPlayButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (bannerType == SimpleBannerType.youtube && youTubeVideo != null) {
      return _buildYouTubeThumbnail();
    }

    if (url != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: _mediaPlaceholder,
              child: const Center(
                child: CircularProgressIndicator(
                  color: _onMedia,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildFallback(context),
          ),
        ],
      );
    }

    return _buildFallback(context);
  }

  Widget _buildYouTubeThumbnail() {
    return CachedNetworkImage(
      imageUrl: youTubeVideo!.thumbnailUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: _mediaPlaceholder,
        child: const Center(
          child: CircularProgressIndicator(color: _onMedia, strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => _buildFallback(context),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppIcon(
          PhosphorIconsRegular.play,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (fallbackUrl != null) {
      return Container(
        decoration: BoxDecoration(
          color: _mediaPlaceholder,
          image: DecorationImage(
            image: AssetImage(fallbackUrl!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                _mediaBackdrop.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: _mediaPlaceholder,
        image: const DecorationImage(
          image: AssetImage('assets/logo/splash_logo.png'),
          fit: BoxFit.contain,
          opacity: 0.3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(
              PhosphorIconsRegular.wifiNone,
              color: _onMedia,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeBannerUnavailableTitle,
              style: const TextStyle(
                color: _onMedia,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeBannerUnavailableSubtitle,
              style: const TextStyle(color: _onMediaMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, _mediaBackdrop.withValues(alpha: 0.7)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _onMedia,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 4,
                      color: _mediaShade,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _onMedia.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: _mediaShade,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
