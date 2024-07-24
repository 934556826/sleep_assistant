import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../core/http/http.dart';
import '../core/utils/toast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final box = GetStorage();

  late TimeOfDay _firstStartTime = const TimeOfDay(hour: 10, minute: 0);
  late TimeOfDay _firstEndTime = const TimeOfDay(hour: 18, minute: 0);
  bool startInit = false;
  bool endInit = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 6, minute: 0);
  int _sleepHour = 8;
  int _sleepMinute = 0;
  // 用来判断是否有更改过时间
  late TimeOfDay _initStartTime;
  late TimeOfDay _initEndTime;

  // 计算时间差
  void calcSleepTime() {
    var sTime = DateTime(2022, 5, 20, _startTime.hour, _startTime.minute);
    var eTime = DateTime(2022, 5, 21, _endTime.hour, _endTime.minute);
    var difference = eTime.difference(sTime);
    _sleepHour =
        difference.inHours >= 24 ? difference.inHours - 24 : difference.inHours;
    _sleepMinute = difference.inMinutes % 60;
    // 写入本地
    box.write('sleepGoal', '$_sleepHour.${zeroPadding(_sleepMinute)}');
  }

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

  // 补0
  String zeroPadding(int num) {
    return num < 10 ? '0$num' : '$num';
  }

  @override
  void dispose() {
    super.dispose();
    if (box.read('startHour') != null && box.read('endHour') != null) {
      print(_initStartTime.toString());
      if (_initStartTime == _startTime && _initEndTime == _endTime) {
        print('没改变');
      } else {
        print('发生改变');
        saveSetting();
      }
    } else {
      box.write('startHour', _firstStartTime.hour);
      box.write('startMinute', _firstStartTime.minute);
      box.write('endHour', _firstEndTime.hour);
      box.write('endMinute', _firstEndTime.minute);
      print('不存在，直接保存');
      saveSetting();
    }
  }

  void saveSetting() {
    String goal = box.read('sleepGoal') ?? '8.0';
    var params = {
      "startTime":
          '${intl.NumberFormat('00').format(_startTime.hour)}:${intl.NumberFormat('00').format(_startTime.minute)}',
      "endTime":
          '${intl.NumberFormat('00').format(_endTime.hour)}:${intl.NumberFormat('00').format(_endTime.minute)}',
      "targetValue": goal,
    };
    if (!box.hasData('token')) {
      return;
    }
    XHttp.putJson("/app/goal", params).then((res) {}).catchError((onError) {});
  }

  @override
  void initState() {
    super.initState();
    if (box.read('startHour') != null && box.read('endHour') != null) {
      setState(() {
        TimeOfDay start = TimeOfDay(
            hour: box.read('startHour'), minute: box.read('startMinute'));
        TimeOfDay end =
            TimeOfDay(hour: box.read('endHour'), minute: box.read('endMinute'));
        _firstStartTime = start;
        _firstEndTime = end;
        int startHour = handleTime(start);
        int endHour = handleTime(end);
        _startTime = TimeOfDay(hour: startHour, minute: start.minute);
        _endTime = TimeOfDay(hour: endHour, minute: end.minute);
        calcSleepTime();
      });
    }
    // 记录初始
    setState(() {
      _initStartTime = _startTime;
      _initEndTime = _endTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const Text(
            '必要睡眠時間には個人差があります。あなたの睡眠時間を分析して最適な睡眠時間を提案します。',
            style: TextStyle(fontSize: 16),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Text("Start: ${_startTime.format(context)}"),
          //     Text("End: ${_endTime.format(context)}"),
          //   ],
          // ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${zeroPadding(_startTime.hour)} : ${zeroPadding(_startTime.minute)}',
                style: const TextStyle(fontSize: 20),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('-'),
              ),
              Text(
                  '${zeroPadding(_endTime.hour)} : ${zeroPadding(_endTime.minute)}',
                  style: const TextStyle(fontSize: 20)),
            ],
          ),
          SizedBox(
            height: 300,
            child: TimeRangePicker(
              hideButtons: true,
              hideTimes: true,
              paintingStyle: PaintingStyle.fill,
              backgroundColor: Colors.grey.withOpacity(0.2),
              labels: [
                ClockLabel.fromTime(
                    time: const TimeOfDay(hour: 12, minute: 0), text: "0"),
                ClockLabel.fromTime(
                    time: const TimeOfDay(hour: 18, minute: 0), text: "6"),
                ClockLabel.fromTime(
                    time: const TimeOfDay(hour: 24, minute: 0), text: "12"),
                ClockLabel.fromTime(
                    time: const TimeOfDay(hour: 6, minute: 0), text: "18")
              ],
              start: startInit ? _startTime : _firstStartTime,
              end: endInit ? _endTime : _firstEndTime,
              rotateLabels: false,
              ticks: 8,
              strokeColor: Theme.of(context).primaryColor.withOpacity(0.5),
              ticksColor: Theme.of(context).primaryColor,
              labelOffset: 15,
              padding: 50,
              onStartChange: (start) {
                setState(() {
                  startInit = true;
                  box.write('startHour', start.hour);
                  box.write('startMinute', start.minute);
                  int hour = handleTime(start);
                  _startTime = TimeOfDay(hour: hour, minute: start.minute);
                  calcSleepTime();
                });
              },
              onEndChange: (end) {
                setState(() {
                  endInit = true;
                  box.write('endHour', end.hour);
                  box.write('endMinute', end.minute);
                  int hour = handleTime(end);
                  _endTime = TimeOfDay(hour: hour, minute: end.minute);
                  calcSleepTime();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Text(
                  '$_sleepHour',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const Text(
                '時間',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Visibility(
                  visible: _sleepMinute > 0,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Text(
                          '$_sleepMinute',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Text(
                        '分',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      )
                    ],
                  )),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Center(
            child: Text(
              '睡眠時間',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );

    ;
  }
}
