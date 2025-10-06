import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../providers/comment_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailsScreen extends ConsumerWidget {
  final String? id;
  const NewsDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return const Scaffold(body: Center(child: Text('Invalid story ID')));
    }

    final newsAsync = ref.watch(singleNewsProvider(id!));

    return Scaffold(
      appBar: AppBar(title: const Text('News Details')),
      body: newsAsync.when(
        data: (story) {
          final kids = (story['kids'] as List?)?.cast<int>() ?? [];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                story['title'] ?? 'No title',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('By: ${story['by'] ?? 'Unknown author'}'),
              const SizedBox(height: 8),
              Text('Type: ${story['type'] ?? 'Unknown'}'),
              const SizedBox(height: 16),
              if (story['url'] != null)
                InkWell(
                  onTap: () async {
                    final Uri url = Uri.parse(story['url']);
                    if (!await launchUrl(
                      url,
                      mode:
                          LaunchMode.externalApplication, 
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open the link'),
                        ),
                      );
                    }
                  },

                  child: Text(
                    story['url'],
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Comments (${kids.length}):',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              if (kids.isEmpty) const Text('No comments yet.'),
              ...kids.map((commentId) {
                final commentAsync = ref.watch(
                  singleCommentProvider(commentId),
                );
                return commentAsync.when(
                  data: (comment) {
                    if (comment['deleted'] == true || comment['text'] == null) {
                      return const SizedBox.shrink();
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment['by'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _parseHtml(comment['text']),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Error loading comment: $e'),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  /// Hacker News comments are in simple HTML, so we remove tags like <p> or <i>.
  String _parseHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&');
  }
}
