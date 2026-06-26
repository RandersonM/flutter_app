class YouTubeVideo {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String description;

  const YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.description,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      videoId: json['id']['videoId'] ?? '',
      title: json['snippet']['title'] ?? '',
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] ??
          json['snippet']['thumbnails']['medium']['url'] ??
          json['snippet']['thumbnails']['default']['url'] ??
          '',
      channelTitle: json['snippet']['channelTitle'] ?? '',
      description: json['snippet']['description'] ?? '',
    );
  }

  String get youTubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  @override
  String toString() {
    return 'YouTubeVideo(videoId: $videoId, title: $title, channelTitle: $channelTitle)';
  }
}
