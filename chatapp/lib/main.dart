// import 'package:flutter/material.dart';
// import 'screens/splash_screen.dart';
// import 'services/chat_manager.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Local Chat App",
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'NotoSans',
//         fontFamilyFallback: const ['NotoEmoji'],
//         useMaterial3: true,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Local Chat App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
        fontFamilyFallback: const ['NotoEmoji'],
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}