import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
import 'package:reactive_direct_select/reactive_direct_select.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:toast/toast.dart';

import '../core/health/health.dart';

class PegasiPage extends StatefulWidget {
  const PegasiPage({super.key});

  @override
  State<PegasiPage> createState() => _PegasiPageState();
}

class _PegasiPageState extends State<PegasiPage> {
  final box = GetStorage();

  FocusNode blankNode = FocusNode();

  FormGroup form() => fb.group({
        'startTime': FormControl<DateTime>(
            validators: [Validators.required], value: DateTime.now()),
        'endTime': FormControl<DateTime>(
            validators: [Validators.required], value: DateTime.now()),
        // 'light': FormControl<String>(validators: [Validators.required],value: ''),
        'light': FormControl<int>(value: 0),
        'type': FormControl<int>(value: 0),
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pegasi'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          // 点击空白页面关闭键盘
          closeKeyboard(context);
        },
        child: buildForm(context),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    ToastContext().init(context);
    return SingleChildScrollView(
      child: Container(
        color: Colors.transparent,
        child: ReactiveFormBuilder(
          form: form,
          builder: (context, form, child) {
            return Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ReactiveDateTimePicker(
                    formControlName: 'startTime',
                    type: ReactiveDatePickerFieldType.dateTime,
                    decoration: const InputDecoration(
                      labelText: '起動時間',
                      border: OutlineInputBorder(),
                      helperText: '',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    locale: const Locale("ja", ""),
                  ),
                  const SizedBox(height: 8),
                  ReactiveDateTimePicker(
                    formControlName: 'endTime',
                    type: ReactiveDatePickerFieldType.dateTime,
                    decoration: const InputDecoration(
                      labelText: '終了時間',
                      border: OutlineInputBorder(),
                      helperText: '',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    locale: const Locale("ja", ""),
                  ),
                  const SizedBox(height: 8),
                  ReactiveDropdownField<int>(
                    formControlName: 'light',
                    decoration: const InputDecoration(
                      labelText: '光強度',
                      border: OutlineInputBorder(),
                      helperText: '',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('強い'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('標準'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('弱い'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ReactiveDropdownField<int>(
                    formControlName: 'type',
                    decoration: const InputDecoration(
                      labelText: 'コース種類',
                      border: OutlineInputBorder(),
                      helperText: '',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('コース無し'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('標準コース'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('速効コース'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('じっくりコース'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text('保存'),
                    onPressed: () {
                      if (form.valid) {
                        savePegasiData(form.value);
                      } else {
                        form.markAllAsTouched();
                      }
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(blankNode);
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }

  void savePegasiData(Map form) {
    var localSleepData = [];
    // 本地存储
    if (box.read('sleepData') != null) {
      localSleepData = jsonDecode(box.read('sleepData'));
      // print('pegasi页面取到了, $localSleepData');
      String today = Health.dateFormatForDay(form['endTime']);
      for (var j = 0; j < localSleepData.length; j++) {
        DateTime end = DateTime.parse(localSleepData[j]['end']);
        String endDay = Health.dateFormatForDay(end);
        if (endDay == today) {
          localSleepData[j]['pegasiStart'] =
              Health.dateFormatForSecond(form['startTime']);
          localSleepData[j]['pegasiEnd'] =
              Health.dateFormatForSecond(form['endTime']);
          localSleepData[j]['pegasiLight'] = form['light'];
          localSleepData[j]['pegasiType'] = form['type'];
          print('取到 ${localSleepData[j]}');
          // 只更新这一条睡眠数据
          Health.editPegasi(localSleepData[j]);
          // 更新本地
          box.write('sleepData', jsonEncode(localSleepData));
          showToast('保存成功');
          Get.back();
          break;
        } else if (j == localSleepData.length - 1) {
          showToast('その日の睡眠データが取得できず、保存に失敗');
          print('没有今日数据');
        }
      }
    } else {
      showToast('その日の睡眠データが取得できず、保存に失敗');
      print('today没取到');
    }
  }
}
