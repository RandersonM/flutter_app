import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class PlateGuideScreen extends StatefulWidget {
  const PlateGuideScreen({super.key});

  @override
  State<PlateGuideScreen> createState() => _PlateGuideScreenState();
}

class _PlateGuideScreenState extends State<PlateGuideScreen> {
  int _touchedIndex = -1;

  List<PlateSection> _buildPlateSections(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      PlateSection(
        title: l10n.vegetablesTitle,
        subtitle: l10n.vegetablesSubtitle,
        description: l10n.vegetablesDescription,
        examples: l10n.vegetablesExamples,
        color: AppColors.green[500]!,
        percentage: 50,
      ),
      PlateSection(
        title: l10n.proteinsTitle,
        subtitle: l10n.proteinsSubtitle,
        description: l10n.proteinsDescription,
        examples: l10n.proteinsExamples,
        color: AppColors.red[500]!,
        percentage: 25,
      ),
      PlateSection(
        title: l10n.carbohydratesTitle,
        subtitle: l10n.carbohydratesSubtitle,
        description: l10n.carbohydratesDescription,
        examples: l10n.carbohydratesExamples,
        color: AppColors.brown[500]!,
        percentage: 25,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.plateGuideTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: Constants.margin * 3,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(), _buildPieChart(), _buildTips()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple[600]!.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: Constants.margin,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                PhosphorIconsRegular.info,
                color: AppColors.purple[600]!,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.plateGuideHeader,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.purple[600]!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.plateDivision,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (pieTouchResponse?.touchedSection != null) {
                        _touchedIndex = pieTouchResponse!
                            .touchedSection!
                            .touchedSectionIndex;
                      } else {
                        _touchedIndex = -1;
                      }
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 0,
                sections: _buildPlateSections(context).asMap().entries.map((
                  entry,
                ) {
                  final isTouched = entry.key == _touchedIndex;
                  final section = entry.value;
                  final fontSize = isTouched ? 18.0 : 14.0;
                  final radius = isTouched ? 120.0 : 110.0;

                  return PieChartSectionData(
                    color: section.color,
                    value: section.percentage.toDouble(),
                    title: '${section.percentage}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 3),
                        Shadow(color: Colors.black, blurRadius: 1),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: _buildPlateSections(context).asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;
        final isTouched = index == _touchedIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _touchedIndex = _touchedIndex == index ? -1 : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isTouched
                  ? section.color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isTouched ? Border.all(color: section.color) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: section.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isTouched ? section.color : null,
                                ),
                          ),
                          Text(
                            section.subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isTouched) ...[
                  const SizedBox(height: 12),
                  Text(
                    section.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.examples(section.examples),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTips() {
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.margin * 2),
      padding: const EdgeInsets.all(Constants.margin * 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.yellow[500]!.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                PhosphorIconsRegular.lightbulb,
                color: AppColors.yellow[500]!,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.sanjiTipsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellow[500]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            AppLocalizations.of(context)!.sanjiTip1,
            PhosphorIconsRegular.leaf,
          ),
          _buildTipItem(
            AppLocalizations.of(context)!.sanjiTip2,
            PhosphorIconsRegular.forkKnife,
          ),
          _buildTipItem(
            AppLocalizations.of(context)!.sanjiTip3,
            PhosphorIconsRegular.palette,
          ),
          _buildTipItem(
            AppLocalizations.of(context)!.sanjiTip4,
            PhosphorIconsRegular.forkKnife,
          ),
          _buildTipItem(
            AppLocalizations.of(context)!.sanjiTip5,
            PhosphorIconsRegular.appleLogo,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              try {
                final url = Uri.parse(
                  'https://bvsms.saude.gov.br/bvs/publicacoes/guia_alimentar_populacao_brasileira_2ed.pdf',
                );
                final canLaunch = await canLaunchUrl(url);
                if (canLaunch) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.couldNotOpenLink,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.errorPrefix(e.toString()),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.yellow[500]!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.yellow[500]!.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const AppIcon(PhosphorIconsRegular.book, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.sanjiReference,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const AppIcon(
                    PhosphorIconsRegular.arrowSquareOut,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.yellow[500]!, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
            ),
          ),
        ],
      ),
    );
  }
}

class PlateSection {
  final String title;
  final String subtitle;
  final String description;
  final String examples;
  final Color color;
  final int percentage;

  PlateSection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.examples,
    required this.color,
    required this.percentage,
  });
}
