import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/news_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = ref.watch(newsProvider('topstories'));
    final newStories = ref.watch(newsProvider('newstories'));
    final best = ref.watch(newsProvider('beststories'));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Hacker News Portal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/top'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Top Stories'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.go('/new'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('New Stories'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.go('/best'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Best Stories'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Expanded list area
            Expanded(
              child: top.when(
                data: (topStories) {
                  return newStories.when(
                    data: (newStoriesData) {
                      return best.when(
                        data: (bestStories) {
                          // Merge all 3
                          final allStories = [
                            ...topStories,
                            ...newStoriesData,
                            ...bestStories,
                          ];

                          // Remove duplicates
                          final uniqueStories = {
                            for (var s in allStories) s['id']: s,
                          }.values.toList();

                          return ListView.builder(
                            itemCount: uniqueStories.length,
                            itemBuilder: (context, index) {
                              final story = uniqueStories[index];
                              return ListTile(
                                title: Text(story['title'] ?? 'No title'),
                                subtitle: Text(story['by'] ?? 'Unknown author'),
                                onTap: () {
                                  final id = story['id'].toString();
                                  context.go('/$id');
                                },
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
