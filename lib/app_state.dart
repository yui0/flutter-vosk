import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // App State variable of primitive type with a getter and setter
  bool _enableDarkMode = false;
  bool get enableDarkMode => _enableDarkMode;
  set enableDarkMode(bool value) {
    _enableDarkMode = value;
  }

  String _infoState = "";
  String get infoState => _infoState;
  set infoState(String value) {
    _infoState = value;
  }
  String _resultState = "";
  String get resultState => _resultState;
  set resultState(String value) {
    _resultState = value;
  }
  String _summaryState = "";
  String get summaryState => _summaryState;
  set summaryState(String value) {
    _summaryState = value;
  }
  String _refState = "";
  String get refState => _refState;
  set refState(String value) {
    _refState = value;
  }
}
