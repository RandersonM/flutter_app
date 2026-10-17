import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

// A character stores its devil fruit and crew by name. The edit form keeps
// that stored name as the source of truth and only looks it up in the loaded
// options to display it, so options that are missing, still loading or renamed
// never change what gets saved.

DevilFruit? devilFruitNamed(List<DevilFruit> fruits, String? romanName) =>
    romanName == null
    ? null
    : fruits.where((fruit) => fruit.romanName == romanName).firstOrNull;

String? crewIdNamed(List<CrewModel> crews, String? name) => name == null
    ? null
    : crews.where((crew) => crew.name == name).firstOrNull?.id;

String? crewNameWithId(List<CrewModel> crews, String? id) =>
    id == null ? null : crews.where((crew) => crew.id == id).firstOrNull?.name;
