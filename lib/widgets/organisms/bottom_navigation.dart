// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/app_routes.dart';
import 'package:opfan/utils/constants.dart' show Constants;
import 'package:opfan/utils/icons/one_piece_icons.dart';
import 'package:opfan/utils/theme.dart';

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

  BottomNavigationBarItem _buildNavigationItem(
    BuildContext context,
    BottomNavigationPages page,
  ) {
    final localizations = AppLocalizations.of(context)!;
    
    final (String label, IconData icon) = switch (page) {
      BottomNavigationPages.finances => (
          localizations.finances,
          FontAwesomeIcons.coins,
        ),
      BottomNavigationPages.workout => (
          localizations.workout,
          FontAwesomeIcons.dumbbell 
        ),
      BottomNavigationPages.home => (
          localizations.home,
          OnePieceIcons.jollyRoger,
        ),
      BottomNavigationPages.cooking => (
          localizations.cooking,
          FontAwesomeIcons.utensils,
        ),
      BottomNavigationPages.knowledge => (
          localizations.planner,
          FontAwesomeIcons.book,
        ),
    };

    // Special design for home button (middle)
    if (page == BottomNavigationPages.home) {
      return BottomNavigationBarItem(
        icon: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Constants.margin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: Column(
            spacing: Constants.margin / 2,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: IconSize.medium,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        activeIcon: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Constants.margin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: IconSize.medium,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        label: '',
      );
    }

    // Regular design for other buttons
    return BottomNavigationBarItem(
      icon: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: IconSize.medium,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      activeIcon: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: Constants.margin,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: IconSize.medium,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 4.0,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: colorScheme.surface,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
            elevation: 0,
            items: _pages
                .map((page) => _buildNavigationItem(context, page))
                .toList(),
            currentIndex: _pages.indexOf(widget.currentPage),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
