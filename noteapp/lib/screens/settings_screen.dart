// import 'package:flutter/material.dart';
// import '../providers/theme_provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class SettingsScreen extends ConsumerWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
//           child: Text(
//             themeMode == ThemeMode.light ? 'Switch to Dark Theme' : 'Switch to Light Theme',
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/font_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Theme toggle button
            ElevatedButton(
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              child: Text(
                themeMode == ThemeMode.light ? 'Switch to Dark Theme' : 'Switch to Light Theme',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            const SizedBox(height: 40),

            // Font size slider
            Text('Font Size: ${fontSize.toStringAsFixed(1)}', style: TextStyle(fontSize: fontSize)),
            Slider(
              value: fontSize,
              min: 12,
              max: 40,
              divisions: 28,
              label: fontSize.toStringAsFixed(1),
              onChanged: (value) {
                ref.read(fontSizeProvider.notifier).setFontSize(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

