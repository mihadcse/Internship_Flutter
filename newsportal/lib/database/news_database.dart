import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

class NewsDatabase {
  static final NewsDatabase _singleton = NewsDatabase._internal();
  factory NewsDatabase() => _singleton;
  NewsDatabase._internal();

  Database? _db;
  final _store = intMapStoreFactory.store('news_store');

  Future<Database> get database async {
    if (_db != null) return _db!;
    // ✅ Use browser IndexedDB via sembast_web
    _db = await databaseFactoryWeb.openDatabase('news_web.db');
    return _db!;
  }

  Future<void> insertOrUpdateNews(Map<String, dynamic> story) async {
    final db = await database;
    final id = story['id'];
    story['cachedAt'] = DateTime.now().toIso8601String();
    await _store.record(id).put(db, story, merge: true);
  }

  Future<Map<String, dynamic>?> getNewsById(int id) async {
    final db = await database;
    return await _store.record(id).get(db) as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getAllNews() async {
    final db = await database;
    final records = await _store.find(db);
    return records.map((e) => e.value as Map<String, dynamic>).toList();
  }

  Future<void> clearAllNews() async {
    final db = await database;
    await _store.delete(db);
  }
}
