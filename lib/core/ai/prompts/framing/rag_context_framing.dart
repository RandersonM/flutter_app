/// Wrappers injected around retrieved/contextual data before it reaches a
/// persona's chat history. Tag names stay fixed in English regardless of the
/// persona's response language — the model is taught to recognize them the
/// same way in every localized system instruction.
class RagContextFraming {
  const RagContextFraming._();

  /// For lore-immersive personas (e.g. Vegapunk): the model treats this as
  /// background it may draw on, not something to quote or repeat verbatim.
  static String loreReference(List<String>? context) {
    if (context == null || context.isEmpty) return '';
    return '[INTERNAL REFERENCE — do NOT repeat or paraphrase this; use it '
        'only if directly relevant]\n'
        '${context.map((c) => '• $c').join('\n')}\n[END REFERENCE]\n\n';
  }

  /// For factual-assistant personas (e.g. Nami): the model is expected to
  /// cite this data directly rather than treat it as optional background.
  static String factualData(List<String>? context) {
    if (context == null || context.isEmpty) return '';
    return '[AVAILABLE DATA — use this data directly to answer]\n'
        '${context.map((c) => '• $c').join('\n')}\n[END DATA]\n\n';
  }

  static String styleInstruction(String? instruction) {
    if (instruction == null || instruction.isEmpty) return '';
    return '[Style Instruction: $instruction]\n\n';
  }
}
