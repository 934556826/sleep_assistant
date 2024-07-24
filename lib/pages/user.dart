import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';

import '../core/http/http.dart';
import '../core/utils/toast.dart';
import '../core/widget/loading_dialog.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  FocusNode blankNode = FocusNode();
  final box = GetStorage();
  String firstName = '';
  String lastName = '';
  int sex = 0; // 1男2女
  DateTime birthday = DateTime.now();
  String height = '';
  String weight = '';

  bool _loading = true;

  bool _hasChange = false;

  FormGroup form() => FormGroup({
        'firstName': FormControl<String>(value: firstName),
        'lastName': FormControl<String>(value: lastName),
        'sex': FormControl<int>(value: sex),
        'birthday': FormControl<DateTime>(value: birthday),
        'height': FormControl<String>(value: height),
        'weight': FormControl<String>(value: weight),
      });
  //  validators: [Validators.required],

  void getUserData() {
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return LoadingDialog(
    //         showContent: false,
    //         backgroundColor: Colors.black38,
    //         loadingView: SpinKitCircle(color: Colors.white),
    //       );
    //     });

    XHttp.get("/getInfo").then((res) {
      // Navigator.pop(context);
      var userData = res['data']['user'];
      setState(() {
        firstName = userData['firstName'] ?? '';
        lastName = userData['lastName'] ?? '';
        sex = int.parse(userData['sex'] ?? '0');
        height = userData['height'] != null
            ? userData['height']
                .toString()
                .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "")
            : '';
        weight = userData['weight'] != null
            ? userData['weight']
                .toString()
                .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "")
            : '';
        if (userData['birthday'] != null) {
          birthday = DateTime.parse(userData['birthday']);
        }
        _loading = false;
      });
    }).catchError((onError) {
      setState(() {
        _loading = false;
      });
      // Navigator.of(context).pop();
    });
  }

  void setUserData([Map<String, dynamic>? params]) {
    if (!box.hasData('token')) {
      return;
    }
    XHttp.putJson("/system/user/profile", params).then((res) {
      // Navigator.pop(context);
      setState(() {
        _hasChange = false;
      });
      ToastUtils.toast('保存成功');
    }).catchError((onError) {
      // Navigator.of(context).pop();
    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白页面关闭键盘
        closeKeyboard(context);
      },
      child: buildForm(context),
    );
  }

  Widget buildForm(BuildContext context) {
    if (_loading) {
      return LoadingDialog(
        showContent: false,
        backgroundColor: Colors.black38,
        loadingView: const SpinKitSpinningLines(color: Colors.white),
      );
    } else {
      return Container(
        color: Colors.transparent,
        child: ReactiveFormBuilder(
          form: form,
          builder: (context, form, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ReactiveTextField(
                      formControlName: 'firstName',
                      maxLength: 20,
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: '姓',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: ((control) {
                        setState(() {
                          _hasChange = true;
                        });
                      }),
                    ),
                    const SizedBox(height: 16),
                    ReactiveTextField(
                      formControlName: 'lastName',
                      maxLength: 20,
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: '名',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: ((control) {
                        setState(() {
                          _hasChange = true;
                        });
                      }),
                    ),
                    const SizedBox(height: 16),
                    ReactiveDropdownField<int>(
                      formControlName: 'sex',
                      decoration: const InputDecoration(
                        labelText: '性别',
                        border: OutlineInputBorder(),
                        helperText: '',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('男'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('女'),
                        ),
                      ],
                      onChanged: ((control) {
                        setState(() {
                          _hasChange = true;
                        });
                      }),
                    ),
                    GestureDetector(
                      onPanCancel: () {
                        setState(() {
                          _hasChange = true;
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: ReactiveDateTimePicker(
                          formControlName: 'birthday',
                          decoration: const InputDecoration(
                            labelText: '誕生日',
                            border: OutlineInputBorder(),
                            helperText: '',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          showClearIcon: false,
                          locale: const Locale("ja", ""),
                        ),
                      ),
                    ),
                    ReactiveTextField(
                      formControlName: 'height',
                      maxLength: 6,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: '身長',
                        suffixText: 'cm',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: ((control) {
                        setState(() {
                          _hasChange = true;
                        });
                      }),
                    ),
                    const SizedBox(height: 16),
                    ReactiveTextField(
                      formControlName: 'weight',
                      maxLength: 6,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: '体重',
                        suffixText: 'kg',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: ((control) {
                        setState(() {
                          _hasChange = true;
                        });
                      }),
                    ),
                    Visibility(
                      visible: _hasChange,
                      child: ElevatedButton(
                        onPressed: () {
                          if (form.valid) {
                            Map<String, dynamic> params = {
                              "firstName": form.value['firstName'],
                              "lastName": form.value['lastName'],
                              "height": form.value['height'],
                              "weight": form.value['weight'],
                              "sex": form.value['sex'],
                              "birthday": DateFormat('yyyy-MM-dd')
                                  .format(form.value['birthday'] as DateTime),
                            };
                            setUserData(params);
                          } else {
                            form.markAllAsTouched();
                          }
                        },
                        child: Text('保存',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 60),
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       sureLogout(context);
                    //     },
                    //     child: Text('ログアウト',
                    //         style:
                    //             TextStyle(color: Colors.white, fontSize: 16)),
                    //     style: TextButton.styleFrom(
                    //       // primary: Theme.of(context).primaryColor,
                    //       padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    ;
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }

  // void sureLogout(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('ログアウトの確認?'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('キャンセル '),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('確認'),
  //             onPressed: () {
  //               box.remove('token');
  //               Get.offAllNamed('/login');
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
