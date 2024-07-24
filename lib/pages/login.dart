import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/font/font.dart';
import '/core/http/http.dart';
import '/core/utils/privacy.dart';
import '/core/utils/toast.dart';
import '/core/widget/loading_dialog.dart';
import '/utils/provider.dart';
import '/utils/sputils.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 响应空白处的焦点的Node
  bool _isShowPassWord = false;
  FocusNode blankNode = FocusNode();
  TextEditingController _unameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();
  SPUtils store = SPUtils();
  final box = GetStorage();
  // 是否同意隐私政策
  bool checkboxSelected = false;

  @override
  void initState() {
    super.initState();
    // 删除已同意
    // store.removeAgreePrivacy();
    // if (!store.isAgreePrivacy()) {
    //   PrivacyUtils.showPrivacyDialog(context, onAgressCallback: () {
    //     Navigator.of(context).pop();
    //     store.saveIsAgreePrivacy(true);
    //     ToastUtils.success('同意しました!');
    //   });
    // }
    if (store.isAgreePrivacy()) {
      setState(() {
        checkboxSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('arguments >>>>>>>>  ${Get.arguments['username']}');
    String username = Get.parameters['username'] ?? '';
    if (!username.isEmpty) {
      setState(() {
        _unameController.text = username;
      });
    }
    DateTime? _lastPopTime;
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            // leading: _leading(context),
            title: Text('ログイン'),
            actions: <Widget>[
              TextButton(
                child: Text('登録', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Get.toNamed('/register');
                },
              )
            ],
          ),
          body: GestureDetector(
            onTap: () {
              // 点击空白页面关闭键盘
              closeKeyboard(context);
            },
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 90.0, horizontal: 24.0),
              child: buildForm(context),
            ),
          ),
        ),
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
        });
  }

  //构建表单R
  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey, //设置globalKey，用于后面获取FormState
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: <Widget>[
          const Center(
              heightFactor: 1.5,
              child: Padding(
                padding: EdgeInsets.only(bottom: 25),
                child: Icon(
                  MyIcons.pegasi,
                  size: 80,
                  color: Color.fromARGB(255, 47, 207, 252),
                )
                // FlutterLogo(
                //   size: 64,
                // )
                ,
              )),
          TextFormField(
              autofocus: false,
              controller: _unameController,
              inputFormatters: [
                FilteringTextInputFormatter(RegExp("^[a-z0-9A-Z]+"),
                    allow: true),
              ],
              maxLength: 20,
              decoration: InputDecoration(
                  counterText: '',
                  labelText: 'ユーザー名',
                  hintText: 'ユーザー名またはニックネームを入力してください',
                  hintStyle: TextStyle(fontSize: 12),
                  icon: Icon(Icons.person)),
              //校验用户名
              validator: (v) {
                return v!.trim().length > 0 ? null : 'ユーザー名は空にしてはいけない!';
              }),
          TextFormField(
              controller: _pwdController,
              maxLength: 20,
              decoration: InputDecoration(
                  counterText: '',
                  labelText: 'パスワード',
                  hintText: 'パスワードを入力してください',
                  hintStyle: TextStyle(fontSize: 12),
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _isShowPassWord
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: showPassWord)),
              obscureText: !_isShowPassWord,
              //校验密码
              validator: (v) {
                return v!.trim().length >= 6 ? null : 'パスワードは6桁以上入力してください！';
              }),

          Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24.0,
                      height: 25.0,
                      child: Checkbox(
                          value: checkboxSelected,
                          onChanged: (value) => {
                                setState(() {
                                  checkboxSelected = !checkboxSelected;
                                  if (!checkboxSelected) {
                                    store.removeAgreePrivacy();
                                  } else {
                                    store.saveIsAgreePrivacy(true);
                                  }
                                })
                              }),
                    ),
                    Expanded(
                        child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '「プライバシーポリシー」',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              PrivacyUtils.seePrivacy();
                            }),
                      const TextSpan(
                        text: 'と',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextSpan(
                          text: '「利用規約」',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed('/termsOfUse');
                            }),
                      const TextSpan(
                          style: TextStyle(fontSize: 14), text: 'を読み、同意しました'),
                    ])))
                  ],
                ),
                onTap: () {
                  setState(() {
                    checkboxSelected = !checkboxSelected;
                    if (!checkboxSelected) {
                      store.removeAgreePrivacy();
                    } else {
                      store.saveIsAgreePrivacy(true);
                    }
                  });
                },
              )),
          // 登录按钮
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Row(
              children: <Widget>[
                Expanded(child: Builder(builder: (context) {
                  return ElevatedButton(
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(15.0)),
                    child: Text('ログイン', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      //由于本widget也是Form的子代widget，所以可以通过下面方式获取FormState
                      if (Form.of(context)!.validate()) {
                        onSubmit(context);
                      }
                    },
                  );
                })),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///点击控制密码是否显示
  void showPassWord() {
    setState(() {
      _isShowPassWord = !_isShowPassWord;
    });
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }

  //验证通过提交数据
  void onSubmit(BuildContext context) {
    closeKeyboard(context);

    if (!checkboxSelected) {
      ToastUtils.toast('同意するにはチェックを入れてください');
      return;
    }

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

    // UserProfile userProfile = Provider.of<UserProfile>(context, listen: false);

    XHttp.postJson("/mobileLogin", {
      "username": _unameController.text,
      "password": _pwdController.text
    }).then((res) {
      Navigator.pop(context);
      // ToastUtils.toast('登录成功');
      box.write('token', res['data']);
      Get.offNamed('/home');
    }).catchError((onError) {
      Navigator.of(context).pop();
    });
  }
}
