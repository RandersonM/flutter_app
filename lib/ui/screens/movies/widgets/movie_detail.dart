import 'package:flutter/material.dart';
import 'package:simple_app/core/models/movies/search_movie.dart';
import 'dart:ui' as ui;

class MovieDetail extends StatelessWidget {
  final SearchMovie movie;
  const MovieDetail({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.network(
          movie.poster,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 400.0,
                    height: 400.0,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                          image: NetworkImage(movie.poster), fit: BoxFit.cover),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 20.0,
                            offset: Offset(0.0, 10.0))
                      ]),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 0.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        movie.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontFamily: 'Arvo'),
                      )),
                      //  Text(
                      //   '${movie.imdbRating}/10',
                      //   style: const TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 20.0,
                      //       fontFamily: 'Arvo'),
                      // )
                    ],
                  ),
                ),
                //  Text(movie.plot,
                //     style:
                //          const TextStyle(color: Colors.white, fontFamily: 'Arvo')),
                const Padding(padding: EdgeInsets.all(10.0)),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      width: 150.0,
                      height: 60.0,
                      alignment: Alignment.center,
                      child: const Text(
                        'Rate Movie',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Arvo',
                            fontSize: 20.0),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xaa3C3261)),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: const Color(0xaa3C3261)),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.bookmark,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: const Color(0xaa3C3261)),
                        )),
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
