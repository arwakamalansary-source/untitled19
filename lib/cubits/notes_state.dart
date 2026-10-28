
import '../models/note_model.dart';

enum NotesStatus {
  initial,
  loading,
  success,
  error,
}

class NotesState {
  final NotesStatus status;
  final List<NoteModel> notes;
  final String? message;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.message,
  });

  NotesState copyWith({
    NotesStatus? status,
    List<NoteModel>? notes,
    String? message,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      message: message,
    );
  }
}
