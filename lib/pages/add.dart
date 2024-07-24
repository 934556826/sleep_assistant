import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:get_storage/get_storage.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '/timeChart/src/components/utils/time_assistant.dart';
import 'package:toast/toast.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141925),
      // appBar: AppBar(
      //   centerTitle: true,
      //   leading: IconButton(
      //     icon: const Icon(Icons.close),
      //     onPressed: () {
      //       Get.back();
      //     },
      //   ),
      // ),
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final box = GetStorage();

  final ClockTimeFormat _clockTimeFormat = ClockTimeFormat.TWENTYFOURHOURS;
  final ClockIncrementTimeFormat _clockIncrementTimeFormat =
      ClockIncrementTimeFormat.FIVEMIN;

  late PickedTime _inBedTime = PickedTime(h: 0, m: 0);
  late PickedTime _outBedTime = PickedTime(h: 8, m: 0);
  // 用于计算睡眠时长 https://pub.dev/packages/progressive_time_picker/example
  late PickedTime _intervalBedTime = PickedTime(h: 0, m: 0);
  final DateTime nowTime = DateTime.now();
  late String _dateTime = '';

// 返回处理后的时间
  int handleTime(TimeOfDay time) {
    var hours = time.hour;
    int hour;
    if (hours > 12) {
      hour = (12 - hours).abs();
    } else {
      hour = 12 + hours == 24 ? 0 : 12 + hours;
    }
    return hour;
  }

  @override
  void initState() {
    super.initState();
    int startHour;
    int endHour;
    if (box.read('startHour') != null && box.read('endHour') != null) {
      TimeOfDay start = TimeOfDay(
          hour: box.read('startHour'), minute: box.read('startMinute'));
      TimeOfDay end =
          TimeOfDay(hour: box.read('endHour'), minute: box.read('endMinute'));
      startHour = handleTime(start);
      endHour = handleTime(end);
    } else {
      startHour = 22;
      endHour = 6;
    }
    setState(() {
      _dateTime = '${nowTime.year}-${nowTime.month}-${nowTime.day}';
      _inBedTime = PickedTime(h: startHour, m: box.read('startMinute') ?? 0);
      _outBedTime = PickedTime(h: endHour, m: box.read('endMinute') ?? 0);
      _intervalBedTime = formatIntervalTime(
        init: _inBedTime,
        end: _outBedTime,
        clockTimeFormat: _clockTimeFormat,
        clockIncrementTimeFormat: _clockIncrementTimeFormat,
      );
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'マニュアル記録',
            style: TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Container(
            width: 100,
            child: DateTimePicker(
              initialValue: DateTime.now().toString(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onChanged: (val) => {
                setState(() {
                  _dateTime = val;
                })
              },
              style: TextStyle(color: Color(0xFF3CDAF7)),
            ),
          ),
        ),
        TimePicker(
          initTime: _inBedTime,
          endTime: _outBedTime,
          height: 260.0,
          width: 260.0,
          onSelectionChange: _updateLabels,
          onSelectionEnd: (start, end, isDisableRange) => print(
              'onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRange: $isDisableRange'),
          primarySectors: _clockTimeFormat.value,
          secondarySectors: _clockTimeFormat.value * 2,
          decoration: TimePickerDecoration(
            baseColor: Color(0xFF1F2633),
            pickerBaseCirclePadding: 15.0,
            sweepDecoration: TimePickerSweepDecoration(
              pickerStrokeWidth: 30.0,
              pickerColor: Color(0xFF3CDAF7),
              showConnector: true,
            ),
            initHandlerDecoration: TimePickerHandlerDecoration(
              color: Color(0xFF141925),
              shape: BoxShape.circle,
              radius: 12.0,
              icon: Icon(
                Icons.bedtime_outlined,
                size: 20.0,
                color: Color(0xFF3CDAF7),
              ),
            ),
            endHandlerDecoration: TimePickerHandlerDecoration(
              color: Color(0xFF141925),
              shape: BoxShape.circle,
              radius: 12.0,
              icon: Icon(
                Icons.notifications_active_outlined,
                size: 20.0,
                color: Color(0xFF3CDAF7),
              ),
            ),
            primarySectorsDecoration: TimePickerSectorDecoration(
              color: Colors.white,
              width: 1.0,
              size: 4.0,
              radiusPadding: 25.0,
            ),
            secondarySectorsDecoration: TimePickerSectorDecoration(
              color: Color(0xFF3CDAF7),
              width: 1.0,
              size: 2.0,
              radiusPadding: 25.0,
            ),
            clockNumberDecoration: TimePickerClockNumberDecoration(
              defaultTextColor: Colors.white,
              defaultFontSize: 12.0,
              scaleFactor: 2.0,
              showNumberIndicators: true,
              clockTimeFormat: _clockTimeFormat,
              clockIncrementTimeFormat: _clockIncrementTimeFormat,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(62.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_intervalBedTime.h}h ${intl.NumberFormat('00').format(_intervalBedTime.m)}min',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF3CDAF7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _timeWidget(
              'BedTime',
              _inBedTime,
              Icon(
                Icons.bedtime_outlined,
                size: 25.0,
                color: Color(0xFF3CDAF7),
              ),
            ),
            _timeWidget(
              'WakeUp',
              _outBedTime,
              Icon(
                Icons.notifications_active_outlined,
                size: 25.0,
                color: Color(0xFF3CDAF7),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                width: MediaQuery.of(context).size.width / 2,
                color: Colors.transparent,
                child: const Center(
                  child: Text(
                    '取消',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              onTap: () {
                Get.back();
              },
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                width: MediaQuery.of(context).size.width / 2,
                color: Colors.transparent,
                child: const Center(
                  child: Text(
                    '保存',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              onTap: () {
                _saveData();
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _timeWidget(String title, PickedTime time, Icon icon) {
    return Container(
      width: 150.0,
      decoration: BoxDecoration(
        color: Color(0xFF1F2633),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(
              '${intl.NumberFormat('00').format(time.h)}:${intl.NumberFormat('00').format(time.m)}',
              style: TextStyle(
                color: Color(0xFF3CDAF7),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              '$title',
              style: TextStyle(
                color: Color(0xFF3CDAF7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            icon,
          ],
        ),
      ),
    );
  }

  void _updateLabels(PickedTime init, PickedTime end, bool? isDisableRange) {
    setState(() {
      _inBedTime = init;
      _outBedTime = end;
      _intervalBedTime = formatIntervalTime(
        init: _inBedTime,
        end: _outBedTime,
        clockTimeFormat: _clockTimeFormat,
        clockIncrementTimeFormat: _clockIncrementTimeFormat,
      );
    });
  }

  Future<void> _saveData() async {
    late DateTime dateFrom;
    late DateTime dateTo;

    List<String> dayArr = _dateTime.split('-');
    List<int> day = dayArr.map((e) => int.parse(e)).toList();
    print(day);
    // 不在同一天
    if (_inBedTime.h.toDouble() > _outBedTime.h.toDouble()) {
      dateTo = DateTime(day[0], day[1], day[2], _outBedTime.h, _outBedTime.m);
      final DateTime beforeOneDay = dateTo.subtract(Duration(days: 1));
      dateFrom = DateTime(beforeOneDay.year, beforeOneDay.month,
          beforeOneDay.day, _inBedTime.h, _inBedTime.m);
    } else {
      dateTo = DateTime(day[0], day[1], day[2], _outBedTime.h, _outBedTime.m);
      dateFrom = DateTime(day[0], day[1], day[2], _inBedTime.h, _inBedTime.m);
    }
    HealthFactory health = HealthFactory();
    var types = [
      HealthDataType.SLEEP_IN_BED,
      // HealthDataType.SLEEP_ASLEEP,
      // HealthDataType.SLEEP_AWAKE
    ];
    var permissions = [HealthDataAccess.READ_WRITE];
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);
    print('requested >>>>>>>>>>>>: $requested');
    if (requested) {
      double differenceMinute =
          dateTo.difference(dateFrom).inMinutes.toDouble();
      print('values >>>>>>>>>>>>>> $differenceMinute');
      print('dateFrom >>>>>>>>>>>>>> $dateFrom');
      print('dateTo >>>>>>>>>>>>>> $dateTo');
      bool writeSuccess = await health.writeHealthData(
          0, HealthDataType.SLEEP_IN_BED, dateFrom, dateTo);
      if (writeSuccess) {
        showToast("手动添加数据成功", duration: Toast.top);
        Get.back();
      } else {
        showToast("手动添加数据失败", duration: Toast.top);
      }
    }
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
