import 'package:flutter/material.dart';
import 'package:cam_star/screens/mode_selection_screen.dart';
import 'package:cam_star/theme/app_theme.dart';

void main() {
  runApp(const CamStarApp());
}

/// CamStar - Local Network Camera Streaming Application
class CamStarApp extends StatelessWidget {
  /// Creates the CamStar application
  const CamStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CamStar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ModeSelectionScreen(),
    );
  }
}
