// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_app/shared/app_routes.dart';
import 'package:simple_app/shared/icons/one_piece_icons.dart';
import 'package:simple_app/shared/theme.dart';

import '../constants.dart';

enum BottomNavigationPages {
  counter,
  calculator,
  onePiece,
}

///
/// Create a BottomNavigationBar - the main menu for this application.
///
class BottomNavigation extends StatefulWidget {
  final BottomNavigationPages currentPage;
  const BottomNavigation(this.currentPage, {Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  List<BottomNavigationPages> pages = <BottomNavigationPages>[
    BottomNavigationPages.counter,
    BottomNavigationPages.calculator,
    BottomNavigationPages.onePiece
  ];

  Future<void> callNewPage(BottomNavigationPages page) async {
    switch (page) {
      case BottomNavigationPages.counter:
        await Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.counter, (_) => false);
        break;

      case BottomNavigationPages.calculator:
        await Navigator.pushNamedAndRemoveUntil(context, AppRoutes.calculator,
            ModalRoute.withName(AppRoutes.calculator));
        break;

      case BottomNavigationPages.onePiece:
        await Navigator.pushNamedAndRemoveUntil(context, AppRoutes.onePiece,
            ModalRoute.withName(AppRoutes.onePiece));
        break;
    }
  }

  ///
  /// Handle bottom navigation clicks.
  ///
  ///
  Future<void> _onItemTapped(int pageIndex) async {
    BottomNavigationPages page = pages.elementAt(pageIndex);
    callNewPage(page);
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      BuildContext context, BottomNavigationPages page) {
    String? label;
    IconData? icon;

    switch (page) {
      case BottomNavigationPages.counter:
        label = AppLocalizations.of(context)!.home;
        icon = Icons.home_rounded;
        break;

      case BottomNavigationPages.calculator:
        label = AppLocalizations.of(context)!.calculatorTitle;
        icon = Icons.calculate;
        break;

      case BottomNavigationPages.onePiece:
        label = AppLocalizations.of(context)!.onePiece;
        icon = OnePieceIcons.jollyRoger;
        break;
    }

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(
            top: Constants.margin, bottom: 0.75 * Constants.margin),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: const Offset(0, Constants.margin),
        child: Container(
          padding: const EdgeInsets.only(bottom: Constants.margin),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 10.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
            child: BottomNavigationBar(
              selectedItemColor: Theme.of(context).colorScheme.onSecondary,
              iconSize: IconSize.medium,
              items: pages
                  .map((BottomNavigationPages page) =>
                      _buildBottomNavigationBarItem(context, page))
                  .toList(),
              currentIndex: pages.indexOf(widget.currentPage),
              onTap: (int pageIndex) {
                _onItemTapped(pageIndex);
              },
              selectedFontSize: 12.0,
            ),
          ),
        ),
      );
}
