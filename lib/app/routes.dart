import 'package:flutter/material.dart';
import 'package:neterite/features/Lobby/screens/lobby_screen.dart';
import 'package:neterite/features/Notebook/screens/notebook_screen.dart';
// Import other screens here

class Routes {
  static const String notes = '/notes';
  static const String calendar = '/calendar';
  static const String lobby = '/lobby';
  static const String todo = '/todo';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case notes:
        return MaterialPageRoute(
          builder: (_) => const NotebookScreen(),
        );
      case calendar:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Calendar Page'))),
        );
      case lobby:
        return MaterialPageRoute(builder: (_) => const LobbyScreen());
      case todo:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('To-Do Page'))),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
