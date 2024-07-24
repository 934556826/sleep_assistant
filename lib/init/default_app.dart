import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../router/route_map.dart';
import 'package:get/get.dart';
import '/utils/sputils.dart';
import '/core/http/http.dart';
import '/utils/provider.dart';
import '/core/utils/toast.dart';
import 'package:get_storage/get_storage.dart';

//默认App的启动
class DefaultApp {
  //运行app
  static void run() {
    WidgetsFlutterBinding.ensureInitialized();
    initFirst().then((value) => runApp(Store.init(ToastUtils.init(MyApp()))));
    initApp();
  }

  /// 必须要优先初始化的内容
  static Future<void> initFirst() async {
    await SPUtils.perInit();
    await GetStorage.init();
  }

  /// 程序初始化操作
  static void initApp() {
    XHttp.init();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      getPages: RouteMap.getPages,
      defaultTransition: Transition.rightToLeft,
      supportedLocales: const [
        Locale("en", "US"),
        Locale("zh", "CN"),
        Locale("ja", "")
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
