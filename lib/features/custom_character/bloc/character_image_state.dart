import 'package:equatable/equatable.dart';

final class CharacterImageState extends Equatable {
  const CharacterImageState({
    this.imageUrl,
    this.isGenerating = false,
    this.failed = false,
  });

  /// The last image generated in this form, kept when a later attempt fails.
  final String? imageUrl;
  final bool isGenerating;
  final bool failed;

  @override
  List<Object?> get props => [imageUrl, isGenerating, failed];
}
