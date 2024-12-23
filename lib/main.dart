import 'dart:io';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
//import 'package:ffmpeg_cli/ffmpeg_cli.dart';
//import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
//import 'package:ffmpeg_kit_flutter/return_code.dart';

import 'package:record/record.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

void main() async {
  await FFMpegHelper.instance.initialize(); // This is a singleton instance
  runApp(const MyApp());  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  static const _textStyle = TextStyle(fontSize: 20, color: Colors.black);
  static const _modelName = 'vosk-model-small-en-us-0.15';
  static const _sampleRate = 16000;

  final _vosk = VoskFlutterPlugin.instance();
  final _modelLoader = ModelLoader();
  //final _recorder = Record();

  String? _fileRecognitionResult;
  String? _error;
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;

  bool _recognitionStarted = false;

  @override
  void initState() {
    super.initState();

    _modelLoader
        .loadModelsList()
        .then((modelsList) {
          print("Loaded models: ${modelsList.map((model) => model.name).toList()}");
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
        .then((value) => _recognizer = value)
        .then((recognizer) {
      if (Platform.isAndroid) {
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

  Widget _commonExample() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
      ),
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

  Future<void> _pickAndRecognizeFile() async {
    try {
      // ファイルを選択
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        String inputPath = result.files.single.path!;
        String outputPath = "${inputPath}_converted.wav";

        // FFmpegでPCM形式に変換
        /*final session = await FFmpegKit.execute(
            '-i "$inputPath" -ar 16000 -ac 1 -f wav "$outputPath"');
        final returnCode = await session.getReturnCode();*/

FFMpegHelper ffmpeg = FFMpegHelper.instance;
final FFMpegCommand cliCommand = FFMpegCommand(
  inputs: [
    FFMpegInput.asset(inputPath),
  ],
  args: [
    const LogLevelArgument(LogLevel.info),
    const OverwriteArgument(),
    const AudioBitrateArgument(16000),
    const CustomArgument([
      "-ac", "1",
      "-f", "wav",
    ])
  ],
  /*filterGraph: FilterGraph(
    chains: [
      FilterChain(
        inputs: [],
        filters: [
        ],
        outputs: [],
      ),
    ],
  ),*/
  outputFilepath: outputPath
);
FFMpegHelperSession session = await ffmpeg.runAsync(
  cliCommand,
  statisticsCallback: (Statistics statistics) {
    print('bitrate: ${statistics.getBitrate()}');
  },
);

        //if (ReturnCode.isSuccess(returnCode)) {
        //if (session) {
          // PCMデータを読み込む
          final bytes = File(outputPath).readAsBytesSync();

          // 音声認識ライブラリに渡す
          _recognizer!.acceptWaveformBytes(bytes);
          final recognitionResult = await _recognizer!.getFinalResult();

          // 結果をUIに表示
          setState(() {
            _fileRecognitionResult = recognitionResult;
          });

          // 一時ファイルを削除
          File(outputPath).deleteSync();
        } else {
          //throw Exception("Failed to convert audio format. Return code: $returnCode");
        }
      /*} else {
        setState(() {
          _fileRecognitionResult = "No file selected.";
        });
      }*/
    } catch (e) {
      setState(() {
        _error = "Error processing file: $e";
      });
    }
  }
}
