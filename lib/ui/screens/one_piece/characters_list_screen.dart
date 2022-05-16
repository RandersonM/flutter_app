// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/shared/app_bar/default_app_bar.dart';
import 'package:simple_app/shared/bottom_navigation/bottom_navigation.dart';
import 'package:simple_app/ui/screens/one_piece/widgets/list/list_content.dart';

import 'widgets/search/search.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({Key? key}) : super(key: key);

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DefaultAppBar(
          title: Text(AppLocalizations.of(context)!.onePiece),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        body: const ListContent(),
        bottomNavigationBar:
            const BottomNavigation(BottomNavigationPages.onePiece),
        drawer: Drawer(
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          elevation: 0.0,
          child: const Search(),
        ),
      );
}
