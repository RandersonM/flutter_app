// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/l10n/app_localizations.dart';
import 'package:simple_app/utils/app_routes.dart';
import 'package:simple_app/utils/constants.dart' show Constants;
import 'package:simple_app/utils/icons/one_piece_icons.dart';
import 'package:simple_app/utils/theme.dart';

enum BottomNavigationPages {
  home,
  onePiece,
  devilFruit,
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
    BottomNavigationPages.home,
    BottomNavigationPages.onePiece,
    BottomNavigationPages.devilFruit,
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

      case BottomNavigationPages.onePiece:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.onePiece,
          ModalRoute.withName(AppRoutes.onePiece),
        );
        break;

      case BottomNavigationPages.devilFruit:
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.devilFruit,
          ModalRoute.withName(AppRoutes.devilFruit),
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
      BottomNavigationPages.home => (localizations.home, Icons.home_rounded),
      BottomNavigationPages.onePiece => (
          localizations.onePiece,
          OnePieceIcons.jollyRoger
        ),
      BottomNavigationPages.devilFruit => (
          'Akuma no Mi',
          Icons.apple // Ícone de maçã para representar frutas
        ),
    };

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(
          top: Constants.margin,
          bottom: Constants.margin * 0.75,
        ),
        child: Icon(
          icon,
          size: IconSize.medium,
        ),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(
          top: Constants.margin,
          bottom: Constants.margin * 0.75,
        ),
        child: Icon(
          icon,
          size: IconSize.medium,
        ),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Transform.translate(
      offset: const Offset(0, Constants.margin),
      child: Container(
        padding: const EdgeInsets.only(bottom: Constants.margin),
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
            selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
            elevation: 0,
            items: _pages
                .map((page) => _buildNavigationItem(context, page))
                .toList(),
            currentIndex: _pages.indexOf(widget.currentPage),
            onTap: _onItemTapped,
            selectedFontSize: 12.0,
            unselectedFontSize: 11.0,
          ),
        ),
      ),
    );
  }
}
