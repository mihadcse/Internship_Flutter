import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/note.dart';

class NoteDatabase {
  static final NoteDatabase _singleton = NoteDatabase._internal();
  factory NoteDatabase() => _singleton;
  NoteDatabase._internal();

  Database? _db;
  final _store = intMapStoreFactory.store('notes');

  Future<Database> get database async {
    if (_db != null) return _db!;

    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('notes.db');
    } else {
      Directory appDir = await getApplicationDocumentsDirectory();
      String dbPath = '${appDir.path}/notes.db';
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }

    return _db!;
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final snapshots = await _store.find(db);
    return snapshots
        .map((snap) => Note.fromMap(snap.value, id: snap.key))
        .toList();
  }

  Future<int> insert(Note note) async {
    final db = await database;
    final key = await _store.add(db, note.toMap());
    return key; // the auto-generated ID
  }

  Future<void> delete(int id) async {
    final db = await database;
    await _store.record(id).delete(db);
  }

}
