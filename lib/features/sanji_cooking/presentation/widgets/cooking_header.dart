import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class CookingHeader extends StatefulWidget {
  const CookingHeader({super.key});

  @override
  State<CookingHeader> createState() => _CookingHeaderState();
}

class _CookingHeaderState extends State<CookingHeader>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  List<String> _buildSanjiQuotes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      l10n.sanjiQuote1,
      l10n.sanjiQuote2,
      l10n.sanjiQuote3,
      l10n.sanjiQuote4,
      l10n.sanjiQuote5,
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuote();
      }
    });
  }

  void _nextQuote() {
    _currentIndex++;

    if (_currentIndex >= _buildSanjiQuotes(context).length) {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
    } else {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _nextQuote();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // GIF hero — no border radius change, keep full bleed
        // SizedBox(
        //   width: double.infinity,
        //   height: 250,
        //   child: Image.asset(
        //     'assets/logo/sanji-cooking.gif',
        //     fit: BoxFit.fill,
        //   ),
        // ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: Image.asset(
              'assets/logo/sanji-cooking.gif',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Quote section — subtle violet glow shadow, no colored border (COOK-02)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            spacing: Constants.margin,
            children: [
              SizedBox(
                height: 60,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _buildSanjiQuotes(context).length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        _buildSanjiQuotes(context)[index],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.tertiary,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
