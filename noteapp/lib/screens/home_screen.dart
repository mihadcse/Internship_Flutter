import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../providers/font_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Correct way: use ref.read() for one-time actions
    Future.microtask(() => ref.read(noteProvider.notifier).loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push('/settings'),
        ),
      ],
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(
                    note.title,
                    style: TextStyle(fontSize: fontSize),
                  ),
                  subtitle: Text(
                    note.content,
                    style: TextStyle(fontSize: fontSize),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref.read(noteProvider.notifier).deleteNote(note.id!);
                    },
                  ),
                  //hoverColor: const Color.fromARGB(255, 2, 8, 72),
                  //textColor: Colors.white,
                  onTap: () => context.push('/add', extra: note),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
