import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen/MainScreen.dart';
import 'screen/SettingScreen.dart';

void main() {
  runApp(HelperApp());
}

class HelperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helper Genai',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2E2B3F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3B2A5A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.white70),
          displaySmall: TextStyle(color: Colors.white60),
          headlineLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: Colors.white70),
          headlineSmall: TextStyle(color: Colors.white60),
          titleLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white70),
          titleSmall: TextStyle(color: Colors.white60),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
          bodySmall: TextStyle(color: Colors.white38),
          labelLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: Colors.white70),
          labelSmall: TextStyle(color: Colors.white60),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A4B8A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF3A334D),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadApiKey(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return MainScreen();
          } else {
            return SettingScreen();
          }
        }
      },
    );
  }

  Future<String?> _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiKey');
  }
}
