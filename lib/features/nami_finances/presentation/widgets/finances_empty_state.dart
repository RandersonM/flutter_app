import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

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
              child: const AppIcon(
                PhosphorIconsRegular.bank,
                color: _purple,
                size: 48,
              ),
            ),
            const SizedBox(height: Constants.margin * 2),
            Text(
              AppLocalizations.of(context)!.saveWithNami,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin),
            Text(
              AppLocalizations.of(context)!.configureYourFinances,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin * 3),
            _FeaturePill(
              icon: PhosphorIconsRegular.trendUp,
              label: AppLocalizations.of(context)!.monthOverview,
            ),
            const SizedBox(height: 10),
            _FeaturePill(
              icon: PhosphorIconsRegular.circle,
              label: AppLocalizations.of(context)!.balanceChart,
            ),
            const SizedBox(height: 10),
            _FeaturePill(
              icon: PhosphorIconsRegular.chartPieSlice,
              label: AppLocalizations.of(context)!.expensesByCategory,
            ),
            const SizedBox(height: Constants.margin * 3),
            AppButton(
              onPressed: onSetup,
              icon: const AppIcon(PhosphorIconsRegular.plus, size: 18),
              label: AppLocalizations.of(context)!.setupFinances,
              isFullWidth: true,
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
