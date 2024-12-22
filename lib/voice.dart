import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voice/new.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

part 'voice.g.dart';

final commandProvider = StateProvider<String>((ref) => "OK then");

@riverpod
FutureOr<SpeechService> speechService(SpeechServiceRef ref) async {
  final VoskFlutterPlugin vosk = VoskFlutterPlugin.instance();

  final String modelPath = await ModelLoader()
      .loadFromAssets('assets/models/vosk-model-small-en-us-0.15.zip');

  final Model model = await vosk.createModel(modelPath);

  final Recognizer recognizer = await vosk.createRecognizer(
    model: model,
    sampleRate: 16000,
    grammar: [
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'zero',
      'clear',
      "ok",
      "say again"
    ],
  );

  final SpeechService speechService = await vosk.initSpeechService(recognizer);
  await speechService.start();
  return speechService;
}

class Voice extends ConsumerWidget {
  const Voice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechService = ref.watch(speechServiceProvider);

    final command = ref.watch(commandProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Vosk'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            speechService.when(
              data: (speechService) {
                speechService.onPartial().forEach((result) {
                  print("PARTIAL: " + result);
                });

                speechService.onResult().forEach((result) {
                  print(command);
                  ref.read(commandProvider.notifier).state = result;
                });

                return Text(command);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text(error.toString()),
            ),
            ElevatedButton(
              child: Text("Next"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewScreen(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
