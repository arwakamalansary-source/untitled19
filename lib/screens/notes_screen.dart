
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/notes_cubit.dart';
import '../cubits/notes_state.dart';
import '../models/note_model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void showNoteDialog({NoteModel? note}) {
    titleController.text = note?.title ?? '';
    descriptionController.text = note?.description ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  showMessage('Please enter a title');
                  return;
                }

                final title = titleController.text;
                final description = descriptionController.text;

                Navigator.pop(dialogContext);

                if (note == null) {
                  await context.read<NotesCubit>().addNote(
                    title,
                    description,
                  );
                } else {
                  await context.read<NotesCubit>().updateNote(
                    note.id,
                    title: title,
                    description: description,
                  );
                }
              },
              child: Text(note == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(NoteModel note) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text(
            'Are you sure you want to delete this note?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NotesCubit>().deleteNote(note.id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesCubit, NotesState>(
      listener: (context, state) {
        if (state.message != null) {
          showMessage(state.message!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Notes'),
            centerTitle: true,
          ),
          body: state.status == NotesStatus.loading &&
              state.notes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.status == NotesStatus.error &&
              state.notes.isEmpty
              ? Center(
            child: Text(
              state.message ?? 'Something went wrong',
            ),
          )
              : state.notes.isEmpty
              ? const Center(child: Text('No notes yet'))
              : ListView.builder(
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              final note = state.notes[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: note.isDone,
                    onChanged: (value) {
                      context.read<NotesCubit>().updateNote(
                        note.id,
                        isDone: value ?? false,
                      );
                    },
                  ),
                  title: Text(
                    note.title,
                    style: TextStyle(
                      decoration: note.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(note.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showNoteDialog(note: note);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          confirmDelete(note);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showNoteDialog(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
