import 'package:flutter/material.dart';
import 'package:neterite/features/Notebook/screens/notebook_update.dart';

class NeteriteCardNote extends StatelessWidget {
  const NeteriteCardNote({super.key, required this.noteTitle, required this.noteId});
  final String noteTitle;
  final String noteId; // El id de la nota

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de actualización de la nota
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfiniteCanvasUpdatePage(canvasId: noteId), // Pasar el ID de la nota
          ),
        );
      },
      child: Card(
        child: SizedBox(
          width: 150,
          height: 50,
          child: Center(child: Text(noteTitle)),
        ),
      ),
    );
  }
}
