class EventModel {
  final String id; // Identificador único para el evento
  String title; // Título del evento
  String description; // Descripción del evento
  DateTime eventDate; // Fecha y hora del evento
  String location; // Ubicación del evento
  bool isAllDay; // Si el evento dura todo el día (opcional)
  
  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.isAllDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
      'isAllDay': isAllDay,
    };
  }

  // Método para crear una instancia de EventModel desde un mapa
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      eventDate: DateTime.parse(map['eventDate']),
      location: map['location'] ?? '',
      isAllDay: map['isAllDay'] ?? false,
    );
  }
}
