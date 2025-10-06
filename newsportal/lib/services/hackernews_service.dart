import 'package:dio/dio.dart';
import '../database/news_database.dart';

class HackerNewsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://hacker-news.firebaseio.com/v0/'));
  final NewsDatabase _db = NewsDatabase();

  /// Fetch story IDs (e.g., topstories, newstories, beststories)
  Future<List<int>> fetchStoryIds(String category) async {
    try {
      // Try from API
      final response = await _dio.get('$category.json');
      return List<int>.from(response.data);
    } on DioException {
      // Offline fallback → use cached story IDs
      final cachedStories = await _db.getAllNews();
      if (cachedStories.isNotEmpty) {
        return cachedStories.map((e) => e['id'] as int).toList();
      } else {
        throw Exception('No internet and no cached stories found.');
      }
    }
  }

  /// Fetch single story
  Future<Map<String, dynamic>> fetchStoryItem(int id) async {
    try {
      // Try from API
      final response = await _dio.get('item/$id.json');
      final story = Map<String, dynamic>.from(response.data);

      // Cache it locally for offline use
      await _db.insertOrUpdateNews(story);
      return story;
    } on DioException {
      // Offline fallback → use cached story
      final localData = await _db.getNewsById(id);
      if (localData != null) {
        return localData;
      } else {
        throw Exception('Offline and story $id not found in cache.');
      }
    }
  }

  /// Get all locally cached stories
  Future<List<Map<String, dynamic>>> getAllLocalNews() async {
    return await _db.getAllNews();
  }

  /// Optional — clear all cache
  Future<void> clearCache() async {
    await _db.clearAllNews();
  }
}
