import 'package:flutter/material.dart';
import 'package:opfan/shared/utils/constants.dart';

const _purple = Color(0xFF8B5CF6);
const _cardBg = Color(0xFF16161C);

/// Onboarding / empty state shown when no financial data exists for the month.
class FinancesEmptyState extends StatelessWidget {
  final VoidCallback onSetup;

  const FinancesEmptyState({super.key, required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Constants.margin),
        padding: const EdgeInsets.all(Constants.margin * 3),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: _purple,
                size: 48,
              ),
            ),
            const SizedBox(height: Constants.margin * 2),
            Text(
              'Economize com a Nami',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin),
            Text(
              'Configure suas finanças do mês e acompanhe\nseu progresso em tempo real.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin * 3),
            const _FeaturePill(
              icon: Icons.trending_up_rounded,
              label: 'Visão geral do mês',
            ),
            const SizedBox(height: 10),
            const _FeaturePill(
              icon: Icons.donut_large_rounded,
              label: 'Gráfico de balanço',
            ),
            const SizedBox(height: 10),
            const _FeaturePill(
              icon: Icons.pie_chart_rounded,
              label: 'Gastos por categoria',
            ),
            const SizedBox(height: Constants.margin * 3),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSetup,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Configurar finanças'),
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _purple, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
        ),
      ],
    );
  }
}
