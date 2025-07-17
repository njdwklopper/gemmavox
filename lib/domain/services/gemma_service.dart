import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:flutter_gemma/core/chat.dart';

class GemmaService {
  final FlutterGemmaPlugin _plugin = FlutterGemmaPlugin.instance;
  InferenceModel? _inferenceModel;
  InferenceChat? _chat;

  void Function(String)? _onTokenUpdate;
  StreamSubscription<String>? _tokenSubscription;

  GemmaService() {
    _initialize();
  }

  Future<void> _initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final modelPath = '${directory.path}/gemma-3n-E2B-it-int4.task';
    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      await _downloadFileWithProgress(modelPath);
    } else {
      await _loadModel(modelPath);
    }
  }

  Future<void> _downloadFileWithProgress(String modelPath) async {
    await dotenv.load(fileName: '.env');
    final huggingUrl = dotenv.env['HUGGING_URL']!;
    final huggingApiKey = dotenv.env['HUGGING_API']!;
    debugPrint('huggingface url: $huggingUrl');
    debugPrint('huggingface key: $huggingApiKey');
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(huggingUrl));
    request.headers['Authorization'] = 'Bearer $huggingApiKey';
    final response = await client.send(request);

    final contentLength = response.contentLength ?? 0;
    int downloaded = 0;
    final file = File(modelPath);
    final sink = file.openWrite();

    await for (final chunk in response.stream) {
      downloaded += chunk.length;
      sink.add(chunk);
      final progress = (downloaded / contentLength) * 100;
      _emit('Download progress: ${progress.toStringAsFixed(2)}%');
    }
    await sink.close();
    await _loadModel(modelPath);
  }

  Future<void> _loadModel(String filePath) async {
    debugPrint('Loading model on path: $filePath');
    await _plugin.modelManager.setModelPath(filePath);
    _inferenceModel = await _plugin.createModel(
      modelType: ModelType.gemmaIt,
      preferredBackend: PreferredBackend.gpuFull,
      maxTokens: 256,
      supportImage: false,
      maxNumImages: 0,
    );

    await _createSession();
    _emit('Download done: $filePath');
  }

  Future<void> sendPrompt(String prompt) async {
    _subToSessionTokensWithPrompt(prompt, (token) {
      _emit(token);
    });
  }

  Future<String> sendPromptForFullResponse(String prompt) async {
    final buffer = StringBuffer();
    _subToSessionTokensWithPrompt(prompt, (token) {
      buffer.write(token);
    });
    return buffer.toString();
  }

  void _subToSessionTokensWithPrompt(String prompt, void Function(String) update) async {
    if (_chat == null) await _createSession();
    await _chat?.addQueryChunk(Message(text: prompt, isUser: true));
    _tokenSubscription = _inferenceModel!.chat?.generateChatResponseAsync().listen(
      (token) {
        update(token);
      },
      onDone: () {
        _tokenSubscription = null;
      },
      onError: (err, stack) {
        _tokenSubscription = null;
        debugPrint('Error in token stream: $err');
      },
      cancelOnError: true,
    );
  }

  void _emit(String token) {
    _onTokenUpdate?.call(token);
  }

  void setListener(void Function(String) listener) {
    _onTokenUpdate = listener;
  }

  Future<void> _createSession() async {
    _chat = await _inferenceModel?.createChat(
      temperature: 0.3,
      randomSeed: 1,
      topK: 42,
      topP: 0.93,
      tokenBuffer: 256,
      supportImage: false,
    );
  }

  Future<void> dispose() async {
    await _chat?.session.close();
    await _chat?.clearHistory();
    await _tokenSubscription?.cancel();
    _onTokenUpdate = null;
    _tokenSubscription = null;
    _chat = null;
  }
}