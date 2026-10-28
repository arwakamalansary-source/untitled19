
class NoteModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}
