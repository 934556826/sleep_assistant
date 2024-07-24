import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '/core/utils/path.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/adapter.dart';
import 'package:get/get.dart' as getx;
import '/core/utils/toast.dart';

import '../../pages/login.dart';

class XHttp {
  XHttp._internal();

  static GetStorage box = GetStorage();

  ///网络请求配置
  static final Dio dio = Dio(BaseOptions(
    baseUrl: "https://app.pegasiglasses.jp/sleep-api",
    // baseUrl: "https://yangshi-tech.cn/sleepApi",
    connectTimeout: 10000,
    receiveTimeout: 3000,
  ));

  ///初始化dio
  static void init() {
    ///初始化cookie
    PathUtils.getDocumentsDirPath().then((value) {
      var cookieJar =
          PersistCookieJar(storage: FileStorage(value + "/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
    });

    //忽略证书校验
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    //添加拦截器
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options, handler) {
      // 有token存在 则加上
      if (box.hasData('token')) {
        options.headers['authorization'] = 'Bearer ${box.read('token')}';
      }
      options.headers['Accept-Language'] = 'ja_JP'; //'zh_CN' 'ja_JP'
      return handler.next(options);
    }, onResponse: (Response response, handler) {
      // 未设置状态码则默认成功状态
      print('响应之前 》》》》》》》》》》 ${response.data}');
      final code = response.data['code'] ?? 200;
      if (code == 401) {
        ToastUtils.toast('ログインステータスの有効期限が切れています');
        box.remove('token');
        getx.Get.off(() => LoginPage());
        throw Error();
      } else if (code == 500) {
        ToastUtils.toast('${response.data['msg']}');
        print('500 >>>>>>>>>>>>>> ${response.data['msg']}');
        throw Error();
      } else if (code != 200) {
        print('其他错误码 ${response.data['msg']}');
        throw Error();
      } else {
        return handler.next(response);
      }
    }, onError: (DioError e, handler) {
      handleError(e);
      return handler.next(e);
    }));
  }

  ///error统一处理
  static void handleError(DioError e) {
    switch (e.type) {
      case DioErrorType.connectTimeout:
        ToastUtils.toast('ネットワークリクエストタイムアウト');
        print("连接超时");
        break;
      case DioErrorType.sendTimeout:
        ToastUtils.toast('ネットワークリクエストタイムアウト');
        print("请求超时");
        break;
      case DioErrorType.receiveTimeout:
        ToastUtils.toast('ネットワークリクエストタイムアウト');
        print("响应超时");
        break;
      case DioErrorType.response:
        ToastUtils.toast('サーバーが異常なのでバックステージスタッフに連絡してください');
        print("出现异常");
        break;
      case DioErrorType.cancel:
        print("请求取消");
        break;
      default:
        // ToastUtils.toast('error $e');
        print("未知错误, $e");
        break;
    }
  }

  ///get请求
  static Future get(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.get(url, queryParameters: params);
    } else {
      response = await dio.get(url);
    }
    return response.data;
  }

  ///post 表单请求
  static Future post(String url, [Map<String, dynamic>? params]) async {
    Response response = await dio.post(url, queryParameters: params);
    return response.data;
  }

  ///post body请求
  static Future postJson(String url, [Map<String, dynamic>? data]) async {
    Response response = await dio.post(url, data: data);
    return response.data;
  }

  static Future put(String url, [Map<String, dynamic>? params]) async {
    Response response = await dio.put(url, queryParameters: params);
    return response.data;
  }

  static Future putJson(String url, [Map<String, dynamic>? data]) async {
    Response response = await dio.put(url, data: data);
    return response.data;
  }

  ///delete请求
  static Future delete(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.delete(url, queryParameters: params);
    } else {
      response = await dio.delete(url);
    }
    return response.data;
  }

  ///下载文件
  static Future downloadFile(urlPath, savePath) async {
    Response response;
    try {
      response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        print("$count $total");
      });
      return response.data;
    } on DioError catch (e) {
      handleError(e);
    }
  }
}
