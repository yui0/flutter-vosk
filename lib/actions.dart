import 'app_state.dart';

import 'package:flutter/foundation.dart'; // compute
import 'dart:isolate';
import 'dart:io'; // File
import 'dart:typed_data'; // for Uint8List
import 'dart:convert'; // json
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

const int _sampleRate = 16000; // 認識周波数
String? _modelName = 'vosk-model-small-en-us-0.15';
late final VoskFlutterPlugin _vosk;
late final ModelLoader _modelLoader;
List<String>? _availableModels; // 利用可能なモデルリスト

Future<void> initializeLibrary() async {
  try {
    _vosk = VoskFlutterPlugin.instance();
    _modelLoader = ModelLoader();
  } catch (e) {
    print('Error initializing Vosk library: $e');
  }
}

Future<Recognizer?> initializeModel(String? name) async {
  try {
    _modelName = name;
    print("Selected model: $name");

    // Load the list of models
    final modelsList = await _modelLoader.loadModelsList();
    //print("Available models: ${modelsList.map((model) => model.name).toList()}");
    //_availableModels = modelsList;

    // Find the specified model
    final modelDescription = modelsList.firstWhere(
      (model) => model.name == _modelName,
      orElse: () => throw Exception('Model $_modelName not found'),
    );

    // Load the model from the network
    print(modelDescription.url);
    //final modelPath = await _modelLoader.loadFromNetwork(modelDescription.url);
    final modelPath = await _modelLoader.loadFromAssets("assets/models/vosk-model-small-ja-0.22.zip");

    // Create the model object
    print(modelPath);
    final model = await _vosk.createModel(modelPath);
    //final spkModel = await _vosk.createSpeakerModel(await _modelLoader.loadFromAssets("assets/models/vosk-model-spk-0.4.zip"));

    // Create the recognizer
    final _recognizer = await _vosk.createRecognizer(
      model: model!,
      sampleRate: _sampleRate,
    );
    //await _vosk.setSpeakerModel(_recognizer, spkModel);
    return _recognizer;
  } catch (e, stackTrace) {
    print('Error during model initialization: $e');
    print(stackTrace);
    return null;
  }
}

// ffmpegでPCM形式に
Future<String> convertToPCM(String inputPath, String outputPath) async {
  FFMpegHelper ffmpeg = FFMpegHelper.instance;
  final FFMpegCommand cliCommand = FFMpegCommand(
    inputs: [
      FFMpegInput.asset(inputPath),
    ],
    args: [
      const LogLevelArgument(LogLevel.info),
      const OverwriteArgument(),
      const CustomArgument([
        "-ar", "$_sampleRate",
        "-ac", "1",
        "-f", "wav",
      ]),
    ],
    outputFilepath: outputPath,
  );

  await ffmpeg.runSync(
    cliCommand,
    statisticsCallback: (Statistics statistics) {
      print('bitrate: ${statistics.getBitrate()}');
    },
  );

  return outputPath;
}

// voskを使って認識
/*Stream<String> processAudioBytes(
    Uint8List audioBytes, dynamic recognizer, int chunkSize) async* {*/
Future<String> processAudioBytes(
    Uint8List audioBytes, dynamic recognizer, int chunkSize) async {
//Future<String> processAudioBytes(Uint8List audioBytes) async {
  //await initializeLibrary();
  //final recognizer = await initializeModel("vosk-model-small-ja-0.22");
  int chunkSize = 8192;
  if (recognizer == null) {
    print("Recognizer initialization failed.");
    return "Error: Recognizer initialization failed.";
  }

  String str = "";
  int pos = 0;
  while (pos + chunkSize <= audioBytes.length) {
    //print("pos: ${pos}");
    try {
      final resultReady = await recognizer.acceptWaveformBytes(
        Uint8List.fromList(audioBytes.sublist(pos, pos + chunkSize)),
      );
      pos += chunkSize;

      if (resultReady) {
        String jsonString = await recognizer.getResult();
        Map<String, dynamic> map = jsonDecode(jsonString);
        str += map['text'];
        print(str);
        //yield str;
      } else {
        final s = await recognizer.getPartialResult();
        print(s);
        FFAppState().infoState = s;
        FFAppState().notifyListeners();
      }
    } catch (e) {
      print("Error processing audio chunk: $e");
      break; // Exit the loop on error
    }
  }

  // Process the remaining audio
  if (pos < audioBytes.length) {
    try {
      await recognizer.acceptWaveformBytes(
        Uint8List.fromList(audioBytes.sublist(pos)),
      );
    } catch (e) {
      print("Error processing remaining audio: $e");
    }
  }

  return str + await recognizer.getFinalResult();
}

/*class IsolateData {
  final Uint8List audioBytes;
  final dynamic recognizer;
  final int chunkSize;
  IsolateData({
    required this.audioBytes,
    required this.recognizer,
    required this.chunkSize,
  });
}
Future<String> processAudioIsolate(IsolateData d) async {
  return processAudioBytes(d.audioBytes, d.recognizer!, d.chunkSize);
}*/
/*Future<dynamic> processAudioChunk(Map<String, dynamic> params) async {
  return await processAudioBytes(
    params['bytes'],
    params['recognizer'],
    params['chunkSize']
  );
}*/
/*final _recognizer = null;
Future<String> _processAudioIsolate(Uint8List bytes) async {
  int chunkSize = 8192;
  return await processAudioBytes(bytes, _recognizer!, chunkSize);
}*/
Future<void> pickAndRecognizeFile(/*_recognizer*/) async {
  try {
    // ファイルを選択
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      // PCM形式に変換
      String inputPath = result.files.single.path!;
      String outputPath = "${inputPath}_converted.wav";
      outputPath = await convertToPCM(inputPath, outputPath);

      // PCMデータを読み込む
      final audioBytes = File(outputPath).readAsBytesSync();

      // 音声認識ライブラリに渡す
      final _recognizer = await initializeModel("vosk-model-small-ja-0.22");
      /*_recognizer!.acceptWaveformBytes(audioBytes);
      final recognitionResult = await _recognizer!.getFinalResult();*/
      int chunkSize = 8192;
      //final recognitionResult = await processAudioBytes(audioBytes, _recognizer!, chunkSize);
      /*final recognitionResult = await compute(processAudioChunk, {
        'bytes': audioBytes,
        'recognizer': _recognizer!,
        'chunkSize': chunkSize
      });*/
      //final recognitionResult = await compute(_processAudioIsolate, audioBytes);
      //final recognitionResult = await compute(processAudioBytes, audioBytes);
      /*IsolateData isolateData = IsolateData(
        audioBytes: audioBytes,
        recognizer: _recognizer,
        chunkSize: chunkSize,
      );
      final recognitionResult = await compute(processAudioIsolate, isolateData);*/
      final recognitionResult = "";
      /*Stream<String> dataStream = processAudioBytes(audioBytes, _recognizer!, chunkSize);
      dataStream.listen(
        (data) {
          print("Received data: $data");
        },
        onDone: () {
          print("End of data stream");
        }
      );*/

      // 結果をUIに表示
      print(recognitionResult);
      FFAppState().resultState = recognitionResult;
      FFAppState().notifyListeners();

      // 一時ファイルを削除
      File(outputPath).deleteSync();
    } else {
      /*setState(() {
        _RecognitionResult = "No file selected.";
      });*/
    }
  } catch (e) {
    /*setState(() {
      _error = "Error processing file: $e";
    });*/
  }
}
void dataProcessingIsolate(SendPort sendPort) {
  sendPort.send("aaa");
}

Future<void> recognizeFileAction() async {
  print("recognizeFileAction...");
  FFAppState().infoState = "ファイルから認識中。。。";
  FFAppState().notifyListeners();
  await pickAndRecognizeFile();
}

Future<void> recognizeAction() async {
  print("recognizeAction");
  FFAppState().infoState = "認識中。。。";
  FFAppState().notifyListeners();

  final receivePort = ReceivePort();
  receivePort.listen((message) {
    print('Processed data: $message');
    receivePort.close();
  });
  await Isolate.spawn(dataProcessingIsolate, receivePort.sendPort);

  // ストリーミングデータのシミュレーション
  /*for (int i = 0; i < 10; i++) {
    receivePort.send(i); // データを送信
    await Future.delayed(Duration(seconds: 1)); // 1秒待機
  }*/
}

Future<void> aboutAction() async {
  print("aboutAction");
}

/*Future<void> setDarkModeSetting(context, theme) async {
}*/
