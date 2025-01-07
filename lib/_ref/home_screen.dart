import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_provider.dart';
import 'home_page_widget.dart';

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

class RoundedContainer extends StatelessWidget {
  final Color containerColor;
  final String text;
  final double containerWidth;
  final double containerHeight;

  const RoundedContainer({
    Key? key,
    this.containerColor = Colors.lime,
    required this.text,
    this.containerWidth = 200,
    this.containerHeight = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: containerWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            color: containerColor,
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
              text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/*class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBackground(),
        Center(
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
        ),
      ],
    );
  }
}*/
/*class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        ],
      ),
    );
  }
}*/

class LoginTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackground(),
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(
                left: 30, 
                top: 100, 
                right: 30, 
                bottom: 50
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ログイン",
                        style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    "ログインID",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "パスワード",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "パスワードをお忘れですか？",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w400,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2.0
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent
                      ),
                      child: const Text(
                        'ログインする',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      onPressed: () {/*タップされた際の処理*/},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Colors.blueAccent),
                          foregroundColor: Colors.blueAccent,
                          backgroundColor: Colors.white
                      ),
                      child: const Text(
                        '新規登録',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      onPressed: () {/*タップされた際の処理*/},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBackground(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundedContainer(text: 'Search Content'),
              Text('Search Content', style: TextStyle(fontSize: 24)),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBackground(),
        Center(
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
        ),
      ],
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
              SliverAppBar(
                title: Text('🌸ai memo🌸'),
                pinned: true, // スクロールしてもAppBarを固定
                floating: true, // スクロール開始と同時にAppBarを表示
                expandedHeight: 150.0, // AppBarの最大高さ
                onStretchTrigger: () async {
                  //await fetchCatImage();
                },
                stretch: true,
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
              HomePageWidget(),
              SearchTab(),
              SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
