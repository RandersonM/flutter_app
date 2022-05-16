// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:json_annotation/json_annotation.dart';

part 'search_movie.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchMovie {
  SearchMovie(
      {required this.title,
      required this.year,
      required this.poster,
      required this.imdbId,
      required this.type});

  @JsonKey(name: 'Title')
  String title;

  @JsonKey(name: 'Year')
  String year;

  @JsonKey(name: 'Poster')
  String poster;

  @JsonKey(name: 'imdbID')
  String imdbId;

  @JsonKey(name: 'Type')
  String type;

  factory SearchMovie.fromJson(Map<String, dynamic> json) =>
      _$SearchMovieFromJson(json);

  Map<String, dynamic> toJson() => _$SearchMovieToJson(this);
}
