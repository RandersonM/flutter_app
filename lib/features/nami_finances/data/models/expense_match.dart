/// A semantic hit from the finances index, pointing at one saved expense.
///
/// Deliberately carries **no monetary value**: the amount is read back from the
/// stored [ExpenseModel] and summed in Dart. Retrieval only answers "which
/// records is the user talking about" — never "how much", because vector
/// similarity is approximate and money has to be exact.
class ExpenseMatch {
  const ExpenseMatch({
    required this.expenseId,
    required this.monthKey,
    required this.similarity,
  });

  final String expenseId;

  /// `YYYY-MM` of the month document this expense belongs to, used to load the
  /// record back without scanning every month.
  final String monthKey;

  /// Cosine similarity reported by the vector store, 0..1.
  final double similarity;

  @override
  String toString() =>
      'ExpenseMatch($expenseId, $monthKey, ${similarity.toStringAsFixed(3)})';
}
