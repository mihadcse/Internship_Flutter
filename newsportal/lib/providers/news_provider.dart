import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hackernews_service.dart';

final hackerNewsServiceProvider = Provider((ref) => HackerNewsService());

/// Fetches category-wise stories (Top, New, Best)
final newsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  final service = ref.watch(hackerNewsServiceProvider);

  try {
    final ids = await service.fetchStoryIds(category);
    final first20 = ids.take(20).toList();
    final stories = await Future.wait(first20.map(service.fetchStoryItem));
    return stories.where((story) => story['title'] != null).toList();
  } catch (e) {
    // If network & cache both fail, fallback to local cache
    final cached = await service.getAllLocalNews();
    if (cached.isNotEmpty) {
      return cached;
    }
    rethrow;
  }
});

/// Fetch single story by ID
final singleNewsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final service = ref.watch(hackerNewsServiceProvider);

  try {
    final story = await service.fetchStoryItem(int.parse(id));
    return story;
  } catch (e) {
    // Fallback to local cache
    final cached = await service.getAllLocalNews();
    final localStory = cached.firstWhere(
      (s) => s['id'].toString() == id,
      orElse: () => {'error': 'Story not available offline'},
    );
    return localStory;
  }
});

/// Loads all locally cached news directly
final localNewsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(hackerNewsServiceProvider);
  return service.getAllLocalNews();
});
