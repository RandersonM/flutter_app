import 'package:equatable/equatable.dart';

enum CrewImageKind { jollyRoger, boat }

final class CrewImageState extends Equatable {
  const CrewImageState({
    this.jollyRogerUrl,
    this.boatUrl,
    this.generating = const {},
    this.outcome,
  });

  final String? jollyRogerUrl;
  final String? boatUrl;
  final Set<CrewImageKind> generating;

  /// One-shot result of the last generation, for the success/error snackbar.
  final CrewImageOutcome? outcome;

  bool isGenerating(CrewImageKind kind) => generating.contains(kind);

  CrewImageState copyWith({
    String? jollyRogerUrl,
    String? boatUrl,
    Set<CrewImageKind>? generating,
    CrewImageOutcome? outcome,
  }) {
    return CrewImageState(
      jollyRogerUrl: jollyRogerUrl ?? this.jollyRogerUrl,
      boatUrl: boatUrl ?? this.boatUrl,
      generating: generating ?? this.generating,
      outcome: outcome,
    );
  }

  @override
  List<Object?> get props => [jollyRogerUrl, boatUrl, generating, outcome];
}

sealed class CrewImageOutcome extends Equatable {
  const CrewImageOutcome(this.kind);

  final CrewImageKind kind;

  @override
  List<Object?> get props => [kind];
}

final class CrewImageGenerated extends CrewImageOutcome {
  const CrewImageGenerated(super.kind);
}

final class CrewImageGenerationFailed extends CrewImageOutcome {
  const CrewImageGenerationFailed(super.kind);
}
