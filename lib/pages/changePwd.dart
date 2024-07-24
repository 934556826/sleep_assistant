import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/core/http/http.dart';
import '/core/utils/toast.dart';
import '/core/widget/loading_dialog.dart';
import 'package:dio/dio.dart';

import 'login.dart';

class ChangePwdPage extends StatefulWidget {
  @override
  _ChangePwdPageState createState() => _ChangePwdPageState();
}

class _ChangePwdPageState extends State<ChangePwdPage> {
  // 响应空白处的焦点的Node
  bool _isShowOldPassWord = false;
  bool _isShowPassWord = false;
  bool _isShowPassWordRepeat = false;
  FocusNode blankNode = FocusNode();
  TextEditingController _oldPwdController = TextEditingController();
  TextEditingController _newPwdController = TextEditingController();
  TextEditingController _newPwdRepeatController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();

  GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('パスワード修正')),
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
              controller: _oldPwdController,
              decoration: InputDecoration(
                  labelText: '古いパスワード',
                  hintText: '古いパスワードを入力してください',
                  hintStyle: TextStyle(fontSize: 12),
                  icon: Icon(Icons.password),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _isShowOldPassWord
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: showOldPassWord)),
              obscureText: !_isShowOldPassWord,
              //校验密码
              validator: (v) {
                return v!.trim().length >= 6 ? null : 'パスワードは6桁以上入力してください！';
              }),
          TextFormField(
              controller: _newPwdController,
              decoration: InputDecoration(
                  labelText: '新しいパスワード',
                  hintText: '新しいパスワードを入力してください',
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

          TextFormField(
              controller: _newPwdRepeatController,
              decoration: InputDecoration(
                  labelText: '新しいパスワード（確認）',
                  hintText: '新しいパスワードを入力してください',
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
                return v!.trim().length < 6
                    ? 'パスワードは6桁以上入力してください！'
                    : _newPwdController.text.trim() != v.trim()
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
                        const Text('保存', style: TextStyle(color: Colors.white)),
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
  void showOldPassWord() {
    setState(() {
      _isShowOldPassWord = !_isShowOldPassWord;
    });
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

    XHttp.put("/system/user/profile/updatePwd", {
      "oldPassword": _oldPwdController.text,
      "newPassword": _newPwdController.text,
    }).then((res) {
      Navigator.pop(context);
      box.remove('token');
      Get.off(() => LoginPage());
      ToastUtils.toast('パスワードが正常に変更されました。もう一度ログインしてください');
    }).catchError((onError) {
      Navigator.of(context).pop();
      ToastUtils.error(onError);
    });
  }
}
