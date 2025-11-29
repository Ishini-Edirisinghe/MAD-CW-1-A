import 'package:flutter/material.dart';
import 'features/start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      home: const StartScreen(),
    );
  }
}
