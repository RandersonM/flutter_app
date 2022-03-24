// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:simple_app/core/one_piece/characters_provider.dart';
import 'package:simple_app/core/one_piece/search_provider.dart';
import 'package:simple_app/screens/one_piece/widgets/list/list_content.dart';
import 'package:simple_app/screens/one_piece/widgets/search/search.dart';
import 'package:simple_app/shared/app_bar/default_app_bar.dart';
import 'package:simple_app/shared/bottom_navigation/bottom_navigation.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({Key? key}) : super(key: key);

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  @override
  Widget build(BuildContext context) => Consumer<CharactersProvider>(
        builder: (BuildContext context, CharactersProvider provider, _) =>
            Scaffold(
          appBar: DefaultAppBar(
            title: Text(AppLocalizations.of(context)!.onePiece),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          body: ListContent(
            provider: provider,
          ),
          bottomNavigationBar:
              const BottomNavigation(BottomNavigationPages.onePiece),
          drawer: Drawer(
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            elevation: 0.0,
            child: ChangeNotifierProvider<SearchProvider>(
              create: (BuildContext context) => SearchProvider(),
              child: const Search(),
            ),
          ),
        ),
      );
}
