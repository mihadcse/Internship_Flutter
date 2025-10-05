import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';

class NewsDetailsScreen extends ConsumerWidget {
  final String? id;
  const NewsDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid story ID')),
      );
    }

    final newsAsync = ref.watch(singleNewsProvider(id!));

    return Scaffold(
      appBar: AppBar(title: const Text('News Details')),
      body: newsAsync.when(
        data: (story) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                story['title'] ?? 'No title',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('By: ${story['by'] ?? 'Unknown author'}'),
              const SizedBox(height: 8),
              Text('Type: ${story['type'] ?? 'Unknown'}'),
              const SizedBox(height: 16),
              if (story['url'] != null)
                Text(
                  story['url'],
                  style: const TextStyle(color: Colors.blue),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
