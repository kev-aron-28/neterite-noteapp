import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Notebook/models/canva_model.dart';
import 'package:neterite/features/Notebook/repo/notebook_repo.dart';
import 'package:neterite/features/Notebook/screens/notebook_new.screen.dart';
import 'package:neterite/features/Notebook/screens/notebook_update.dart';

class NotebookScreen extends StatefulWidget {
  NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final InMemoryCanvasRepository repository = InMemoryCanvasRepository();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  List<CanvasModel> canvases = [];

  Future<void> _loadEvents() async {
    List<CanvasModel> canvas = await repository.getAllCanvas();
    if (searchQuery.isNotEmpty) {
      canvas = canvas.where((event) =>
          event.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    setState(() {
      canvases = canvas;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    'Notas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Buscar canvas",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Lista de canvas
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: canvases.length,
                itemBuilder: (context, index) {
                  final canvas = canvases[index];
                  return ListTile(
                    title: Text(canvas.name),
                    leading: const Icon(Icons.folder, color: Colors.deepPurple),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteCanvas(canvas.id);
                      },
                    ),
                    hoverColor: Colors.blue,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InfiniteCanvasUpdatePage(canvasId: canvas.id),
                        ),
                      );

                      setState(() {
                        _loadEvents();
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfiniteCanvasPage()),
          );

          setState(() {
            _loadEvents();
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear Canvas',
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 0),
    );
  }

  void _deleteCanvas(String canvasId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este canvas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              repository.deleteCanvas(canvasId);
              setState(() {
                _loadEvents();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
