import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';

class FinancialResults extends StatelessWidget {
  final double totalExpenses;
  final double availableAmount;
  final double dailyAmount;

  const FinancialResults({
    Key? key,
    required this.totalExpenses,
    required this.availableAmount,
    required this.dailyAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return _buildSection(
      title: l10n.results,
      icon: Icons.calculate,
      color: AppColors.blue[500]!,
      children: [
        _buildResultCard(
          title: l10n.totalExpenses,
          value: totalExpenses,
          icon: Icons.payments,
          color: AppColors.red[500]!,
        ),
        const SizedBox(height: Constants.margin),
        _buildResultCard(
          title: l10n.availableAmount,
          value: availableAmount,
          icon: Icons.account_balance_wallet,
          color: availableAmount >= 0 ? AppColors.green[500]! : AppColors.red[500]!,
        ),
        const SizedBox(height: Constants.margin),
        _buildResultCard(
          title: l10n.dailyAmount,
          value: dailyAmount,
          icon: Icons.today,
          color: AppColors.orange[500]!,
          isDaily: true,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: Constants.margin),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    bool isDaily = false,
  }) {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(Constants.margin),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(Constants.margin),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: Constants.margin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_formatCurrency(value)} ${AppLocalizations.of(context)!.currency}${isDaily ? AppLocalizations.of(context)!.perDay : ''}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCurrency(double value) {
    if (value == 0) return '0';
    
    final parts = value.toInt().toString().split('');
    final result = <String>[];
    
    for (int i = parts.length - 1; i >= 0; i--) {
      if ((parts.length - 1 - i) % 3 == 0 && i != parts.length - 1) {
        result.insert(0, ',');
      }
      result.insert(0, parts[i]);
    }
    
    return result.join();
  }
} 