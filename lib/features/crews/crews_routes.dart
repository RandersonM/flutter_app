import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/features/crews/presentation/create_crew_screen.dart';
import 'package:opfan/features/crews/presentation/edit_crew_screen.dart';
import 'package:opfan/features/crews/presentation/list_crews_screen.dart';
import 'package:opfan/features/crews/presentation/crew_details_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class CrewsRoutes implements FeatureRouteModule {
  static const String createCrew = '/createCrew';
  static const String editCrew = '/editCrew';
  static const String listCrews = '/listCrews';
  static const String crewDetails = '/crewDetails';

  @override
  List<String> get routes => [createCrew, editCrew, listCrews, crewDetails];

  @override
  Set<String> get privateRoutes => {createCrew, editCrew, listCrews};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case createCrew:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const CreateCrewScreen(),
          settings: settings,
        );
      case editCrew:
        final crew = settings.arguments as CrewModel;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditCrewScreen(crew: crew),
          settings: settings,
        );
      case listCrews:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ListCrewsScreen(),
          settings: settings,
        );
      case crewDetails:
        final crew = settings.arguments as CrewModel;
        return MaterialPageRoute<dynamic>(
          builder: (_) => CrewDetailsScreen(crew: crew),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
