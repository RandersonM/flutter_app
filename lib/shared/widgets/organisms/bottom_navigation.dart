import 'package:phosphor_flutter/phosphor_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart';


// Fixed dark plum color — identical for light and dark mode.
const Color _kNavBarBackground = Color(0xFF2D1648);
// Active capsule — solid violet.
const Color _kActiveCapsule = Color(0xFF7C3AED);

enum BottomNavigationPages {
  home,
  finances,
  workout,
  cooking,
  knowledge,
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation(
    this.currentPage, {
    super.key,
  });

  final BottomNavigationPages currentPage;

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  static const List<BottomNavigationPages> _pages = <BottomNavigationPages>[
    BottomNavigationPages.finances,
    BottomNavigationPages.workout,
    BottomNavigationPages.home,
    BottomNavigationPages.cooking,
    BottomNavigationPages.knowledge,
  ];

  Future<void> _navigateToPage(BottomNavigationPages page) async {
    if (page == widget.currentPage) return;

    switch (page) {
      case BottomNavigationPages.home:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (_) => false,
        );
        break;

      case BottomNavigationPages.finances:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.finances,
          ModalRoute.withName(AppRoutes.finances),
        );
        break;

      case BottomNavigationPages.workout:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.workout,
          ModalRoute.withName(AppRoutes.workout),
        );
        break;

      case BottomNavigationPages.cooking:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.cooking,
          ModalRoute.withName(AppRoutes.cooking),
        );
        break;
      case BottomNavigationPages.knowledge:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.knowledge,
          ModalRoute.withName(AppRoutes.knowledge),
        );
        break;
    }
  }

  Future<void> _onItemTapped(int pageIndex) async {
    final page = _pages[pageIndex];
    await _navigateToPage(page);
  }

  Widget _buildNavigationItem(
    BuildContext context,
    BottomNavigationPages page,
    bool isActive,
    int index,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final (String label, IconData icon) = switch (page) {
      BottomNavigationPages.finances => (
          localizations.finances,
          PhosphorIconsRegular.coins,
        ),
      BottomNavigationPages.workout => (
          localizations.workout,
          PhosphorIconsRegular.barbell,
        ),
      BottomNavigationPages.home => (
          localizations.home,
          PhosphorIconsRegular.skull,
        ),
      BottomNavigationPages.cooking => (
          localizations.cooking,
          PhosphorIconsRegular.forkKnife,
        ),
      BottomNavigationPages.knowledge => (
          localizations.planner,
          PhosphorIconsRegular.book,
        ),
    };

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 7.0,
                ),
                decoration: BoxDecoration(
                  color: isActive ? _kActiveCapsule : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.white.withValues(
                    alpha: isActive ? 1.0 : 0.55,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                  letterSpacing: isActive ? 0.2 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Respect the device's bottom safe area (home indicator, etc.)
    // without adding any extra external padding so the bar is truly
    // docked to the screen edge.
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _kNavBarBackground,
        // Only top corners are rounded — the bar is flush with the screen bottom.
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Constants.size16),
          topRight: Radius.circular(Constants.size16),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed-height content area — icons stay vertically centered here.
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildNavigationItem(
                  context,
                  _pages[index],
                  _pages[index] == widget.currentPage,
                  index,
                ),
              ),
            ),
          ),
          // Safe-area spacer — keeps bar flush at the bottom edge.
          SizedBox(height: bottomInset > 0 ? bottomInset : 8.0),
        ],
      ),
    );
  }
}
