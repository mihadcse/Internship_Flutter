import '../db/note_database.dart';
import '../models/note.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});

class NoteNotifier extends StateNotifier<List<Note>> {
  final _db = NoteDatabase();
  final _store = intMapStoreFactory.store('notes');

  NoteNotifier() : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = await _db.getNotes();
  }

  Future<void> addNote(Note note) async {
    final id = await _db.insert(note); // get Sembast key
    await loadNotes(); // reload notes
  }

  Future<void> deleteNote(int id) async {
    await _db.delete(id);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    final db = await _db.database; 
    await _store.record(note.id!).update(db, note.toMap());
    await loadNotes(); 
  }
}
