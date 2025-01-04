import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';

class SpeechRecognitionService {
  static const int _sampleRate = 16000;
  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance;
  final ModelLoader _modelLoader = ModelLoader();

  Recognizer? _recognizer;
  Model? _model;

  Future<Recognizer?> initializeModel(String? modelName) async {
    try {
      final modelsList = await _modelLoader.loadModelsList();
      final modelDescription = modelsList.firstWhere(
        (model) => model.name == modelName,
        orElse: () => throw Exception('Model $modelName not found'),
      );

      final modelPath = await _modelLoader.loadFromAssets(modelDescription.url);
      _model = await _vosk.createModel(modelPath);
      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: _sampleRate,
      );
      return _recognizer;
    } catch (e) {
      throw Exception('Error initializing model: $e');
    }
  }

  Future<String> processAudioFile(String inputPath) async {
    String outputPath = "${inputPath}_converted.wav";
    await _convertToPCM(inputPath, outputPath);

    final bytes = File(outputPath).readAsBytesSync();
    final recognitionResult = await _processAudioBytes(bytes);

    File(outputPath).deleteSync();
    return recognitionResult;
  }

  Future<void> _convertToPCM(String inputPath, String outputPath) async {
    FFMpegHelper ffmpeg = FFMpegHelper.instance;
    final cliCommand = FFMpegCommand(
      inputs: [FFMpegInput.asset(inputPath)],
      args: [
        const LogLevelArgument(LogLevel.info),
        const OverwriteArgument(),
        const CustomArgument(["-ar", "$_sampleRate", "-ac", "1", "-f", "wav"]),
      ],
      outputFilepath: outputPath,
    );
    await ffmpeg.runSync(cliCommand);
  }

  Future<String> _processAudioBytes(Uint8List audioBytes) async {
    const chunkSize = 8192;
    int pos = 0;

    while (pos + chunkSize < audioBytes.length) {
      await _recognizer!.acceptWaveformBytes(
        Uint8List.fromList(audioBytes.sublist(pos, pos + chunkSize)),
      );
      pos += chunkSize;
    }
    await _recognizer!.acceptWaveformBytes(
      Uint8List.fromList(audioBytes.sublist(pos)),
    );
    return _recognizer!.getFinalResult();
  }
}
