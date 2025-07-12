import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GemmaService {
  final FlutterGemmaPlugin _plugin = FlutterGemmaPlugin.instance;
  late InferenceModel? _inferenceModel;

  GemmaService._privateConstructor();

  static final GemmaService _instance = GemmaService._privateConstructor();
  static GemmaService get instance => _instance;

  InferenceModelSession? _session;

  final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();

  Stream<String> get tokenStream => _tokenStreamController.stream;

  initialize() async {
    await dotenv.load(fileName: '.env');
    final huggingUrl = dotenv.env['HUGGING_URL']!;
    final huggingApiKey = dotenv.env['HUGGING_API']!;
    debugPrint('huggingface url: $huggingUrl');
    debugPrint('huggingface key: $huggingApiKey');

    final directory = await getApplicationDocumentsDirectory();
    final modelPath = '${directory.path}/gemma-3n-E2B-it-int4.task';

    final modelFile = File(modelPath);
    if (!await modelFile.exists() || await modelFile.length() < 1024 * 1024 * 50) {
      downloadFileWithProgress(huggingUrl, modelPath, huggingApiKey);
    } else {
      _loadModel(modelPath);
    }
  }

  Future<void> downloadFileWithProgress(String url, String modelPath, String token) async {
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    final response = await client.send(request);

    final contentLength = response.contentLength ?? 0;
    int downloaded = 0;

    final file = File(modelPath);
    final sink = file.openWrite();

    response.stream.listen(
          (List<int> chunk) {
        downloaded += chunk.length;
        sink.add(chunk);
        final progress = (downloaded / contentLength) * 100;
        _tokenStreamController.add('Download progress: ${progress.toStringAsFixed(2)}%');
      },
      onDone: () async {
        await sink.close();
        _loadModel(modelPath);
      },
      onError: (e) {
        _tokenStreamController.add('Download error: $e');
      },
      cancelOnError: true,
    );
  }

  _loadModel(String filePath) async {
    print(filePath);
    await _plugin.modelManager.setModelPath(filePath);
    _inferenceModel = await _plugin.createModel(
      modelType: ModelType.gemmaIt,
      preferredBackend: PreferredBackend.gpuFull,
      maxTokens: 256,
      supportImage: false,
      maxNumImages: 0,
    );
    await createSession();
    _tokenStreamController.add('Download done: $filePath');
  }

  createSession() async {
    if (_inferenceModel != null && _session == null) {
      _session = await _inferenceModel!.createSession();
    }
    if (_inferenceModel == null) {
      throw Exception('Inference model is not initialized.');
    }
  }

  closeSession() async {
    if (_session != null) {
      await _session!.close();
      _session = null;
    }
  }

  Future<void> sendPrompt(String prompt) async {
    if (_session != null) {
      await _session!.addQueryChunk(Message(text: prompt, isUser: true));
      await for (final token in _session!.getResponseAsync()) {
        _tokenStreamController.add(token);
      }
    } else {
      throw Exception('Session is not initialized.');
    }
  }

  Future<String> getPromptAndFullResponse(String prompt) async {
    if (_session != null) {
      final buffer = StringBuffer();
      await _session!.addQueryChunk(Message(text: prompt, isUser: true));

      await for (final token in _session!.getResponseAsync()) {
        buffer.write(token);
      }
      return buffer.toString();
    } else {
      throw Exception('Session is not initialized.');
    }
  }

  Future<void> clear() async {
    await tokenStream.drain();
    await _tokenStreamController.close();
  }

  Future<void> dispose() async {
    closeSession();
    await _inferenceModel?.close();
    _inferenceModel = null;
    clear();
  }
}
