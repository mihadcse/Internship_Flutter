import 'package:flutter_riverpod/flutter_riverpod.dart';

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(16.0); // default font size

  void setFontSize(double size) {
    state = size;
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});
