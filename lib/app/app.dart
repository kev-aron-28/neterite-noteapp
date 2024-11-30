import 'package:flutter/material.dart';
import 'package:neterite/app/routes.dart';

class NeteriteApp extends StatelessWidget {
  const NeteriteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      initialRoute: Routes.lobby,
      onGenerateRoute: Routes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

