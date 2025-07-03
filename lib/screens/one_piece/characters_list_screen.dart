// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:opfan/screens/one_piece/widgets/list/list_content.dart';
import 'package:opfan/screens/one_piece/widgets/search/search.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';

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
