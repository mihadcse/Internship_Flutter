import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/font_provider.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  final Note? note;
  const AddNoteScreen({super.key, this.note});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  // final _titleController = TextEditingController();
  // final _contentController = TextEditingController();

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing note if editing
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(fontSizeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              style: TextStyle(fontSize: fontSize),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedNote = Note(
                  id: widget.note?.id, // keep existing id if editing
                  title: _titleController.text,
                  content: _contentController.text,
                  createdAt: widget.note?.createdAt ?? DateTime.now(),
                );

                final noteNotifier = ref.read(noteProvider.notifier);

                if (widget.note == null) {
                  // Add new note
                  await noteNotifier.addNote(updatedNote);
                } else {
                  // Update existing note
                  await noteNotifier.updateNote(updatedNote);
                }

                context.pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
