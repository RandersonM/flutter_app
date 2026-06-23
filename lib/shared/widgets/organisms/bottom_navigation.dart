// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart' show Constants;
import 'package:opfan/shared/utils/icons/one_piece_icons.dart';

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

  BottomBarItem _buildNavigationItem(
    BuildContext context,
    BottomNavigationPages page,
    bool isActive,
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

    return BottomBarItem(
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      selectedIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSecondaryContainer)),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: StylishBottomBar(
        option: AnimatedBarOptions(
          iconSize: Constants.iconSize,
          barAnimation: BarAnimation.transform3D,
          iconStyle: IconStyle.animated,
          opacity: 0.3,
        ),
        fabLocation: StylishBarFabLocation.center,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
        notchStyle: NotchStyle.circle,
        elevation: 2,
        currentIndex: _pages.indexOf(widget.currentPage),
        hasNotch: true,
        items: _pages
            .map((page) => _buildNavigationItem(
                  context,
                  page,
                  page == widget.currentPage,
                ))
            .toList(),
        onTap: (index) => _onItemTapped(index),
      ),
    );
  }
}
