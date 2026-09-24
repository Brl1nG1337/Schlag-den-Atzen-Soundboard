import 'package:flutter/material.dart';

import 'screens/soundboard_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const SoundboardApp());

class SoundboardApp extends StatelessWidget {
  const SoundboardApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Schlag den Atzen Soundboard',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const SoundboardScreen(),
  );
}
