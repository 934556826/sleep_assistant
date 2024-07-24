import 'dart:convert';
import 'dart:ui';

import '/utils/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPUtils {
  //创建工厂方法
  static SPUtils? _instance;
  factory SPUtils() => _instance ??= SPUtils._initial();
  SharedPreferences? _preferences;
  //创建命名构造函数
  SPUtils._initial() {
    //为什么在这里需要新写init方法 主要是在命名构造中不能使用async/await
    init();
  }
  //初始化SharedPreferences
  void init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  //到这里还没有完 有时候会遇到使用时提示 SharedPreferences 未初始化,所以还需要提供一个static 的方法
  static Future<SPUtils?> perInit() async {
    if (_instance == null) {
      //静态方法不能访问非静态变量所以需要创建变量再通过方法赋值回去
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _instance = SPUtils._pre(preferences);
    }
    return _instance;
  }

  SPUtils._pre(SharedPreferences prefs) {
    _preferences = prefs;
  }

  ///设置String类型的
  void setString(key, value) {
    _preferences?.setString(key, value);
  }

  ///设置setStringList类型的
  void setStringList(key, value) {
    _preferences?.setStringList(key, value);
  }

  ///设置setBool类型的
  void setBool(key, value) {
    _preferences?.setBool(key, value);
  }

  ///设置setDouble类型的
  void setDouble(key, value) {
    _preferences?.setDouble(key, value);
  }

  ///设置setInt类型的
  void setInt(key, value) {
    _preferences?.setInt(key, value);
  }

  ///存储Json类型的
  void setJson(key, value) {
    value = jsonEncode(value);
    _preferences?.setString(key, value);
  }

  ///通过泛型来获取数据
  T? get<T>(key) {
    var result = _preferences?.get(key);
    if (result != null) {
      return result as T;
    }
    return null;
  }

  ///获取JSON
  // Map<String, dynamic>? getJson(key) {
  //   String? result = _preferences?.getString(key);
  //   if (StringUtil.isNotEmpty(result)) {
  //     return jsonDecode(result!);
  //   }
  //   return null;
  // }

  ///文中的StringUtil中的isNotEmpty的判断
  ///  static isNotEmpty(String? str) {
  /// return str?.isNotEmpty ?? false;
  /// }
  ///清除全部
  void clean() {
    _preferences?.clear();
  }

  ///移除某一个
  void remove(key) {
    _preferences?.remove(key);
  }

  static String getLocale() {
    // String locale = _preferences?.getString('key_locale');
    // if (locale == null) {
    //   locale = LOCALE_FOLLOW_SYSTEM;
    // }
    return 'zh';
  }

  static String getNickName() {
    return '仰视科技';
  }

  static int getThemeIndex() {
    return 0;
  }

  static Brightness getBrightness() {
    return Brightness.light;
  }

  ///是否同意隐私协议
  Future<bool> saveIsAgreePrivacy(bool isAgree) async {
    var result = await _preferences?.setBool('key_agree_privacy_v1', isAgree);
    if (result != null) {
      return result;
    }
    return false;
  }

  bool isAgreePrivacy() {
    var result = _preferences?.containsKey('key_agree_privacy_v1');
    if (result != null) {
      return result;
    }
    return false;
  }

  Future<bool> removeAgreePrivacy() async {
    var result = await _preferences?.remove('key_agree_privacy_v1');
    if (result != null) {
      return result;
    }
    return false;
  }
}
