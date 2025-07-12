import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gemma_vox/domain/services/gemma_service.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemmaVox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TranslatePage(),
    );
  }
}

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String _response = '';
  late StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _subscription = GemmaService.instance.tokenStream.listen((token) {
      setState(() {
        _response += token;
      });
    });
    await GemmaService.instance.sendPrompt('Translate "Hello" to Khmer.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GemmaVox App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _response.isEmpty ? "Initializing..." : _response,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
