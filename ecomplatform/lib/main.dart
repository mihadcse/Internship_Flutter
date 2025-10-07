
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ugsqkjskozyplkqaqtxx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnc3FranNrb3p5cGxrcWFxdHh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3MjI5NzksImV4cCI6MjA3NTI5ODk3OX0.YdPDzDBLbxLa_PiVj7YIOM8ed20F2Zs7r-Tcx5Yfbv4',
  );
  print("Supabase initialized");

  // ✅ Listen for password recovery event
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    if (event == AuthChangeEvent.passwordRecovery) {
      // Force navigation to reset-password page
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
