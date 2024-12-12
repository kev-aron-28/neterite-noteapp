import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Subject/model/subject_model.dart';
import 'package:neterite/features/Subject/repo/subject_repo.dart';
import 'package:neterite/features/Subject/screens/subject_create_screen.dart';
import 'package:neterite/features/Subject/screens/update_subject_screen.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  SubjectState createState() => SubjectState();
}

class SubjectState extends State<SubjectScreen> {
  final InMemorySubjectRepository _repository = InMemorySubjectRepository(); // Reemplaza con tu implementación real
  List<Subject> _subjects = [];
  List<Subject> _filteredSubjects = [];
  bool _isLoading = true;

  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubjects();

    // Escuchar cambios en el campo de búsqueda
    _searchController.addListener(() {
      _filterSubjects(_searchController.text);
    });
  }

  _fetchSubjects() async {
    try {
      final subjects = await _repository.getAllSubjects(); // Asegúrate de que sea async si tu repositorio lo requiere
      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las materias')),
      );
    }
  }

  void _filterSubjects(String query) {
    // Verifica si la consulta no está vacía
    if (query.isEmpty) {
      setState(() {
        _filteredSubjects = _subjects;
      });
      return;
    }

    setState(() {
      // Filtra las materias por nombre que coincidan con la consulta
      _filteredSubjects = _subjects
          .where((subject) =>
              subject.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteSubject(String id) async {
    try {
      _repository.deleteSubject(id);
      setState(() {
        _subjects.removeWhere((subject) => subject.id == id);
        _filteredSubjects.removeWhere((subject) => subject.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materia eliminada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la materia')),
      );
    }
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Está seguro de que desea eliminar esta materia?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteSubject(id);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      // Título de la sección
                      Text(
                        'Materias',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: TextField(
                          controller: _searchController, // Vincula el controlador
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: "Buscar materias",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildSubjectList(_filteredSubjects),
                ),
              ],
            ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 4),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateSubjectScreen(), // Cambia según tu pantalla
            ),
          ).then((_) => _fetchSubjects()); // Recargar materias al volver
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubjectList(List<Subject> subjects) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text('No hay materias registradas.'),
      );
    }

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return ListTile(
          title: Text(subject.name),
          subtitle: Text(subject.teacher),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(subject.id),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => UpdateSubjectScreen(subjectId: subject.id)),
            );
          },
        );
      },
    );
  }
}
