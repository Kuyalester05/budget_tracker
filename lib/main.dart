import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BursaApp());
}

class BursaApp extends StatelessWidget {
  const BursaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BURSA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const WelcomeScreen(),
    );
  }
}