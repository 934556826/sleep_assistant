import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/timeChart/time_chart.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart'
    as drawer_time_picker;
import 'package:get_storage/get_storage.dart';
import '../core/health/health.dart';
import '../core/widget/loading_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:metooltip/metooltip.dart';
import '../core/widget/tooltipDefault.dart';

final box = GetStorage();

// 补0
String zeroPadding(int num) {
  return num < 10 ? '0$num' : '$num';
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  // Data must be sorted.
  late List<DateTimeRange> smallDataList = [];
  var viewMode = ViewMode.weekly;
  int selectedIndex = 0;
  bool _loading = true;
  int _sleepHour = 0; // 平均睡眠时间 小时
  int _sleepMinute = 0; // 平均睡眠时间 分钟
  String _averageStartTime = '00:00';
  String _averageEndTime = '00:00';

  @override
  void initState() {
    super.initState();
    getHealthData(7);
  }

  Future getHealthData(int days) async {
    try {
      var val = await Health.fetchStepData(days);
      if (val == null) {
        setState(() {
          _loading = false;
        });
        return;
      }
      // 记录开始时间结束时间 用于计算平均时间
      List<DateTimeRange> arr = [];
      // 记录真实的睡眠时间 让柱状图显示真实睡眠时间
      List<DateTimeRange> trueArr = [];
      String today = Health.dateFormatForDay(DateTime.now());
      var localSleepData = [];
      bool hasChange = false;
      // 本地存储
      // box.remove('sleepData');
      if (box.read('sleepData') != null) {
        localSleepData = jsonDecode(box.read('sleepData'));
      } else {
        print('没取到');
      }

      for (var i = 0; i < val.length; i++) {
        String dateFrom = val[i]['dateFrom'];
        String dateTo = val[i]['dateTo'];
        num sleepMinute = num.parse(val[i]['value'].toString());
        String key =
            '${Health.dateFormatForDay(dateFrom)}~${Health.dateFormatForDay(dateTo)}';
        String endDay = dateTo;
        bool currentHasExit = false;
        for (var j = 0; j < localSleepData.length; j++) {
          var e = localSleepData[j];
          String localEndDay = e['end'];
          if (e.isNotEmpty) {
            if (localEndDay == endDay) {
              currentHasExit = true;
              break;
            }
          }
        }
        // 不存在 新增
        if (!currentHasExit) {
          hasChange = true;
          localSleepData.add({
            'key': key,
            'start': dateFrom,
            'end': dateTo,
            'score': 0,
            'platformType': val[i]['platform'].toString(),
            'pegasiStart': '',
            'pegasiEnd': '',
            'pegasiLight': '',
            'pegasiType': '',
            'createTime': Health.dateFormatForSecond(DateTime.now()),
            "deviceId": val[i]['deviceId'],
            "sourceId": val[i]['sourceId'],
            "sourceName": val[i]['sourceName'],
            "fromWatch": val[i]['fromWatch'],
            "sleepTime": sleepMinute.toString(),
            "newAdd": true, // 标识为新增的数据 上传时只upload新增的数据
          });
        }

        // 没有今日数据 就要创建 顶在前面
        if (i == 0) {
          if (dateTo != today) {
            arr.add(DateTimeRange(
              start: DateTime.now(),
              end: DateTime.now(),
            ));
            // 写轮眼行为
            trueArr.add(DateTimeRange(
              start: DateTime.now(),
              end: DateTime.now(),
            ));
          }
        }
        arr.add(DateTimeRange(
          start: DateTime.parse(dateFrom),
          end: DateTime.parse(dateTo),
        ));
        // 写轮眼但记录真实睡眠时间
        trueArr.add(DateTimeRange(
          start: DateTime.parse(dateFrom),
          end: DateTime.parse(dateFrom)
              .add(Duration(minutes: sleepMinute.toInt())),
        ));
      }

      if (hasChange) {
        // 保存
        Health.uploadSleepData(localSleepData);
      }

      setState(() {
        // 计算平均每天睡了多久 入睡时间与起床时间
        num allH = 0;
        num allM = 0;
        List allData = [];
        int allStartMilliseconds = 0;
        int allendMilliseconds = 0;
        for (var i = 0; i < arr.length; i++) {
          DateTime start = arr[i].start;
          DateTime end = arr[i].end;
          PickedTime intervalTime = formatIntervalTime(
            init: PickedTime(h: arr[i].start.hour, m: arr[i].start.minute),
            end: PickedTime(h: arr[i].end.hour, m: arr[i].end.minute),
            clockTimeFormat: ClockTimeFormat.TWENTYFOURHOURS,
            clockIncrementTimeFormat: ClockIncrementTimeFormat.ONEMIN,
          );
          // 手动添加的假数据 不算进去
          if (intervalTime.h == 24 && intervalTime.m == 0) {
            continue;
          }
          allStartMilliseconds += (start.millisecondsSinceEpoch -
              DateTime(start.year, start.month, start.day, 00, 00)
                  .millisecondsSinceEpoch);
          if (start.hour < 12) {
            allStartMilliseconds += 24 * 60 * 60 * 1000;
          }
          allendMilliseconds += (end.millisecondsSinceEpoch -
              DateTime(end.year, end.month, end.day, 00, 00)
                  .millisecondsSinceEpoch);
          allData.add(intervalTime);
        }
        int averageStart = (allStartMilliseconds ~/ allData.length);
        int ss1 =
            DateTime(2020, 1, 1, 00, 00).millisecondsSinceEpoch + averageStart;
        DateTime ss2 = DateTime.fromMillisecondsSinceEpoch(ss1);
        _averageStartTime =
            '${intl.NumberFormat('00').format(ss2.hour)}:${intl.NumberFormat('00').format(ss2.minute)}';

        int averageEnd = (allendMilliseconds ~/ allData.length);
        int ss3 =
            DateTime(2020, 1, 1, 00, 00).millisecondsSinceEpoch + averageEnd;
        DateTime ss4 = DateTime.fromMillisecondsSinceEpoch(ss3);
        _averageEndTime =
            '${intl.NumberFormat('00').format(ss4.hour)}:${intl.NumberFormat('00').format(ss4.hour)}';

        for (var i = 0; i < allData.length; i++) {
          allH += allData[i].h;
          allM += allData[i].m;
        }
        var averageTime = allH * 60 + allM;
        _sleepHour = ((averageTime / allData.length) ~/ 60);
        _sleepMinute = ((averageTime / allData.length) % 60).toInt();

        smallDataList = trueArr;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      return print(e);
    }
  }

  // 截取到的三天的数据
  List _sublistArr = [];

  @override
  Widget build(BuildContext context) {
    tooltipShowCallBack(double? amount, DateTime startTime, DateTime endTime) =>
        {
          setState(() {
            var localSleepData = [];
            if (box.read('sleepData') != null) {
              localSleepData = jsonDecode(box.read('sleepData'));
              String chooseDay = Health.dateFormatForDay(endTime);
              for (var j = 0; j < localSleepData.length; j++) {
                DateTime end = DateTime.parse(localSleepData[j]['end']);
                String endDay = Health.dateFormatForDay(end);
                if (endDay == chooseDay) {
                  if (j + 3 <= localSleepData.length - 1) {
                    _sublistArr = localSleepData.sublist(j, j + 3);
                  } else {
                    _sublistArr =
                        localSleepData.sublist(j, localSleepData.length);
                  }
                  break;
                }
              }
            } else {
              print('pegasi三天页面没取到');
            }
          })
        };
    const sizedBox = SizedBox(height: 16);
    if (_loading) {
      return LoadingDialog(
        showContent: false,
        backgroundColor: Colors.black38,
        loadingView: const SpinKitSpinningLines(color: Colors.white),
      );
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Button('7日間', active: selectedIndex == 0, onPressed: () {
                    setState(() {
                      if (selectedIndex == 0) return;
                      selectedIndex = 0;
                      viewMode = ViewMode.weekly;
                      getHealthData(7);
                    });
                  }),
                  Button('1か月', active: selectedIndex == 1, onPressed: () {
                    setState(() {
                      if (selectedIndex == 1) return;
                      selectedIndex = 1;
                      viewMode = ViewMode.monthly;
                      getHealthData(30);
                    });
                  }),
                  // Button('3か月', active: selectedIndex == 2, onPressed: () {
                  //   setState(() {
                  //     selectedIndex = 2;
                  //     viewMode = ViewMode.monthly;
                  //   });
                  // }),
                ],
              ),
              sizedBox,
              Row(
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
                  const Text(
                    '/日',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Row(
                  children: [
                    Column(
                      children: [
                        const Text(
                          '平均就寝時間',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        Text(
                          _averageStartTime,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          '平均起床時間',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        Text(
                          _averageEndTime,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              sizedBox,
              TimeChart(
                data: smallDataList,
                chartType: ChartType.amount,
                viewMode: viewMode,
                barColor: const Color.fromARGB(255, 130, 152, 250),
                tooltipShowCallBack: tooltipShowCallBack,
              ),
              sizedBox,
              sizedBox,
              sleepTimeProgress(data: _sublistArr)
            ],
          ),
        ),
      );
    }
  }
}

class Button extends StatelessWidget {
  String text;
  bool active = false;
  void Function()? onPressed;
  Button(this.text, {super.key, required this.active, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            active ? Color.fromARGB(0, 25, 25, 143) : Colors.white,
          ),
          foregroundColor: MaterialStateProperty.all(Colors.black45),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        ),
        onPressed: onPressed,
        child: Text(text));
  }
}

class sleepTimeProgress extends StatefulWidget {
  const sleepTimeProgress({super.key, required this.data});

  final List data;

  @override
  State<sleepTimeProgress> createState() => _sleepTimeProgressState();
}

class _sleepTimeProgressState extends State<sleepTimeProgress> {
  late int bootTime;
  // 默认启动时间15分钟
  late DateTime initialDateTime;

  void _openTimePickerSheet(BuildContext context) async {
    final result = await drawer_time_picker.TimePicker.show<DateTime?>(
      context: context,
      sheet: TimePickerSheet(
        sheetTitle: 'デバイス起動時間を選択',
        minuteTitle: 'Minute',
        hourTitle: 'Hour',
        saveButtonText: 'Save',
        minHour: 0,
        maxHour: 2,
        minuteInterval: 1,
        initialDateTime: initialDateTime,
      ),
    );

    if (result != null) {
      setState(() {
        box.write('bootTime', '${result.hour}.${zeroPadding(result.minute)}');
        bootTime = (result.hour * 60 + result.minute);
        initialDateTime = DateTime(2022, 2, 22, result.hour, result.minute);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    String stroageTime = box.read('bootTime') ?? '0.15';
    List<String> time = stroageTime.split('.');
    setState(() {
      bootTime = (int.parse(time[0]) * 60 + int.parse(time[1]));
      initialDateTime =
          DateTime(2022, 2, 22, int.parse(time[0]), int.parse(time[1]));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取设备的宽度和高度
    final double allWidth = MediaQuery.of(context).size.width - 32;
    List showList = [];
    for (var i = 0; i < widget.data.length; i++) {
      var ele = widget.data[i];
      // 计算启动时间
      int startupTime = 0;
      // 总睡眠时间
      int sleepTime = 0;
      if (ele['pegasiStart'] != '' && ele['pegasiEnd'] != '') {
        var difference = DateTime.parse(ele['pegasiEnd'])
            .difference(DateTime.parse(ele['pegasiStart']));
        startupTime = difference.inMinutes;
      }
      var sleepDifference =
          DateTime.parse(ele['end']).difference(DateTime.parse(ele['start']));
      sleepTime = sleepDifference.inHours * 60 + sleepDifference.inMinutes % 60;
      // 超过两天的不要
      if (i != 0) {
        var betweentDay = DateTime.parse(widget.data[0]['start'])
            .difference(DateTime.parse(ele['start']))
            .inDays;
        if (betweentDay > 2) {
          continue;
        }
      }
      showList.insert(0, {
        'start': DateTime.parse(ele['start']),
        'startupTime': startupTime,
        'sleepTime': sleepTime,
      });
    }
    // print('showList =>>>>>>>>>>>>>>>>>>>> ${showList}');
    // 总分钟数
    int allTimeLong = widget.data.length * 24 * 60;

    late List<Widget> positionSon = [];
    for (var i = 0; i < showList.length; i++) {
      var e = showList[i];
      double positionX;
      if (i == 0) {
        positionX = 0;
      } else {
        var different = e['start'].difference(showList[0]['start']);
        positionX = (different.inMinutes / allTimeLong) * allWidth;
      }
      double width = (e['sleepTime'] / allTimeLong) * allWidth;
      double bootWidth = (e['startupTime'] / (allTimeLong)) * allWidth;
      bootWidth = bootWidth == 0 ? 0 : bootWidth + 5;
      positionSon.add(Positioned(
          left: positionX + bootWidth,
          top: 0,
          child: MeTooltip(
            message: '${e['startupTime']};${e['sleepTime']};${e['start']}',
            allOffset: 5,
            tooltipChild: _getTooltipChild,
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: bootWidth,
                  color: Color.fromARGB(255, 255, 192, 0),
                ),
                Container(
                  height: 20,
                  width: width,
                  color: Colors.blue,
                ),
              ],
            ),
            preferOri: PreferOrientation.down,
          )));
    }

    // 计算设备启动时间的宽度
    // double bootWidth = (bootTime / (24 * 60)) * allWidth;
    // bool wakeOver24 = widget.endText.hour < widget.startText.hour;
    // double overWidth = 0;
    // // 睡眠开始坐标
    // var posX =
    //     ((widget.startText.hour * 60 + widget.startText.minute) / (24 * 60)) *
    //         allWidth;
    // var difference = widget.endText.difference(widget.startText);
    // // 睡眠占用宽度
    // var sleepWidth =
    //     ((difference.inHours * 60 + difference.inMinutes % 60) / (24 * 60)) *
    //         allWidth;
    // if (wakeOver24) {
    //   overWidth =
    //       ((widget.endText.hour * 60 + widget.endText.minute) / (24 * 60)) *
    //           allWidth;
    // }
    return Column(
      children: [
        Container(
            width: allWidth,
            height: 20,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 220, 230, 241),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: positionSon,
            )
            // Stack(
            //   children: [
            //     Visibility(
            //       visible: wakeOver24,
            //       child: Positioned(
            //         left: 0,
            //         top: 0,
            //         child: Container(
            //           height: 20,
            //           width: overWidth,
            //           color: Colors.blue,
            //         ),
            //       ),
            //     ),
            //     Positioned(
            //         left: posX - bootWidth,
            //         top: 0,
            //         child: Row(
            //           children: [
            //             Container(
            //               height: 20,
            //               width: bootWidth,
            //               color: Color.fromARGB(255, 255, 192, 0),
            //             ),
            //             Container(
            //               height: 20,
            //               width: sleepWidth,
            //               color: Colors.blue,
            //             ),
            //           ],
            //         ))
            //   ],
            // ),
            ),
        // ElevatedButton(
        //     style: ButtonStyle(
        //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(20))),
        //     ),
        //     onPressed: () {
        //       _openTimePickerSheet(context);
        //     },
        //     child: const Text('デバイス起動時間を選択'))
      ],
    );
  }

  TooltipBase _getTooltipChild(DefTooltipType p) {
    return CustomTooltip(
      message: p.message,
      height: p.height,
      preferOri: p.preferOri,
      allOffset: p.allOffset,
      triangleColor: p.triangleColor,
      padding: p.padding,
      margin: p.margin,
      decoration: p.decoration,
      animation: p.animation,
      textStyle: p.textStyle,
      target: p.target,
      entry: p.entry,
      targetSize: p.targetSize,
      customDismiss: p.customDismiss,
    );
  }
}

class CustomTooltip extends TooltipBase {
  final String message;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Offset target;
  final double allOffset;
  final PreferOrientation preferOri;
  final OverlayEntry entry;
  final Size targetSize;
  final Function customDismiss;
  final Color? triangleColor;
  CustomTooltip(
      {Key? key,
      required this.message,
      required this.height,
      this.triangleColor,
      this.padding,
      this.margin,
      this.decoration,
      this.textStyle,
      required Animation<double> animation,
      required this.target,
      required this.allOffset,
      required this.preferOri,
      required this.entry,
      required this.targetSize,
      required this.customDismiss})
      : super(
            key: key,
            message: message,
            height: height,
            triangleColor: triangleColor,
            padding: padding,
            margin: margin,
            decoration: decoration,
            animation: animation,
            textStyle: textStyle,
            target: target,
            allOffset: allOffset,
            preferOri: preferOri,
            entry: entry,
            targetSize: targetSize,
            customDismiss: customDismiss);

  @override
  Widget getDefaultComputed(Animation<double>? animation) => myTooltipDefault(
        message: message,
        height: height,
        padding: padding,
        margin: margin,
        decoration: decoration,
        textStyle: textStyle,
      );

  @override
  Widget customTipPainter() {
    return CustomPaint(
        size: Size(15.0, 10),
        painter:
            DefTrianglePainter(preferSite: preferOri, color: triangleColor));
  }

  @override
  void clickTooltip(customDismiss) {
    print("消失");
    customDismiss();
  }
}
