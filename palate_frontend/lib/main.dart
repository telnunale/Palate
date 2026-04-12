import 'package:flutter/material.dart';
import 'views/login_view.dart';

void main() {
  runApp(const PalateApp());
}

class PalateApp extends StatelessWidget {
  const PalateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDF6EE),
        colorSchemeSeed: const Color(0xFFB85C38),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF5A5A5A),
          ),
        ),
      ),
      home: const LoginView(),
    );
  }
}
