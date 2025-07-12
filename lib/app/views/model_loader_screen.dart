import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gemma_vox/domain/services/gemma_service.dart';

class LoadModelScreen extends StatefulWidget {
  const LoadModelScreen({super.key});

  @override
  State<LoadModelScreen> createState() => _LoadModelScreenState();
}

const greeting = 'Create a greeting in any language you know. '
    'Each time you are asked, choose a different language and '
    'provide only one word along with the corresponding '
    'country’s emoji flag. For example, "Hello 🇬🇧".';

class _LoadModelScreenState extends State<LoadModelScreen> {
  String _response = '';
  late StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _subscription = GemmaService.instance.tokenStream.listen((progress) {
      setState(() {
        _response = progress;
        if (progress.contains("done")){
          _completeDownload();
          _subscription.cancel();
        }
      });
    });
    await GemmaService.instance.initialize();
  }

  _completeDownload() async {
    _updateResponse(await GemmaService.instance.getPromptAndFullResponse(greeting));

    Future.delayed(const Duration(seconds: 5), () {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Center(child: Text(_response, style: const TextStyle(fontSize: 18))),
    );
  }

  _updateResponse(String response) {
    setState(() {
      _response = response;
    });
  }
}
