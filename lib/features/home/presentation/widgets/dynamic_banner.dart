// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/home/bloc/index.dart';
import 'package:opfan/features/home/presentation/widgets/simple_video_banner.dart';
import 'package:opfan/features/home/presentation/widgets/inline_youtube_player.dart';

// Stands in for the video banner, so it keeps the dark media chrome in every theme.
const _mediaPlaceholder = Color(0xFF212121); // harness:allow decorative
const _onMedia = Colors.white; // harness:allow decorative

class DynamicBanner extends StatelessWidget {
  final HomeState state;
  final double height;

  const DynamicBanner({super.key, required this.state, this.height = 250.0});

  @override
  Widget build(BuildContext context) {
    if (state is HomeLoaded) {
      final homeState = state as HomeLoaded;
      final character = homeState.featuredCharacter;

      if (homeState.isPlayingVideo && homeState.currentVideo != null) {
        return InlineYouTubePlayer(
          video: homeState.currentVideo!,
          height: height,
          onClose: () {
            context.read<HomeBloc>().add(const StopVideoInline());
          },
        );
      }

      if (homeState.currentVideo != null) {
        return SimpleVideoBanner(
          bannerType: SimpleBannerType.youtube,
          youTubeVideo: homeState.currentVideo,
          height: height,
          title: character.name,
          subtitle: homeState.currentVideo!.title,
          onTap: () {
            context.read<HomeBloc>().add(const PlayVideoInline());
          },
        );
      }

      if (homeState.isLoadingVideo) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: _mediaPlaceholder,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: _onMedia),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.searchingVideo,
                  style: const TextStyle(color: _onMedia),
                ),
              ],
            ),
          ),
        );
      }

      return SimpleVideoBanner(
        url: character.image,
        fallbackUrl: 'assets/logo/splash_logo.png',
        bannerType: SimpleBannerType.image,
        height: 200,
        title: character.name,
        subtitle: AppLocalizations.of(context)!.featuredCharacter,
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
