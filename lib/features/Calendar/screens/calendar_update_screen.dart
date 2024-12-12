import 'package:flutter/material.dart';
import 'package:neterite/features/Calendar/model/event_model.dart';
import 'package:neterite/features/Calendar/repo/event_repo.dart';

class UpdateEventView extends StatefulWidget {
  final String eventId;

  const UpdateEventView({Key? key, required this.eventId}) : super(key: key);

  @override
  State<UpdateEventView> createState() => _UpdateEventViewState();
}

class _UpdateEventViewState extends State<UpdateEventView> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  bool isAllDay = false;

  final InMemoryEventRepository eventRepository = InMemoryEventRepository();

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final event = (await eventRepository.getEvents())
        .firstWhere((e) => e.id == widget.eventId, orElse: () => throw Exception('Evento no encontrado'));

    setState(() {
      titleController = TextEditingController(text: event.title);
      descriptionController = TextEditingController(text: event.description);
      locationController = TextEditingController(text: event.location);
      selectedDate = event.eventDate;
      selectedTime = TimeOfDay.fromDateTime(event.eventDate);
      isAllDay = event.isAllDay;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _updateEvent() async {
    final updatedEvent = EventModel(
      id: widget.eventId,
      title: titleController.text,
      description: descriptionController.text,
      eventDate: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
      location: locationController.text,
      isAllDay: isAllDay,
    );

    await eventRepository.updateEvent(updatedEvent);
    Navigator.of(context).pop(); // Volver a la vista anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Ubicación'),
            ),
            SwitchListTile(
              title: Text('Todo el día'),
              value: isAllDay,
              onChanged: (value) {
                setState(() {
                  isAllDay = value;
                });
              },
            ),
            ListTile(
              title: Text('Fecha: ${selectedDate.toLocal().toString().split(' ')[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            if (!isAllDay)
              ListTile(
                title: Text('Hora: ${selectedTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: _selectTime,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateEvent,
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
