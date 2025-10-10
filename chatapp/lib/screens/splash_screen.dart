import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to ChatScreen after full animation
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const ChatScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of your image assets
    final images = [
      '../assets/ollama.png',
      '../assets/ollamablack.png',
      '../assets/text.png',
    ];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash Text Animation
            Text(
              "🧠 Local AI Chat",
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold),
            ).animate()
              .fadeIn(duration: 800.ms)
              .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 1400.ms)
              .then(delay: 500.ms)
              .fadeOut(duration: 800.ms),

            const SizedBox(height: 30),

            // Images in the same place
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < images.length; i++)
                    Image.asset(images[i])
                        .animate()
                        .fadeIn(duration: 600.ms, delay: (i * 1000).ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          delay: (i * 1000).ms,
                        )
                        .fadeOut(duration: 400.ms, delay: (i * 1000 + 600).ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
