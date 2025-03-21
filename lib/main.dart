// Copyright © 2025 Yuichiro Nakada
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'actions.dart' as actions;
import 'home_widget.dart' show HomeWidget;
//import 'settings_widget.dart' show SettingsWidget;

class Frame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text('🌸ai memo🌸'),
                pinned: true,
                floating: true,
                expandedHeight: 100.0,
                onStretchTrigger: () async {},
                stretch: true,
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: 'Home'),
                    Tab(icon: Icon(Icons.settings), text: "Settings"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              HomeWidget(),
              HomeWidget(),
              //SettingsWidget(),
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
      title: 'Flutter App',
      home: Frame(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = FFAppState();
  await appState.initializePersistedState();

  actions.initializeLibrary();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}
