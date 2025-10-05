import 'package:dio/dio.dart';
import '../database/news_database.dart';

class HackerNewsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://hacker-news.firebaseio.com/v0/'));
  final NewsDatabase _db = NewsDatabase();

  Future<List<int>> fetchStoryIds(String category) async {
    final response = await _dio.get('$category.json');
    return List<int>.from(response.data);
  }

  Future<Map<String, dynamic>> fetchStoryItem(int id) async {
    // Step 1: Check local DB first
    final localData = await _db.getNewsById(id);
    if (localData != null) {
      return localData;
    }

    // Step 2: Fetch from API if not found locally
    final response = await _dio.get('item/$id.json');
    final story = response.data;

    // Step 3: Save to local DB for caching
    if (story != null) {
      await _db.insertOrUpdateNews(Map<String, dynamic>.from(story));
    }

    return story;
  }

  Future<List<Map<String, dynamic>>> getAllLocalNews() async {
    return await _db.getAllNews();
  }
}