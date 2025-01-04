import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_provider.dart';

class AppBackground extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return LayoutBuilder(builder: (context, contraint) {
     final height = contraint.maxHeight;
     final width = contraint.maxWidth;

     return Stack(
       children: <Widget>[
         Container(
           color: Color(0xFFE4E6F1),
         ),
         Positioned(
           top: height * 0.20,
           left: height * 0.35,
           child: Container(
             height: height,
             width: width,
             decoration: BoxDecoration(
                 shape: BoxShape.circle, color: Colors.white.withOpacity(0.4)),
           ),
         ),
         Positioned(
           top: -height * 0.10,
           left: -height * 0.39,
           child: Container(
             height: height,
             width: width,
             decoration: BoxDecoration(
                 shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
           ),
         ),
       ],
     );
   });
 }
}

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Home Content', style: TextStyle(fontSize: 24)),
          ElevatedButton(
            onPressed: () {
              // ボタンのアクション
            },
            child: Text('Go to Details'),
          ),
        ],
      ),
    );
  }
}

// Searchタブのクラス
class SearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Search Content', style: TextStyle(fontSize: 24)),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
            ),
          ),
        ],
      ),
    );
  }
}

// Settingsタブのクラス
class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Settings Content', style: TextStyle(fontSize: 24)),
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: true,
            onChanged: (bool value) {
              // スイッチのアクション
            },
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状態を監視
    final counterState = ref.watch(counterProvider);
    final counterNotifier = ref.read(counterProvider.notifier);

    return DefaultTabController(
      length: 3, // タブの数
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              /*SliverAppBar(
                onStretchTrigger: () async {
                  //await fetchCatImage();
                },
                stretch: true,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('SliverAppBar Sample'),
                  background: Image.network(
                    "https://aws.random.cat/meow",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),*/
              SliverAppBar(
                title: Text('SliverAppBar + TabView'),
                pinned: true, // スクロールしてもAppBarを固定
                floating: true, // スクロール開始と同時にAppBarを表示
                expandedHeight: 150.0, // AppBarの最大高さ
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    "https://picsum.photos/200/150",
                    //"http://shibe.online/api/shibes?count=1&urls=true&httpsUrls=true",
                    fit: BoxFit.cover,
                  ),
                ),
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: 'Home'),
                    Tab(icon: Icon(Icons.search), text: "Search"),
                    Tab(icon: Icon(Icons.settings), text: "Settings"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              HomeTab(),
              SearchTab(),
              SettingsTab(),
              //Center(child: Text('Tab 2 Content')),
              AppBackground(),
              //Center(child: Text('Tab 3 Content')),
Stack(
    children: <Widget>[
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.lime,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: Offset(10, 10),
              color: Theme.of(context).scaffoldBackgroundColor,
              blurRadius: 20,
            ),
            BoxShadow(
              offset: Offset(-10, -10),
              color: Theme.of(context).scaffoldBackgroundColor,
              blurRadius: 20,
            ),
          ],
        ),
      ),
      Container(
        alignment: Alignment.center,
        height: 100,
        width: 90,
        child: Container(
          alignment: Alignment.center,
          height: 50,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: Text(
            'test',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ],
  ),
            ],
          ),
        ),
      ),
    );

    /*return Scaffold(
      appBar: AppBar(title: Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Count: ${counterState.count}',
              //style: Theme.of(context).textTheme.headline4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: counterNotifier.decrement,
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: counterNotifier.increment,
                ),
              ],
            ),
          ],
        ),
      ),
    );*/
  }
}
