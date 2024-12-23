import 'dart:io';
import 'dart:typed_data'; // for Uint8List
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';

import 'package:record/record.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

const _sampleRate = 16000; // 認識周波数

void main() async {
  await FFMpegHelper.instance.initialize(); // for ffmpeg
  runApp(const MyApp());  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),*/
      home: KotoriMemo(),
    );
  }
}

class KotoriMemo extends StatefulWidget {
  const KotoriMemo({Key? key}) : super(key: key);

  @override
  State<KotoriMemo> createState() => _KotoriMemoState();
}

class _KotoriMemoState extends State<KotoriMemo> {
  static const _textStyle = TextStyle(fontSize: 18, color: Colors.black);

  //static const _modelName = 'vosk-model-small-en-us-0.15';
  String? _modelName = 'vosk-model-small-en-us-0.15';
  List? _availableModels; // 利用可能なモデルリスト

  final _vosk = VoskFlutterPlugin.instance();
  final _modelLoader = ModelLoader();
  //final _recorder = Record();

  String? _fileRecognitionResult;
  String? _error;
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;

  bool _recognitionStarted = false;

  // 音声認識モデル
  Future<Recognizer?> _initializeModel(String? name) async {
    try {
      _modelName = name;
      _modelLoader
        .loadModelsList()
        .then((modelsList) {
          print("Available models: ${modelsList.map((model) => model.name).toList()}");
          _availableModels = modelsList;
          return modelsList.firstWhere(
            (model) => model.name == _modelName,
            orElse: () => throw Exception('Model $_modelName not found'),
          );
        })
        .then((modelDescription) =>
          _modelLoader.loadFromNetwork(modelDescription.url)) // load model
        .then(
          (modelPath) => _vosk.createModel(modelPath)) // create model object
        .then((model) => setState(() => _model = model))
        .then((_) => _vosk.createRecognizer(
          model: _model!, sampleRate: _sampleRate)) // create recognizer
        .then((value) => _recognizer = value);

      print("Selected model: $name");
      return _recognizer;
    } catch (e) {
      print('Error during model initialization: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _initializeModel(_modelName).then((recognizer) {
      if (Platform.isAndroid) {
        /*final speechService = await _vosk.initSpeechService(recognizer);
        speechService.onPartial().forEach((partial) => print(partial));
        speechService.onResult().forEach((result) => print(result));
        await speechService.start();*/
        _vosk
            .initSpeechService(_recognizer!) // init speech service
            .then((speechService) =>
                setState(() => _speechService = speechService))
            .catchError((e) => setState(() => _error = e.toString()));
      }
    }).catchError((e, stacktrace) {
      setState(() => _error = e.toString());
      print('Exception: '+e.toString());
      print('Stacktrace: '+stacktrace.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
          body: Center(child: Text("[Error] $_error", style: _textStyle)));
    } else if (_model == null) {
      return const Scaffold(
          body: Center(child: Text("Loading model...", style: _textStyle)));
    } else if (Platform.isAndroid && _speechService == null) {
      return const Scaffold(
        body: Center(
          child: Text("Initializing speech service...", style: _textStyle),
        ),
      );
    } else {
      return Platform.isAndroid ? _androidExample() : _commonExample();
    }
  }

  Widget _androidExample() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async {
                  if (_recognitionStarted) {
                    await _speechService!.stop();
                  } else {
                    await _speechService!.start();
                  }
                  setState(() => _recognitionStarted = !_recognitionStarted);
                },
                child: Text(_recognitionStarted
                    ? "Stop recognition"
                    : "Start recognition")),
            StreamBuilder(
                stream: _speechService!.onPartial(),
                builder: (context, snapshot) => Text(
                    "Partial result: ${snapshot.data.toString()}",
                    style: _textStyle)),
            StreamBuilder(
                stream: _speechService!.onResult(),
                builder: (context, snapshot) => Text(
                    "Result: ${snapshot.data.toString()}",
                    style: _textStyle)),
          ],
        ),
      ),
    );
  }

  // ボタン
  Widget _buildButton(
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        /*primary: Colors.blueAccent,
        onPrimary: Colors.white,*/
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // メイン画面
  Widget _commonExample() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kotori Memo",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                /*Text(
                  "Welcome to Kotori Memo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),*/
                const SizedBox(height: 10),
                const Text(
                  "Select a model, record audio, or upload a file to begin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _modelName,
                  items: _availableModels!.map((model) {
                    return DropdownMenuItem<String>(
                      value: model.name,
                      child: Text(model.name),
                    );
                  }).toList(),
                  onChanged: (String? newModel) async {
                    if (newModel != null && newModel != _modelName) {
                      setState(() => _modelName = newModel);
                      await _initializeModel(newModel);
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildButton(
                  icon: Icons.upload_file,
                  label: "Upload and Recognize Audio",
                  onPressed: _pickAndRecognizeFile,
                ),
                const SizedBox(height: 15),
                _buildButton(
                  icon: _recognitionStarted ? Icons.stop : Icons.mic,
                  label: _recognitionStarted ? "Stop Recording" : "Record Audio",
                  onPressed: () {
                    setState(() {
                      _recognitionStarted = !_recognitionStarted;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (_fileRecognitionResult != null)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Recognition Result:\n$_fileRecognitionResult",
                        style: _textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      /*body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _modelName,
              items: _availableModels!.map((model) {
                return DropdownMenuItem<String>(
                  value: model.name,
                  child: Text(model.name),
                );
              }).toList(),
              onChanged: (String? newModel) => _initializeModel(newModel),
            ),
            ElevatedButton(
              onPressed: _pickAndRecognizeFile,
              child: const Text("Upload and Recognize Audio"),
            ),
            if (_fileRecognitionResult != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Recognition Result:\n$_fileRecognitionResult",
                  style: _textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
                onPressed: () async {
                  if (_recognitionStarted) {
                    await _stopRecording();
                  } else {
                    await _recordAudio();
                  }
                  setState(() => _recognitionStarted = !_recognitionStarted);
                },
                child: Text(
                    _recognitionStarted ? "Stop recording" : "Record audio")),
            Text("Final recognition result: $_fileRecognitionResult",
                style: _textStyle),
          ],
        ),
      ),*/
    );
  }

  Future<void> _recordAudio() async {
    /*try {
      await _recorder.start(
          samplingRate: 16000, encoder: AudioEncoder.wav, numChannels: 1);
    } catch (e) {
      _error = e.toString() +
          '\n\n Make sure fmedia(https://stsaz.github.io/fmedia/)'
              ' is installed on Linux';
    }*/
  }

  Future<void> _stopRecording() async {
    /*try {
      final filePath = await _recorder.stop();
      if (filePath != null) {
        final bytes = File(filePath).readAsBytesSync();
        _recognizer!.acceptWaveformBytes(bytes);
        _fileRecognitionResult = await _recognizer!.getFinalResult();
      }
    } catch (e) {
      _error = e.toString() +
          '\n\n Make sure fmedia(https://stsaz.github.io/fmedia/)'
              ' is installed on Linux';
    }*/
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
  Future<String> processAudioBytes(
      Uint8List audioBytes, dynamic recognizer, int chunkSize) async {
    int pos = 0;

    while (pos + chunkSize < audioBytes.length) {
      final resultReady = await recognizer.acceptWaveformBytes(
        Uint8List.fromList(audioBytes.sublist(pos, pos + chunkSize)),
      );
      pos += chunkSize;

      if (resultReady) {
        print(await recognizer.getResult());
      } else {
        print(await recognizer.getPartialResult());
      }
    }

    // Process the remaining audio
    await recognizer.acceptWaveformBytes(
      Uint8List.fromList(audioBytes.sublist(pos)),
    );
    return (await recognizer.getFinalResult());
  }

  Future<void> _pickAndRecognizeFile() async {
    try {
      // ファイルを選択
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        // PCM形式に変換
        String inputPath = result.files.single.path!;
        String outputPath = "${inputPath}_converted.wav";
        outputPath = await convertToPCM(inputPath, outputPath);

        // PCMデータを読み込む
        final bytes = File(outputPath).readAsBytesSync();

        // 音声認識ライブラリに渡す
        /*_recognizer!.acceptWaveformBytes(bytes);
        final recognitionResult = await _recognizer!.getFinalResult();*/
        int chunkSize = 8192;
        final recognitionResult = await processAudioBytes(bytes, _recognizer!, chunkSize);

        // 結果をUIに表示
        setState(() {
          _fileRecognitionResult = recognitionResult;
        });

        // 一時ファイルを削除
        File(outputPath).deleteSync();
      } else {
        setState(() {
          _fileRecognitionResult = "No file selected.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error processing file: $e";
      });
    }
  }
}
