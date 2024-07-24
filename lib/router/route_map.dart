import 'package:flutter/material.dart';
import '../pages/home.dart';
import '../pages/login.dart';
import '../pages/add.dart';
import '../pages/pegasi.dart';
import '../pages/register.dart';
import '../pages/setting.dart';
import '../pages/changePwd.dart';
import '../pages/UserSetting.dart';
import '../pages/termsOfUse.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/core/widget/web_view_page.dart';

class RouteMap {
  static GetStorage box = GetStorage();

  static List<GetPage> getPages = [
    GetPage(
        name: '/',
        page: () {
          return !box.hasData('token') ? LoginPage() : HomePage();
        }),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/register', page: () => RegisterPage()),
    GetPage(name: '/changePwd', page: () => ChangePwdPage()),
    GetPage(name: '/login', page: () => LoginPage()),
    // GetPage(name: '/add', page: () => AddPage()),
    GetPage(name: '/setting', page: () => SettingPage()),
    GetPage(name: '/pegasi', page: () => PegasiPage()),
    GetPage(name: '/userSetting', page: () => UserSettingPage()),
    GetPage(name: '/web', page: () => WebViewPage()),
    GetPage(name: '/termsOfUse', page: () => TermsOfUserPage()),
    // GetPage(name: '/menu/sponsor-page', page: () => SponsorPage()),
    // GetPage(name: '/menu/settings-page', page: () => SettingsPage()),
    // GetPage(name: '/menu/about-page', page: () => AboutPage()),
  ];

  /// 页面切换动画ß
  static Widget getTransitions(
      BuildContext context,
      Animation<double> animation1,
      Animation<double> animation2,
      Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
              //1.0为右进右出，-1.0为左进左出
              begin: Offset(1.0, 0.0),
              end: Offset(0.0, 0.0))
          .animate(
              CurvedAnimation(parent: animation1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  }
}
