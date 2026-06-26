import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'package:opfan/features/one_piece/presentation/widgets/list/list_content.dart';
import 'package:opfan/features/one_piece/presentation/widgets/search/search.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DefaultAppBar(
            title: Text(AppLocalizations.of(context)!.onePiece),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const AppIcon(PhosphorIconsRegular.caretLeft, size: 34),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const AppIcon(
                      PhosphorIconsRegular.magnifyingGlass),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ]),
        body: const ListContent(),
        drawer: Drawer(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0.0,
          child: const Search(),
        ),
      );
}
