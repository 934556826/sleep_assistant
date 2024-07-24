import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/router/router.dart';
import 'utils.dart';

//隐私弹窗工具
class PrivacyUtils {
  PrivacyUtils._internal();

  //隐私服务政策地址
  static const PRIVACY_URL = 'https://app.pegasiglasses.jp/#/privacy';

  static void showPrivacyDialog(BuildContext context,
      {required VoidCallback onAgressCallback}) {
    Utils.getPackageInfo().then((packageInfo) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('[アプリ利用に関する同意事項]'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  // Text('   [アプリ利用に関する同意事項]'),
                  const SizedBox(height: 5),
                  // const Text('   我们深知个人信息对你的重要性，也感谢你对我们的信任。'),
                  const SizedBox(height: 5),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        style: TextStyle(fontSize: 14),
                        text:
                            '   当社は、お客様にとって個人情報の重要性を認識し、その適正な収集、保存、利用、保護をはかるとともに、安全管理を行うため、'),
                    TextSpan(
                        text: '「睡眠品質改善システムに関するプライバシー ポリシー」',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            PrivacyUtils.seePrivacy();
                          }),
                    TextSpan(
                      text: 'を定めています。',
                      style: TextStyle(fontSize: 14),
                    ),
                  ])),
                  const SizedBox(height: 5),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '   詳しくは ',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextSpan(
                        text: '「プライバシーポリシー」',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            PrivacyUtils.seePrivacy();
                          }),
                    TextSpan(
                      text: 'の全文をご覧ください。',
                      style: TextStyle(fontSize: 14),
                    ),
                  ])),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('同意しない'),
                onPressed: () {
                  Navigator.of(context).pop();
                  showPrivacySecond(context,
                      onAgressCallback: onAgressCallback);
                },
              ),
              TextButton(
                child: Text('同意する'),
                onPressed: onAgressCallback == null
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : onAgressCallback,
              ),
            ],
          );
        },
      );
    });
  }

  ///第二次提醒
  static void showPrivacySecond(BuildContext context,
      {required VoidCallback onAgressCallback}) {
    Utils.getPackageInfo().then((packageInfo) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text(''),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    '    当社は、お客様の個人情報の保護を重視し、「プライバシーポリシー」に従って、お客様の情報を厳重に保護および処理することをお約束します。 このポリシーに同意しない場合、サービスを提供することはできません。',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('アプリを終了する'),
                onPressed: () {
                  exit(0);
                  // Navigator.of(context).pop();
                  // showPrivacyThird(context, onAgressCallback: onAgressCallback);
                },
              ),
              TextButton(
                child: Text('もう一度確認する'),
                onPressed: () {
                  Navigator.of(context).pop();
                  showPrivacyDialog(context,
                      onAgressCallback: onAgressCallback);
                },
              ),
            ],
          );
        },
      );
    });
  }

  ///第次提醒
  static void showPrivacyThird(BuildContext context,
      {required VoidCallback onAgressCallback}) {
    Utils.getPackageInfo().then((packageInfo) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('  要不要再想想？'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('退出应用'),
                onPressed: () {
                  //退出程序
                  // SystemNavigator.pop();
                  exit(0);
                },
              ),
              TextButton(
                child: Text('再次查看'),
                onPressed: () {
                  Navigator.of(context).pop();
                  showPrivacyDialog(context,
                      onAgressCallback: onAgressCallback);
                },
              ),
            ],
          );
        },
      );
    });
  }

  static void seePrivacy() {
    Utils.getPackageInfo().then((packageInfo) {
      // ${packageInfo.appName}
      XRouter.goWeb(PRIVACY_URL, '「システムに関するプライバシー ポリシー」');
    });
  }
}
