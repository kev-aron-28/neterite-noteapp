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

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  _fetchSubjects() {
    try {
      final subjects = _repository.getAllSubjects();
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
    setState(() {
      _filteredSubjects = _subjects
          .where((subject) =>
              subject.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: const SearchBar(
                      leading: Icon(Icons.search),
                      hintText: "Buscar materias",
                    ),
                  ),
                ),
                Expanded(
                  child: _buildSubjectList(_filteredSubjects),
                ),
              ],
            ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 4),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UpdateSubjectScreen(subjectId: subject.id))
            );
          },
        );
      },
    );
  }
}
