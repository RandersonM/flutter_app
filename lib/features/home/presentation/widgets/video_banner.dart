import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum BannerType {
  youtube,
  networkVideo,
  gif,
}

class VideoBanner extends StatefulWidget {
  const VideoBanner({
    super.key,
    required this.url,
    required this.bannerType,
    this.height = 200.0,
    this.autoPlay = true,
    this.showControls = false,
  });

  final String url;
  final BannerType bannerType;
  final double height;
  final bool autoPlay;
  final bool showControls;

  @override
  State<VideoBanner> createState() => _VideoBannerState();
}

class _VideoBannerState extends State<VideoBanner> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      switch (widget.bannerType) {
        case BannerType.youtube:
          final videoId = YoutubePlayerController.convertUrlToId(widget.url);
          if (videoId != null) {
            _youtubeController = YoutubePlayerController.fromVideoId(
              videoId: videoId,
              autoPlay: widget.autoPlay,
              params: YoutubePlayerParams(
                mute: false,
                showControls: widget.showControls,
                showFullscreenButton: false,
              ),
            );
          } else {
            setState(() {
              _hasError = true;
            });
          }
          break;
        case BannerType.networkVideo:
          _videoController =
              VideoPlayerController.networkUrl(Uri.parse(widget.url));
          await _videoController!.initialize();
          if (widget.autoPlay) {
            await _videoController!.play();
          }
          _videoController!.setLooping(true);
          break;
        case BannerType.gif:
          //TODO: GIFs são tratados como imagens animadas
          break;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    switch (widget.bannerType) {
      case BannerType.youtube:
        return _youtubeController != null
            ? YoutubePlayer(
                controller: _youtubeController!,
              )
            : _buildErrorWidget();
      case BannerType.networkVideo:
        return _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            : _buildErrorWidget();
      case BannerType.gif:
        return CachedNetworkImage(
          imageUrl: widget.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              PhosphorIconsRegular.warningCircle,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'Error loading content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
