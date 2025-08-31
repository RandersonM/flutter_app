// Developed by Randerson Mayllon
// Copyright © 2022.

class Constants {
  // Default margin: 8.0
  static const double margin = 8.0;
  static const double iconSize = 24.0;

  // Array of button
  static final List<String> calculatorButtons = [
    'C',
    'X^2',
    '%',
    'DEL',
    '7',
    '8',
    '9',
    '/',
    '4',
    '5',
    '6',
    'x',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
  ];

  static String formatAbbreviateBounty(double bounty) {
    if (bounty >= 1000000000) {
      return '${(bounty / 1000000000).toStringAsFixed(1)}B';
    } else if (bounty >= 1000000) {
      return '${(bounty / 1000000).toStringAsFixed(1)}M';
    } else if (bounty >= 1000) {
      return '${(bounty / 1000).toStringAsFixed(1)}K';
    } else {
      return bounty.toStringAsFixed(0);
    }
  }

  /// Formats bounty value with currency mask
  /// Examples: 1000 -> 1,000 | 1000000 -> 1,000,000 | 1000000000 -> 1,000,000,000
  static String formatBounty(String bounty) {
    // Remove any non-digit characters and convert to int
    final cleanBounty = bounty.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanBounty.isEmpty) return '0';

    final number = int.tryParse(cleanBounty) ?? 0;

    // Format with commas for thousands separators
    final formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );

    return formatted;
  }
}
