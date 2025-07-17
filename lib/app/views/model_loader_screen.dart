import 'package:flutter/material.dart';
import 'package:gemma_vox/domain/services/gemma_service.dart';
import '../../domain/locators.dart';

class LoadModelScreen extends StatefulWidget {
  const LoadModelScreen({super.key});

  @override
  State<LoadModelScreen> createState() => _LoadModelScreenState();
}

class _LoadModelScreenState extends State<LoadModelScreen> {
  final _gemma = getIt<GemmaService>();
  String _response = '';

  @override
  void initState() {
    super.initState();
    _gemma.setListener((token) {
      setState(() {
        _response = token;
        if (token.contains("done")){
          _completeDownload();
        }
      });
    });
  }

  _completeDownload() async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Center(child: Text(_response, style: const TextStyle(fontSize: 18))),
    );
  }
}
