import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gemma_vox/app/views/model_loader_screen.dart';
import 'package:gemma_vox/app/views/translate_screen.dart';
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return buildPageRoute(const LoadModelScreen());
          case '/home':
            return buildPageRoute(const HomeScreen());
          case '/conversation':
            return buildPageRoute(const TranslatePage());
          case '/voice_translator':
            return buildPageRoute(const TranslatePage());
          case '/phrasecards':
            return buildPageRoute(const TranslatePage());
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
      },
    );
  }
}

PageRoute buildPageRoute(Widget page) {
  if (Platform.isIOS) {
    return CupertinoPageRoute(builder: (_) => page);
  } else {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}