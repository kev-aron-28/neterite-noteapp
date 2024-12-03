import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Notebook/screens/notebook_new.screen.dart';

class NotebookScreen extends StatelessWidget {
  NotebookScreen({super.key});

  // Ejemplo de datos para las notas
  final List<Map<String, String>> notes = [
    {"title": "Primera Nota", "subtitle": "Descripción de la primera nota"},
    {"title": "Segunda Nota", "subtitle": "Descripción de la segunda nota"},
    {"title": "Tercera Nota", "subtitle": "Descripción de la tercera nota"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: const SearchBar(
                      leading: Icon(Icons.search),
                      hintText: "Buscar nota",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Lista de notas
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Evita conflictos con SingleChildScrollView
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(note["title"] ?? "Sin título"),
                    subtitle: Text(note["subtitle"] ?? "Sin descripción"),
                    leading: const Icon(Icons.folder, color: Colors.deepPurple),
                    hoverColor: Colors.blue
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Redirige a la página de creación de evento
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfiniteCanvasPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear Evento',
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 0),
    );
  }
}
