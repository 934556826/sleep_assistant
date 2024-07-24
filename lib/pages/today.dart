import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/flutter_rating_bar/flutter_rating_bar.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:get_storage/get_storage.dart';
import '../core/health/health.dart';
import '../core/widget/loading_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../core/font/font.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final box = GetStorage();

  final ClockTimeFormat _clockTimeFormat = ClockTimeFormat.TWENTYFOURHOURS;
  final ClockIncrementTimeFormat _clockIncrementTimeFormat =
      ClockIncrementTimeFormat.ONEMIN;

  late PickedTime _inBedTime = PickedTime(h: 0, m: 0);
  late PickedTime _outBedTime = PickedTime(h: 8, m: 0);
  // 用于计算睡眠时长 https://pub.dev/packages/progressive_time_picker/example
  late PickedTime _intervalBedTime = PickedTime(h: 0, m: 0);

  late double _sleepGoal;
  late bool _isSleepGoal = false;
  late bool _getTodaySuccess = false;
  // 今日分数
  late double _todayRating = 0;

  bool _loading = true;

  late List sleepData = [];

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
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    String goal = box.read('sleepGoal') ?? '8.0';
    getHealthData().then((val) {
      if (val == null) {
        int startHour;
        int endHour;
        if (box.read('startHour') != null && box.read('endHour') != null) {
          TimeOfDay start = TimeOfDay(
              hour: box.read('startHour'), minute: box.read('startMinute'));
          TimeOfDay end = TimeOfDay(
              hour: box.read('endHour'), minute: box.read('endMinute'));
          startHour = handleTime(start);
          endHour = handleTime(end);
        } else {
          startHour = 22;
          endHour = 6;
        }
        setState(() {
          _getTodaySuccess = false;
          // _inBedTime =
          //     PickedTime(h: startHour, m: box.read('startMinute') ?? 0);
          // _outBedTime = PickedTime(h: endHour, m: box.read('endMinute') ?? 0);
          _inBedTime = PickedTime(h: 0, m: 0);
          _outBedTime = PickedTime(h: 0, m: 0);
          _intervalBedTime = formatIntervalTime(
            init: _inBedTime,
            end: _outBedTime,
            clockTimeFormat: _clockTimeFormat,
            clockIncrementTimeFormat: _clockIncrementTimeFormat,
          );
          _sleepGoal =
              double.parse('${_intervalBedTime.h}.${_intervalBedTime.m}');
          _isSleepGoal =
              (_sleepGoal * 100 >= (double.parse(goal) * 100)) ? true : false;
          _loading = false;
        });
        return;
      } else {
        // 将今日数据存储起来
        var localSleepData = [];
        // 本地存储
        // box.remove('sleepData');
        if (box.read('sleepData') != null) {
          localSleepData = jsonDecode(box.read('sleepData'));
        }

        String dateFrom = val[0]['dateFrom'];
        String dateTo = val[0]['dateTo'];
        bool hasExit = false;
        // bool hasChange = false;
        String key =
            '${Health.dateFormatForDay(dateFrom)}~${Health.dateFormatForDay(dateTo)}';
        String today = Health.dateFormatForDay(DateTime.now());

        for (var j = 0; j < localSleepData.length; j++) {
          var e = localSleepData[j];
          DateTime end = DateTime.parse(e['end']);
          String endDay = Health.dateFormatForDay(end);

          if (endDay == today) {
            hasExit = true;
            // 检测有无修改数据
            // if (dateFrom != e['start'] || dateTo != e['end']) {
            //   hasChange = true;
            //   e['start'] = dateFrom;
            //   e['end'] = dateTo;
            // }
            // 获取今日分数
            setState(() {
              _todayRating = double.parse(e['score'].toString());
              print('_todayRating =>>>>>>>>  $_todayRating');
            });
            break;
          }
        }

        if (!hasExit) {
          Map<String, dynamic> json = {
            'key': key,
            'start': dateFrom,
            'end': dateTo,
            'score': 0,
            'platformType': val[0]['platform'].toString(),
            'pegasiStart': '',
            'pegasiEnd': '',
            'pegasiLight': '',
            'pegasiType': '',
            'createTime': Health.dateFormatForSecond(DateTime.now()),
            "deviceId": val[0]['deviceId'],
            "sourceId": val[0]['sourceId'],
            "sourceName": val[0]['sourceName'],
            "sleepTime": val[0]['value'],
          };
          // 不存在 新增
          localSleepData.add(json);
          // 更新本地
          box.write('sleepData', jsonEncode(localSleepData));
          // 上传线上
          json.removeWhere((key, value) => key == 'createTime');
          Health.uploadAlone(json);
        }
        // else if (hasChange) {
        //   // 更新本地
        //   box.write('sleepData', jsonEncode(localSleepData));
        // }

        setState(() {
          _getTodaySuccess = true;
          // 睡眠
          // sleep(const Duration(seconds: 3));
          sleepData = val;
          _inBedTime = PickedTime(
              h: DateTime.parse(sleepData[0]['dateFrom']).hour,
              m: DateTime.parse(sleepData[0]['dateFrom']).minute);
          _outBedTime = PickedTime(
              h: DateTime.parse(sleepData[0]['dateTo']).hour,
              m: DateTime.parse(sleepData[0]['dateTo']).minute);
          // 手表上的真实数据
          if (sleepData[0]['fromWatch'] == true) {
            int sleepMinute = sleepData[0]['value'].toInt();
            DateTime dateFrom = DateTime.parse(sleepData[0]['dateFrom']);
            DateTime dateTo = dateFrom.add(Duration(minutes: sleepMinute));
            PickedTime awakeTime = PickedTime(h: dateTo.hour, m: dateTo.minute);
            _intervalBedTime = formatIntervalTime(
              init: _inBedTime,
              end: awakeTime,
              clockTimeFormat: _clockTimeFormat,
              clockIncrementTimeFormat: _clockIncrementTimeFormat,
            );
            // 手动添加的数据或其他
          } else {
            _intervalBedTime = formatIntervalTime(
              init: _inBedTime,
              end: _outBedTime,
              clockTimeFormat: _clockTimeFormat,
              clockIncrementTimeFormat: _clockIncrementTimeFormat,
            );
          }

          _sleepGoal =
              double.parse('${_intervalBedTime.h}.${_intervalBedTime.m}');
          _isSleepGoal =
              (_sleepGoal * 100 >= (double.parse(goal) * 100)) ? true : false;
          _loading = false;
        });
      }
    });
  }

  Future getHealthData() async {
    try {
      return await Health.fetchStepData(1);
    } catch (e) {
      return print('error >>>>>>>>>>>>>>>>> $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取设备的宽度和高度
    final size = MediaQuery.of(context).size;

    if (_loading) {
      return LoadingDialog(
        showContent: false,
        backgroundColor: Colors.black38,
        loadingView: const SpinKitSpinningLines(color: Colors.white),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
                decoration: const BoxDecoration(
                  //装饰
                  color: Color.fromARGB(255, 231, 225, 225),
                ),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  decoration: const BoxDecoration(
                    //装饰
                    color: Color.fromARGB(255, 250, 250, 250),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  //装饰
                                  color: const Color(0xFF141925),
                                  borderRadius: BorderRadius.circular(130),
                                ),
                                child: TimePicker(
                                  initTime: _inBedTime,
                                  endTime: _outBedTime,
                                  height: 260.0,
                                  width: 260.0,
                                  onSelectionChange: (PickedTime init,
                                      PickedTime end, bool? isDisableRange) {},
                                  onSelectionEnd:
                                      (start, end, isDisableRange) => print(
                                          'onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRange: $isDisableRange'),
                                  primarySectors: _clockTimeFormat.value,
                                  secondarySectors: _clockTimeFormat.value * 2,
                                  decoration: TimePickerDecoration(
                                    baseColor: const Color(0xFF1F2633),
                                    pickerBaseCirclePadding: 15.0,
                                    sweepDecoration: TimePickerSweepDecoration(
                                      pickerStrokeWidth: 30.0,
                                      pickerColor: const Color(0xFF3CDAF7),
                                      showConnector: true,
                                    ),
                                    initHandlerDecoration:
                                        TimePickerHandlerDecoration(
                                      color: const Color(0xFF141925),
                                      shape: BoxShape.circle,
                                      radius: 12.0,
                                      icon: const Icon(
                                        Icons.bedtime_outlined,
                                        size: 20.0,
                                        color: Color(0xFF3CDAF7),
                                      ),
                                    ),
                                    endHandlerDecoration:
                                        TimePickerHandlerDecoration(
                                      color: const Color(0xFF141925),
                                      shape: BoxShape.circle,
                                      radius: 12.0,
                                      icon: const Icon(
                                        Icons.notifications_active_outlined,
                                        size: 20.0,
                                        color: Color(0xFF3CDAF7),
                                      ),
                                    ),
                                    primarySectorsDecoration:
                                        TimePickerSectorDecoration(
                                      color: Colors.white,
                                      width: 1.0,
                                      size: 4.0,
                                      radiusPadding: 25.0,
                                    ),
                                    secondarySectorsDecoration:
                                        TimePickerSectorDecoration(
                                      color: const Color(0xFF3CDAF7),
                                      width: 1.0,
                                      size: 2.0,
                                      radiusPadding: 25.0,
                                    ),
                                    clockNumberDecoration:
                                        TimePickerClockNumberDecoration(
                                      defaultTextColor: Colors.white,
                                      defaultFontSize: 12.0,
                                      scaleFactor: 2.0,
                                      showNumberIndicators: true,
                                      clockTimeFormat: _clockTimeFormat,
                                      clockIncrementTimeFormat:
                                          _clockIncrementTimeFormat,
                                    ),
                                  ),
                                  child: Visibility(
                                    visible: _getTodaySuccess,
                                    child: Padding(
                                      padding: const EdgeInsets.all(62.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${_intervalBedTime.h}h ',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Color(0xFF3CDAF7),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Visibility(
                                              visible: _intervalBedTime.m > 0,
                                              child: Text(
                                                '${intl.NumberFormat('00').format(_intervalBedTime.m)}min',
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  color: Color(0xFF3CDAF7),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  left: 0,
                                  top: 0,
                                  width: 260.0,
                                  height: 260.0,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                    //装饰
                                    color: Colors.transparent,
                                  ))),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !_getTodaySuccess,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Center(
                            child: Column(
                              children: const [
                                Text(
                                  '睡眠時デバイスを付けることで',
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '睡眠時間を記録します',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _timeWidget(
                            'BedTime',
                            _inBedTime,
                            const Icon(
                              Icons.bedtime_outlined,
                              size: 25.0,
                              color: Color(0xFF3CDAF7),
                            ),
                          ),
                          _timeWidget(
                            'WakeUp',
                            _outBedTime,
                            const Icon(
                              Icons.notifications_active_outlined,
                              size: 25.0,
                              color: Color(0xFF3CDAF7),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: size.width,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2633),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          child: Text(
                            !_getTodaySuccess
                                ? '今日のデータを取得していません'
                                : _isSleepGoal
                                    ? "今日の睡眠目標を達成しました"
                                    : '今日の睡眠目標を達成できていません',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            // Visibility(
            //   visible: !_getTodaySuccess,
            //   child: Container(
            //       width: size.width,
            //       // padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            //       decoration: const BoxDecoration(
            //         //装饰
            //         color: Color.fromARGB(255, 231, 225, 225),
            //       ),
            //       child: Container(
            //         margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            //         decoration: BoxDecoration(
            //           //装饰
            //           color: Colors.transparent,
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             ElevatedButton(
            //                 onPressed: () {
            //                   Get.toNamed('/add');
            //                 },
            //                 child: const Text('マニュアル記録'))
            //           ],
            //         ),
            //       )),
            // ),
            Stack(
              children: [
                Container(
                    width: size.width,
                    // padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: const BoxDecoration(
                      //装饰
                      color: Color.fromARGB(255, 231, 225, 225),
                    ),
                    child: Container(
                      height: 100,
                      // margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      decoration: const BoxDecoration(
                        //装饰
                        color: Color.fromARGB(255, 250, 250, 250),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 10, 8),
                            child: Text(
                              '睡眠評価',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: RatingBar.builder(
                              initialRating: _todayRating,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                switch (index) {
                                  case 0:
                                    return const Icon(
                                      Icons.sentiment_very_dissatisfied,
                                      color: Colors.red,
                                    );
                                  case 1:
                                    return const Icon(
                                      Icons.sentiment_dissatisfied,
                                      color: Colors.redAccent,
                                    );
                                  case 2:
                                    return const Icon(
                                      Icons.sentiment_neutral,
                                      color: Colors.amber,
                                    );
                                  case 3:
                                    return const Icon(
                                      Icons.sentiment_satisfied,
                                      color: Colors.lightGreen,
                                    );
                                  case 4:
                                    return const Icon(
                                      Icons.sentiment_very_satisfied,
                                      color: Colors.green,
                                    );
                                  default:
                                    return const Icon(
                                      Icons.sentiment_very_satisfied,
                                      color: Colors.green,
                                    );
                                }
                              },
                              onRatingUpdate: (double rating) {
                                setRat(rating);
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    right: 20,
                    bottom: 14,
                    width: 60.0,
                    height: 60.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 47, 207, 252),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          MyIcons.pegasi,
                          size: 44,
                          // color: Color.fromARGB(255, 199, 33, 33),
                        ),
                        onPressed: () {
                          Get.toNamed('/pegasi');
                        },
                      ),
                    )),
              ],
            ),
          ],
        ),
      );
    }
  }

  void setRat(double rating) {
    var localSleepData = [];
    // 本地存储
    if (box.read('sleepData') != null) {
      localSleepData = jsonDecode(box.read('sleepData'));
      String today = Health.dateFormatForDay(DateTime.now());
      for (var j = 0; j < localSleepData.length; j++) {
        DateTime end = DateTime.parse(localSleepData[j]['end']);
        String endDay = Health.dateFormatForDay(end);
        if (endDay == today &&
            rating != double.parse(localSleepData[j]['score'].toString())) {
          localSleepData[j]['score'] = rating;
          // 更新线上
          Health.saveSleepScore(localSleepData[j]);
          // 更新本地
          box.write('sleepData', jsonEncode(localSleepData));
          break;
        }
      }
    } else {
      print('today没取到');
    }
  }
}

Widget _timeWidget(String title, PickedTime time, Icon icon) {
  return Container(
    width: 150.0,
    decoration: BoxDecoration(
      color: const Color(0xFF1F2633),
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            '${intl.NumberFormat('00').format(time.h)}:${intl.NumberFormat('00').format(time.m)}',
            style: const TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF3CDAF7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          icon,
        ],
      ),
    ),
  );
}
