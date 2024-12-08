import 'package:flutter/material.dart';
import 'package:neterite/features/Subject/model/subject_model.dart';
import 'package:neterite/features/Subject/repo/subject_repo.dart';

class UpdateSubjectScreen extends StatefulWidget {
  final String subjectId;

  const UpdateSubjectScreen({Key? key, required this.subjectId})
      : super(key: key);

  @override
  State<UpdateSubjectScreen> createState() => _UpdateSubjectScreenState();
}

class _UpdateSubjectScreenState extends State<UpdateSubjectScreen> {
  final InMemorySubjectRepository _repository = InMemorySubjectRepository();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _teacherController;
  Subject? _subject;

  @override
  void initState() {
    super.initState();
    _loadSubject();
  }

  void _loadSubject() {
    final subject = _repository.getSubject(widget.subjectId);
    if (subject != null) {
      setState(() {
        _subject = subject;
        _nameController = TextEditingController(text: subject.name);
        _teacherController = TextEditingController(text: subject.teacher);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materia no encontrada')),
      );
      Navigator.pop(context);
    }
  }

  void _updateSubject() {
    if (_formKey.currentState!.validate()) {
      final updatedSubject = Subject(
        id: _subject!.id,
        name: _nameController.text,
        teacher: _teacherController.text,
      );
      _repository.updateSubject(_subject!.id, updatedSubject);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materia actualizada correctamente')),
      );
      Navigator.pop(context); // Volver a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_subject == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Materia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Materia',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'Profesor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del profesor no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateSubject,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
