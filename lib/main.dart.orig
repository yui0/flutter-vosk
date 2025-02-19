// Copyright © 2025 Yuichiro Nakada
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_web_plugins/url_strategy.dart';
/*import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';*/

import 'package:flutterflow_ui/flutterflow_ui.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'app_state.dart';
import 'actions.dart' as actions;

import 'home_widget.dart' show HomeWidget;
import 'settings_widget.dart' show SettingsWidget;

class Frame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,//3, // タブの数
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text('🌸ai memo🌸'),
                pinned: true, // スクロールしてもAppBarを固定
                floating: true, // スクロール開始と同時にAppBarを表示
                expandedHeight: 100.0, // AppBarの最大高さ
                onStretchTrigger: () async {
                },
                stretch: true,
                /*flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    "https://picsum.photos/200/150",
                    fit: BoxFit.cover,
                  ),
                ),*/
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: 'Home'),
                    //Tab(icon: Icon(Icons.search), text: "Search"),
                    Tab(icon: Icon(Icons.settings), text: "Settings"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              HomeWidget(),
              //HomePageWidget(),
              SettingsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFlow App',
      //theme: FlutterFlowTheme.of(context),
      home: Frame(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();*/

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  actions.initializeLibrary();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}
