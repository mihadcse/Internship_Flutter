import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env from assets for Flutter Web and mobile
  await dotenv.load(fileName: "assets/.env");

  // Safely get environment variables
  final url = dotenv.env['URL'];
  final anonKey = dotenv.env['ANON_KEY'];

  if (url == null || anonKey == null) {
    throw Exception("Missing Supabase environment variables in assets/.env");
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
  );

  print("✅ Supabase initialized successfully");

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    if (event == AuthChangeEvent.passwordRecovery) {
      appRouter.go('/reset-password');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'E-commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: appRouter,
    );
  }
}
