/// Style tokens shared across image-generation prompts (character portraits,
/// jolly rogers, ships) to avoid re-typing the same quality/style suffixes
/// in every prompt builder.
class ImagePromptStyles {
  const ImagePromptStyles._();

  static const animeStyle = 'anime style';
  static const onePieceUniverse = 'One Piece universe';
  static const onePieceStyle = 'One Piece style';
  static const highQuality = 'high quality';
  static const professionalIllustration = 'professional illustration';
  static const vibrantColors = 'vibrant colors';

  /// The trio every image prompt in this app ends with.
  static const common = [highQuality, professionalIllustration, vibrantColors];
}
