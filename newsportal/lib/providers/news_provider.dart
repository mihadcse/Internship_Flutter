import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hackernews_service.dart';

final hackerNewsServiceProvider = Provider((ref) => HackerNewsService());

final newsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  final service = ref.watch(hackerNewsServiceProvider);
  final ids = await service.fetchStoryIds(category);
  final first20 = ids.take(20).toList(); // Limit to 20 stories
  final stories = await Future.wait(first20.map(service.fetchStoryItem));
  return stories.where((story) => story['title'] != null).toList();
});

final singleNewsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final service = ref.watch(hackerNewsServiceProvider);
  final story = await service.fetchStoryItem(int.parse(id));
  return story;
});

final localNewsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(hackerNewsServiceProvider);
  return service.getAllLocalNews();
});
