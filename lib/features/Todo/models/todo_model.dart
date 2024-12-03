class TodoModel {
  String id;
  String title;
  bool isCompleted;
  DateTime date; // Campo para la fecha

  TodoModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date, // Aseguramos que la fecha se pase en el constructor
  });
}
