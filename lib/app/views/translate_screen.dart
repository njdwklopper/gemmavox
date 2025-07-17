import 'package:flutter/material.dart';
import 'package:gemma_vox/domain/services/gemma_service.dart';
import '../../domain/locators.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemmaVox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TranslatePage(),
    );
  }
}

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final _gemma = getIt<GemmaService>();
  String _response = '';

  @override
  void initState() {
    super.initState();
    _gemma.setListener((token) {
      setState(() {
        _response += token;
      });
    });
    _gemma.sendPrompt('Translate "Hello" to Khmer.');
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
    super.dispose();
    _gemma.dispose();
  }
}
