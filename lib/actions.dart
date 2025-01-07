import 'app_state.dart';

Future<void> recognizeFileAction() async {
  print("recognizeFileAction");
  FFAppState().infoState = "ファイルから認識中。。。";
  //FFAppState().update();
  FFAppState().notifyListeners(); // UIを更新
}

Future<void> recognizeAction() async {
  print("recognizeAction");
  FFAppState().infoState = "認識中。。。";
  FFAppState().notifyListeners();
}

Future<void> aboutAction() async {
  print("aboutAction");
}

/*Future<void> setDarkModeSetting(context, theme) async {
}*/
