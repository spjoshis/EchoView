import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cam_star/screens/mode_selection_screen.dart';
import 'package:cam_star/theme/app_theme.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide status bar for better camera view
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );

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
