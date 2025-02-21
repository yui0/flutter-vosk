// Copyright © 2025 Yuichiro Nakada
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'actions.dart' as actions;

void launchURL(String url) {}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedLanguage = '日本語';
  String? selectedAudio;

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedLanguage,
                  items: ['日本語', '英語', '韓国語']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedLanguage = val);
                    if (val != null) FFAppState().modelState = val;
                  },
                  decoration: InputDecoration(
                    labelText: '言語を選択してください。',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedAudio,
                  items: ['ja.wav', 'jfk.wav', 'Option 1']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) /*async*/ {
                    setState(() => selectedAudio = val);
                    if (val != null) actions.recognizeFile('assets/' + val);
                    //if (val != null) actions.recognizeFile(await rootBundle.loadString('assets/' + val));
                  },
                  decoration: InputDecoration(
                    labelText: 'デモ音声',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => print('Button pressed ...'),
                      child: const Text('再生'),
                    ),
                    ElevatedButton(
                      onPressed: () async => await actions.recognizeFileAction(),
                      child: const Text('ファイル'),
                    ),
                    ElevatedButton(
                      onPressed: () async => await actions.recognizeAction(),
                      child: const Text('認識'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoContainer(FFAppState().infoState),
                _buildMarkdownContainer(FFAppState().resultState),
                _buildMarkdownContainer(FFAppState().summaryState),
                _buildMarkdownContainer(FFAppState().refState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String text) {
    return Container(
      width: double.infinity,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Text(text),
    );
  }

  Widget _buildMarkdownContainer(String data) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
      child: MarkdownBody(
        data: data,
        selectable: true,
        onTapLink: (_, url, __) => launchURL(url!),
      ),
    );
  }
}

