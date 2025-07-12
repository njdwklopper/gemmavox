import 'package:flutter/material.dart';
import 'package:gemma_vox/app/views/model_loader_screen.dart';
import 'app/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemmaVox',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadModelScreen(),
        '/home': (context) => const HomeScreen(),
        '/conversation': (context) => const HomeScreen(),
        '/translator': (context) => const HomeScreen(), // One more idea, copy and "share" any text to app for translation quickly
        '/phrasecards': (context) => const HomeScreen(),
      },
    );
  }
}