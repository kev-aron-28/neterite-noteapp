import 'package:neterite/features/Subject/model/subject_model.dart';

class InMemorySubjectRepository {
  final Map<String, Subject> _storage = {};

  InMemorySubjectRepository._privateConstructor();

  static final InMemorySubjectRepository _instance =
      InMemorySubjectRepository._privateConstructor();

  factory InMemorySubjectRepository() {
    return _instance;
  }

  void addSubject(Subject subject) {
    _storage[subject.id] = subject;
  }

  Subject? getSubject(String id) {
    return _storage[id];
  }

  List<Subject> getAllSubjects() {
    return _storage.values.toList();
  }

  void updateSubject(String id, Subject updatedSubject) {
    if (_storage.containsKey(id)) {
      _storage[id] = updatedSubject;
    } else {
      throw Exception('Subject with id "$id" not found');
    }
  }
  void deleteSubject(String id) {
    if (_storage.containsKey(id)) {
      _storage.remove(id);
    } else {
      throw Exception('Subject with id "$id" not found');
    }
  }
}
