import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final savedName = prefs.getString('user_name');

  runApp(BursaApp(savedName: savedName));
}

class BursaApp extends StatelessWidget {
  final String? savedName;
  const BursaApp({super.key, this.savedName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BURSA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: savedName != null && savedName!.isNotEmpty
          ? HomeScreen(userName: savedName!)
          : const WelcomeScreen(),
    );
  }
}