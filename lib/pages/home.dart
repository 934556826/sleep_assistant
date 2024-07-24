import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../core/http/http.dart';
import '../core/utils/utils.dart';
import '../pages/today.dart';
import '../pages/analysis.dart';
import '../pages/user.dart';
import 'package:get/get.dart';
import '/core/utils/toast.dart';
import 'package:open_store/open_store.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final globalKey = GlobalKey<AnimatedListState>();
  String tltle = '今日の睡眠';
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const TodayPage(),
    const AnalysisPage(),
    // SettingPage(),
    const UserPage()
  ];
  final box = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    advancedStatusCheck();
  }

  advancedStatusCheck() async {
    String minimumAppVersion = '';
    final parameters = {"id": "6444021953"};
    var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Failed to query iOS App Store');
      return null;
    }
    final jsonObj = json.decode(response.body);
    final List results = jsonObj['results'];
    if (results.isEmpty) {
      debugPrint('Can\'t find an app in the App Store');
      return null;
    }
    Utils.getPackageInfo().then((packageInfo) async {
      String localVersion = packageInfo.version;
      String storeVersion = jsonObj['results'][0]['version'];
      String releaseNotes = jsonObj['results'][0]['releaseNotes'];

      // print('localVersion >>>> ${localVersion}');
      // print('storeVersion >>>> ${storeVersion}');
      // print('releaseNotes >>>> ${releaseNotes}');

      bool hasUpdate = canUpdate(localVersion, storeVersion);

      // 获取最小版本号
      await XHttp.get("/app/version").then((res) {
        minimumAppVersion = res['minimumAppVersion'];
      });

      bool forceUpdate = canUpdate(localVersion, minimumAppVersion);
      // 强制更新
      if (forceUpdate) {
        updateDialog(true, releaseNotes);
      } else if (hasUpdate) {
        // 三天提示一次
        if (box.read('updateTipTime') != null) {
          DateTime lastTipTime = DateTime.parse(box.read('updateTipTime'));
          if (DateTime.now().difference(lastTipTime).inDays > 2) {
            updateDialog(false, releaseNotes);
            box.write('updateTipTime', DateTime.now().toString());
          }
        } else {
          updateDialog(false, releaseNotes);
          box.write('updateTipTime', DateTime.now().toString());
        }
      }
    });
  }

  bool canUpdate(
    String localVersion,
    String storeVersion,
  ) {
    final local = localVersion.split('.').map(int.parse).toList();
    final store = storeVersion.split('.').map(int.parse).toList();

    // Each consecutive field in the version notation is less significant than the previous one,
    // therefore only one comparison needs to yield `true` for it to be determined that the store
    // version is greater than the local version.
    for (var i = 0; i < store.length; i++) {
      // The store version field is newer than the local version.
      if (store[i] > local[i]) {
        return true;
      }

      // The local version field is newer than the store version.
      if (local[i] > store[i]) {
        return false;
      }
    }

    // The local and store versions are the same.
    return false;
  }

  void updateDialog(bool necessary, String releaseNotes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '睡眠品質評価アプリ更新のお願い',
            style: TextStyle(fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  releaseNotes,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Visibility(
                visible: !necessary,
                child: TextButton(
                  child: const Text('キャンセル '),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )),
            TextButton(
              child: const Text('アプリを更新する'),
              onPressed: () {
                OpenStore.instance.open(
                  appStoreId: '6444021953', // AppStore id of your app for iOS
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? _lastPopTime;
    return WillPopScope(
        onWillPop: () {
          if (_lastPopTime == null ||
              DateTime.now().difference(_lastPopTime!) >
                  const Duration(milliseconds: 1000)) {
            //两次点击间隔超过1秒则重新计时
            ToastUtils.toast("もう一度押すと、プログラムを終了します");
            _lastPopTime = DateTime.now();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            key: _scaffoldKey,
            title: Text(tltle),
            centerTitle: true,
            actions: <Widget>[
              PopupMenuButton(
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: "1",
                      child: Text("目標設定"),
                    ),
                    PopupMenuItem(
                      value: "2",
                      child: Text("アカウント設定"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == '1') {
                    Get.toNamed('/setting');
                  } else if (value == '2') {
                    Get.toNamed('/userSetting');
                  }
                },
                // onCanceled: () {
                //   print("canceled");
                // },
              )
            ],
          ),
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              // type: BottomNavigationBarType.fixed, // 如果底部有四个或四个以上菜单时候配置这个
              onTap: (index) {
                setState(() {
                  if (_currentIndex != index) {
                    _currentIndex = index;
                    tltle = _currentIndex == 0
                        ? '今日睡眠'
                        : _currentIndex == 1
                            ? '睡眠分析'
                            // : _currentIndex == 2
                            //     ? '目標設定'
                            : _currentIndex == 2
                                ? '個人情報'
                                : '';
                  }
                });
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'ホーム'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined), label: '分析'),
                // BottomNavigationBarItem(
                //     icon: Icon(Icons.track_changes_rounded), label: '目標'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle_outlined), label: '個人'),
              ]),
        ));
  }
}
