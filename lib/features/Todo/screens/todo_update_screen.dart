import 'package:flutter/material.dart';
import 'package:neterite/features/Todo/models/todo_model.dart';
import 'package:neterite/features/Todo/repo/todo_repo.dart';
import 'package:neterite/features/Subject/model/subject_model.dart';
import 'package:neterite/features/Subject/repo/subject_repo.dart';

class UpdateTodoScreen extends StatefulWidget {
  final String id;

  const UpdateTodoScreen({super.key, required this.id});

  @override
  _UpdateTodoScreenState createState() => _UpdateTodoScreenState();
}

class _UpdateTodoScreenState extends State<UpdateTodoScreen> {
  late TodoModel? _todo;
  final InMemoryTodoRepository _repository = InMemoryTodoRepository();
  final InMemorySubjectRepository _subjectRepository = InMemorySubjectRepository();
  final TextEditingController _titleController = TextEditingController();
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _todo = _repository.getById(widget.id); // Get all subjects
    if (_todo != null) {
      _titleController.text = _todo!.title;
      _selectedSubjectId = _todo!.subject; // Pre-select the subject
    }
  }

  void _updateTodo() {
    if (_todo != null && _selectedSubjectId != null) {
      setState(() {
        _repository.update(
          _todo!.id,
          title: _titleController.text,
          date: _todo!.date, // Keep the original date
          isCompleted: _todo!.isCompleted, // Keep the original status
          subject: _selectedSubjectId!, // Assign selected subject
        );
      });
      Navigator.of(context).pop(); // Go back to the previous screen
    }
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _todo?.date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && _todo != null) {
      setState(() {
        _todo!.date = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_todo == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Actualizar Tarea'),
        ),
        body: const Center(
          child: Text('Tarea no encontrada.'),
        ),
      );
    }

     final List<Subject> subjects = _subjectRepository.getAllSubjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown to select the subject
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              items: subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.name, // Use subject.id as the unique value
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSubjectId = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Seleccionar Materia',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una materia';
                  }
                  return null;
                },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Fecha: ${_todo!.date.toLocal().toIso8601String().split("T").first}'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Cambiar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateTodo,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
