import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import 'package:go_router/go_router.dart';

class NewsListScreen extends ConsumerWidget {
  final String category;
  const NewsListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider(category));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${category.replaceAll("stories", " Stories").toUpperCase()}',
        ),
      ),
      body: newsAsync.when(
        data: (stories) => ListView.builder(
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            return ListTile(
              title: Text(story['title'] ?? 'No title'),
              subtitle: Text(story['by'] ?? 'Unknown author'),
              onTap: () {
                final id = story['id'].toString();
                context.go('/$id');
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
