import 'package:flutter/material.dart';
import 'package:neterite/features/Calendar/model/event_model.dart';
import 'package:neterite/features/Calendar/repo/event_repo.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _location = '';
  bool _isAllDay = false;

  InMemoryEventRepository repo = InMemoryEventRepository();

  // Método para seleccionar la fecha
  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  // Método para seleccionar la hora
  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _selectedTime = selectedTime;
      });
    }
  }

  // Método para crear el evento
  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona la fecha y la hora')),
        );
        return;
      }

      final eventTitle = _titleController.text;
      final eventDescription = _descriptionController.text;

      final event = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: eventTitle,
        description: eventDescription,
        eventDate: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        location: _location,
        isAllDay: _isAllDay,
      );

      // Aquí puedes guardar el evento en el repositorio o en una lista
      repo.createEvent(event);

      Navigator.pop(context); // Regresar a la página anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo para el título del evento
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para la descripción del evento
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selector de fecha
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Selecciona una fecha'
                        : 'Fecha: ${_selectedDate!.toLocal().toIso8601String().split("T").first}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Elegir Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selector de hora
              Row(
                children: [
                  Text(
                    _selectedTime == null
                        ? 'Selecciona una hora'
                        : 'Hora: ${_selectedTime!.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text('Elegir Hora'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo para la ubicación del evento
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ubicación del Evento',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Opción para marcar si el evento es todo el día
              Row(
                children: [
                  const Text('¿Todo el día?'),
                  Checkbox(
                    value: _isAllDay,
                    onChanged: (value) {
                      setState(() {
                        _isAllDay = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botón para crear el evento
              Center(
                child: ElevatedButton(
                  onPressed: _createEvent,
                  child: const Text('Crear Evento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
