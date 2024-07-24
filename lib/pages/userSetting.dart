import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../core/http/http.dart';
import '../core/font/font.dart';
import '../core/utils/privacy.dart';
import '../core/utils/toast.dart';
import '../core/widget/loading_dialog.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({super.key});

  @override
  State<UserSettingPage> createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  final box = GetStorage();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アカウント設定'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        children: [
          // 一条线
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Colors.green),
            title: Text('プライバシーポリシー'),
            trailing: Icon(Icons.chevron_right_sharp),
            onTap: () {
              PrivacyUtils.seePrivacy();
            },
          ),
          Divider(), // 一条线
          ListTile(
            leading: Icon(Icons.password_outlined,
                color: Color.fromARGB(255, 45, 162, 221)),
            title: Text('パスワード修正'),
            trailing: Icon(Icons.chevron_right_sharp),
            onTap: () {
              Get.toNamed('/changePwd');
            },
          ),
          Divider(), // 一条线
          ListTile(
            leading: Icon(MyIcons.off, color: Colors.red),
            title: Text('アカウントを削除'),
            trailing: Icon(Icons.chevron_right_sharp),
            onTap: () {
              deleteDialog();
            },
          ),
          Divider(), // 一条线
          Container(
            margin: EdgeInsets.only(top: 60),
            child: ElevatedButton(
              onPressed: () {
                sureLogout();
              },
              child: Text('ログアウト',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: TextButton.styleFrom(
                // primary: Theme.of(context).primaryColor,
                padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
              ),
            ),
          )
        ],
      ),
    );
  }

  void sureLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ログアウトの確認?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル '),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('確認'),
              onPressed: () {
                box.remove('token');
                Get.offAllNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }

  void deleteDialog({bool necessary = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('アカウントを削除しますか？削除後は同じアカウントでログインすることが出来なくなります。'),
              ],
            ),
          ),
          actions: <Widget>[
            Visibility(
                visible: !necessary,
                child: TextButton(
                  child: Text('キャンセル '),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )),
            TextButton(
              child: Text('確認'),
              onPressed: () {
                deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteAccount([Map<String, dynamic>? params]) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            showContent: false,
            backgroundColor: Colors.black38,
            loadingView: SpinKitCircle(color: Colors.white),
          );
        });
    XHttp.delete("/system/user/profile/disable").then((res) {
      Navigator.pop(context);
      ToastUtils.toast('削除成功しました');
      box.remove('token');
      Get.offAllNamed('/login');
    }).catchError((onError) {
      Navigator.of(context).pop();
    });
  }
}
