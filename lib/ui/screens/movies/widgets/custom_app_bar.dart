import 'package:flutter/material.dart';
import 'package:simple_app/blocs/movie/movie_search_bloc.dart';
import 'package:simple_app/service_locator.dart';

class SearchMovieBar extends StatelessWidget {
  const SearchMovieBar({Key? key}) : super(key: key);

  double appBarHeight(BuildContext context) =>
      150.0 + MediaQuery.of(context).padding.top;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.0,
      child: Container(
        height: appBarHeight(context),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        // color: Theme.of(context).colorScheme.primary,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondary,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  BackButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Movie Search',
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontSize: 34, color: Colors.white),
                  ),
                ],
              ),
              const SearchBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  const SearchBox({Key? key}) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  void dispose() {
    sl.get<MovieSearchBloc>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      elevation: 3.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(2.0),
        ),
      ),
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter a Movie Title',
          fillColor: Colors.white,
        ),
        // onChanged: (query) {},
        onSubmitted: sl.get<MovieSearchBloc>().addQuery,
      ),
    );
  }
}
