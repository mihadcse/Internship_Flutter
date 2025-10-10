import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/message.dart';

class SembastDB {
  static final SembastDB _instance = SembastDB._internal();
  factory SembastDB() => _instance;
  SembastDB._internal();

  Database? _db;
  final _store = intMapStoreFactory.store('messages');

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('chat_app');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, 'chat_app.db');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }
    return _db!;
  }

  Future<void> insertMessageWithSession(Message msg) async {
    final db = await database;
    await _store.add(db, msg.toMap());
  }

  Future<List<Map<String, dynamic>>> getMessagesBySession(String sessionId, {int limit = 50}) async {
    final db = await database;
    final finder = Finder(
      filter: Filter.equals('sessionId', sessionId),
      sortOrders: [SortOrder('timestamp')],
      limit: limit,
    );
    final records = await _store.find(db, finder: finder);
    return records.map((e) => e.value).toList();
  }

  Future<List<String>> getAllSessionIds() async {
    final db = await database;
    final records = await _store.find(db);
    final sessionIds = records.map((e) => e.value['sessionId'].toString()).toSet();
    return sessionIds.toList();
  }
}

