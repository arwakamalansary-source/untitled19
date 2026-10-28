
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note_model.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(const NotesState()) {
    loadNotes();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? subscription;

  CollectionReference<Map<String, dynamic>> get notesCollection =>
      firestore.collection('notes');

  void loadNotes() {
    emit(state.copyWith(status: NotesStatus.loading));

    subscription = notesCollection.snapshots().listen(
          (snapshot) {
        final notes = snapshot.docs.map((doc) {
          return NoteModel.fromMap(doc.data(), doc.id);
        }).toList();

        emit(state.copyWith(
          status: NotesStatus.success,
          notes: notes,
          message: null,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          status: NotesStatus.error,
          message: error.toString(),
        ));
      },
    );
  }

  Future<void> addNote(String title, String description) async {
    if (title.trim().isEmpty) {
      emit(state.copyWith(
        status: NotesStatus.error,
        message: 'Title cannot be empty',
      ));
      return;
    }

    emit(state.copyWith(status: NotesStatus.loading, message: null));

    try {
      final note = NoteModel(
        id: '',
        title: title.trim(),
        description: description.trim(),
      );

      await notesCollection.add(note.toMap());

      emit(state.copyWith(
        status: NotesStatus.success,
        message: 'Note added successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotesStatus.error,
        message: e.toString(),
      ));
    }
  }

  Future<void> updateNote(
      String id, {
        String? title,
        String? description,
        bool? isDone,
      }) async {
    if (title != null && title.trim().isEmpty) {
      emit(state.copyWith(
        status: NotesStatus.error,
        message: 'Title cannot be empty',
      ));
      return;
    }

    emit(state.copyWith(status: NotesStatus.loading, message: null));

    try {
      final data = <String, dynamic>{};

      if (title != null) data['title'] = title.trim();
      if (description != null) {
        data['description'] = description.trim();
      }
      if (isDone != null) data['isDone'] = isDone;

      await notesCollection.doc(id).update(data);

      emit(state.copyWith(
        status: NotesStatus.success,
        message: 'Note updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotesStatus.error,
        message: e.toString(),
      ));
    }
  }

  Future<void> deleteNote(String id) async {
    emit(state.copyWith(status: NotesStatus.loading, message: null));

    try {
      await notesCollection.doc(id).delete();

      emit(state.copyWith(
        status: NotesStatus.success,
        message: 'Note deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotesStatus.error,
        message: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
