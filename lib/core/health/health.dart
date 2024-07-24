import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import '../http/http.dart';

class Health {
  Health._internal();

  static final box = GetStorage();

  static Future fetchStepData(int days) async {
    // int? steps;
    var sleep_awake;

    HealthFactory health = HealthFactory();

    final types = [
      // HealthDataType.SLEEP_IN_BED,
      HealthDataType.SLEEP_ASLEEP,
      // HealthDataType.SLEEP_AWAKE
    ];

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: days));

    // bool requested = await health.requestAuthorization([HealthDataType.STEPS]);
    bool requested =
        await health.requestAuthorization([HealthDataType.SLEEP_ASLEEP]);
    if (requested) {
      try {
        // 只获取1天的数据
        if (days == 1) {
          sleep_awake =
              await health.getHealthDataFromTypes(yesterday, now, types);
          // sleep_awake = await health.getHealthDataFromTypes(
          //     now.subtract(Duration(days: 3)),
          //     now.subtract(Duration(days: 2)),
          //     types);
          if (sleep_awake.isEmpty) {
            return null;
          } else {
            List data = sleep_awake.toList();
            return Health.calcSleepData(data);
          }
        } else {
          // 分天获取
          List data = [];
          for (var i = 0; i < days; i++) {
            DateTime start = i == 0
                ? now.subtract(const Duration(days: 1))
                : now.subtract(Duration(days: i + 1));
            DateTime end = i == 0 ? now : now.subtract(Duration(days: i));
            var currentValue =
                await health.getHealthDataFromTypes(start, end, types);
            var result = Health.calcSleepData(currentValue.toList());
            if (result == null) {
            } else {
              data.add(result[0]);
            }
          }

          // sleep_awake =
          //     await health.getHealthDataFromTypes(yesterday, now, types);
          // List data = sleep_awake.toList();

          // 过滤掉重复的日期 只选取第一个
          if (data.length > 1) {
            data.sort((a, b) {
              return DateTime.parse(b['dateTo'])
                  .millisecondsSinceEpoch
                  .compareTo(
                      DateTime.parse(a['dateFrom']).millisecondsSinceEpoch);
            });
            List filterData = [];
            late String start;
            late String end;
            for (var i = 0; i < data.length; i++) {
              var item = data[i];
              if (i == 0) {
                filterData.add(data[i]);
              } else {
                var lastItem = data[i - 1];
                start = Health.dateFormatForDay(lastItem['dateFrom']);
                end = Health.dateFormatForDay(lastItem['dateTo']);
                if (Health.dateFormatForDay(item['dateFrom']) == start &&
                    Health.dateFormatForDay(item['dateTo']) == end) {
                } else {
                  filterData.add(data[i]);
                }
              }
            }
            return filterData;
          } else {
            return data;
          }
        }
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval ===>>>>>>>: $error");
      }
    } else {
      print("===>>>>>>> Authorization not granted - error in authorization");
      // setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  static calcSleepData(List data) {
    if (data.isEmpty) {
      return null;
    } else if (data.length == 1) {
      //手动添加的数据
      var todayData = {
        'value': data[0].value,
        'unit': data[0].unit,
        'dateFrom': Health.dateFormatForSecond(data[0].dateFrom),
        'dateTo': Health.dateFormatForSecond(data[0].dateTo),
        'dataType': data[0].type,
        'platform': data[0].platform,
        'deviceId': data[0].deviceId,
        'sourceId': data[0].sourceId,
        'sourceName': data[0].sourceName
      };
      List<Map> arr = [];
      arr.add(todayData);

      return arr;
    } else {
      // 真实睡眠数据
      List realSleepData = data.reversed.toList();
      double totalMinute = 0.0;
      var todayData = {
        'value': 0.0,
        'type': realSleepData[0].type,
        'unit': realSleepData[0].unit,
        'dateFrom': Health.dateFormatForSecond(realSleepData[0].dateFrom),
        'dateTo': Health.dateFormatForSecond(
            realSleepData[realSleepData.length - 1].dateTo),
        'platform': realSleepData[0].platform,
        'deviceId': realSleepData[0].deviceId,
        'sourceId': realSleepData[0].sourceId,
        'sourceName': realSleepData[0].sourceName,
        'fromWatch': true,
      };
      for (var i = 0; i < realSleepData.length; i++) {
        var item = realSleepData[i];
        totalMinute += double.parse(item.value.toString());
      }
      todayData['value'] = totalMinute;

      List<Map> arr = [];
      arr.add(todayData);

      return arr;
    }
  }

  // 将数据保存在本地
  static uploadSleepData(List data) {
    data.sort((a, b) {
      return DateTime.parse(b['end'])
          .millisecondsSinceEpoch
          .compareTo(DateTime.parse(a['start']).millisecondsSinceEpoch);
    });
    List filterData = [];
    for (var i = 0; i < data.length; i++) {
      var item = data[i];
      if (i == 0) {
        filterData.add(data[i]);
      } else {
        var lastItem = data[i - 1];
        var lastItemDay = lastItem['end'];
        var itemDay = item['end'];
        if (itemDay == lastItemDay) {
          if (lastItem['createTime'] == null) {
            // 替换为更新时间较新的
            filterData.removeAt(filterData.length - 1);
            filterData.add(data[i]);
          } else {
            if (item['createTime'] != null) {
              if (DateTime.parse(item['createTime']).millisecond >
                  DateTime.parse(lastItem['createTime']).millisecond) {
                // 替换为更新时间较新的
                filterData.removeAt(filterData.length - 1);
                filterData.add(data[i]);
              }
            }
          }
        } else {
          filterData.add(data[i]);
        }
      }
    }
    // Health.uploadHealthData(jsonEncode(filterData));
    Health.uploadHealthData1(filterData);
  }

  static uploadHealthData(String dataJson) {
    XHttp.putJson("/app/demo/sleep", {'json': dataJson})
        .then((res) {})
        .catchError((onError) {});
  }

  static uploadHealthData1(List data) {
    List finalData = [];
    for (var i = 0; i < data.length; i++) {
      var item = data[i];
      // 只更新新增数据
      if (item['newAdd'] == true) {
        // 计算睡了多少分钟
        DateTime start = DateTime.parse(item['start']);
        DateTime end = DateTime.parse(item['end']);
        Duration diff = end.difference(start);

        Map obj = {
          "bedIn": item['start'],
          "wakeUp": item['end'],
          "pegasiStartTime": item['pegasiStart'] ?? '',
          "pegasiEndTime": item['pegasiEnd'] ?? '',
          "pegasiLight": item['pegasiLight'],
          "pegasiType": (item['pegasiType'] is String &&
                  double.tryParse(item['pegasiType']) == null)
              ? 0
              : item['pegasiType'],
          "platform": item['platformType'],
          "sleepScore": item['score'],
          "recordDate": item['key'],
          "sleepTime": item['fromWatch'] == true
              ? item['sleepTime'].toString()
              : diff.inMinutes.toString(),
          "deviceId": item['deviceId'],
          "sourceId": item['sourceId'],
          "sourceName": item['sourceName'],
          // "version": 0,
          // "revision": 0,
        };
        finalData.add(obj);
      }
    }

    // print('finalData >>>>>>>>>>>>>>>>> $finalData');

    // 保存本地
    for (var i = 0; i < data.length; i++) {
      // 删除新增数据标识
      data[i]['newAdd'] = null;
    }
    box.write('sleepData', jsonEncode(data));

    // 上传
    XHttp.putJson("/app/sleep/upload", {'data': finalData})
        .then((res) {})
        .catchError((onError) {});
  }

  static String dateFormatForSecond(var time) {
    if (time is DateTime) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
    } else if (time is String) {
      DateTime times = DateTime.parse(time);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(times);
    } else {
      return '';
    }
  }

  static dateFormatForDay(var time) {
    if (time is DateTime) {
      return DateFormat('yyyy-MM-dd').format(time);
    } else if (time is String) {
      DateTime times = DateTime.parse(time);
      return DateFormat('yyyy-MM-dd').format(times);
    } else {
      return '';
    }
  }

  static saveSleepScore(Map<String, dynamic> json) {
    Map<String, dynamic> replaceJson = {
      'recordDate': json['key'],
      'score': json['score'],
    };
    print('replaceJson >>>>>>>>>>>>>>>>>>>>>>>>>>>>  $replaceJson');
    XHttp.putJson("/app/score", replaceJson)
        .then((res) {})
        .catchError((onError) {});
  }

  // 更新单条数据的pagesi
  static editPegasi(Map<String, dynamic> json) {
    Map<String, dynamic> modifyJson = {
      'recordDate': json['key'],
      'sourceId': json['sourceId'],
      'pegasiStartTime': json['pegasiStart'],
      'pegasiEndTime': json['pegasiEnd'],
      'pegasiLight': json['pegasiLight'],
      'pegasiType': json['pegasiType'],
    };
    print('modifyJson >>>>>>>>>>>>>>>>>>>>>>>>>>>>  $modifyJson');
    XHttp.putJson("/app/sleep/modify", modifyJson)
        .then((res) {})
        .catchError((onError) {});
  }

  // 更新单条数据
  static editSleepData(Map<String, dynamic> json) {
    print('json >>>>>>>>>>>>>>>>>>>>>>>>>>>>  $json');
    XHttp.putJson("/app/sleep/modify", json)
        .then((res) {})
        .catchError((onError) {});
  }

  // 上传单条数据
  static uploadAlone(Map<String, dynamic> json) {
    Map obj = {
      "bedIn": json['start'],
      "wakeUp": json['end'],
      "pegasiStartTime": json['pegasiStart'] ?? '',
      "pegasiEndTime": json['pegasiEnd'] ?? '',
      "pegasiLight": json['pegasiLight'],
      "pegasiType": (json['pegasiType'] is String &&
              double.tryParse(json['pegasiType']) == null)
          ? 0
          : json['pegasiType'],
      "platform": json['platformType'],
      "sleepScore": json['score'],
      "recordDate": json['key'],
      "sleepTime": json['sleepTime'].toString(),
      "deviceId": json['deviceId'],
      "sourceId": json['sourceId'],
      "sourceName": json['sourceName'],
    };
    List arr = [];
    arr.add(obj);
    print('obj >>>>>>>>>>>>>>>>>>>>>>>>>>>>  $arr');
    XHttp.putJson("/app/sleep/upload", {'data': arr})
        .then((res) {})
        .catchError((onError) {});
  }
}
