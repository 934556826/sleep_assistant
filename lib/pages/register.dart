import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '/core/http/http.dart';
import '/core/utils/toast.dart';
import '/core/widget/loading_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 响应空白处的焦点的Node
  bool _isShowPassWord = false;
  bool _isShowPassWordRepeat = false;
  FocusNode blankNode = FocusNode();
  TextEditingController _unameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _pwdRepeatController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登録')),
      body: GestureDetector(
        onTap: () {
          // 点击空白页面关闭键盘
          closeKeyboard(context);
        },
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(vertical: 100.0, horizontal: 24.0),
          child: buildForm(context),
        ),
      ),
    );
  }

  //构建表单
  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey, //设置globalKey，用于后面获取FormState
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: <Widget>[
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
                if (v!.trim().length < 6) {
                  return 'ユーザー名は6から20文字以内の英数字で設定してください!';
                } else {
                  return null;
                }
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
                if (v!.trim().length < 5) {
                  return 'パスワードは5文字以上20文字以下で設定してください!';
                } else {
                  return null;
                }
              }),

          TextFormField(
              controller: _pwdRepeatController,
              maxLength: 20,
              decoration: InputDecoration(
                  counterText: '',
                  labelText: 'パスワードを繰り返す',
                  hintText: 'パスワードを入力してください',
                  hintStyle: TextStyle(fontSize: 12),
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _isShowPassWordRepeat
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: showPassWordRepeat)),
              obscureText: !_isShowPassWordRepeat,
              //校验密码
              validator: (v) {
                return v!.trim().length < 5
                    ? 'パスワードは5文字以上20文字以下で設定してください!'
                    : _pwdController.text.trim() != v.trim()
                        ? '2回入力したパスワードが一致しない!'
                        : null;
              }),

          // 登录按钮
          Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: Row(
              children: <Widget>[
                Expanded(child: Builder(builder: (context) {
                  return ElevatedButton(
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(15.0)),
                    child:
                        const Text('登録', style: TextStyle(color: Colors.white)),
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

  ///点击控制密码是否显示
  void showPassWordRepeat() {
    setState(() {
      _isShowPassWordRepeat = !_isShowPassWordRepeat;
    });
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }

  //验证通过提交数据
  void onSubmit(BuildContext context) async {
    closeKeyboard(context);

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

    XHttp.postJson("/register", {
      "username": _unameController.text,
      "password": _pwdController.text,
      "confirmPassword": _pwdRepeatController.text
    }).then((res) {
      Navigator.pop(context);
      ToastUtils.toast('登録に成功しました');
      // 返回上一页
      Get.offAllNamed('/login',
          parameters: {'username': _unameController.text});
      // Navigator.of(context).pop();
    }).catchError((onError) {
      Navigator.of(context).pop();
      ToastUtils.error(onError);
    });
  }
}
