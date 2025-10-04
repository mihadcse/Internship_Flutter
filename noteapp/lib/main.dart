import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/add_note_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';
import 'models/note.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/add', builder: (context, state)
    {
        final note = state.extra as Note?; // receive note if editing
        return AddNoteScreen(note: note);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    

    return MaterialApp.router(
      title: 'Note App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //scaffoldBackgroundColor: const Color.fromARGB(255, 97, 105, 223),
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 11, 236, 127)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
