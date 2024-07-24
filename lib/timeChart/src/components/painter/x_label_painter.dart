import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '/timeChart/src/components/painter/chart_engine.dart';
import '/timeChart/src/components/translations/translations.dart';
import '/timeChart/src/components/view_mode.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

abstract class XLabelPainter extends ChartEngine {
  static const int toleranceDay = 1;

  XLabelPainter({
    required super.viewMode,
    required super.context,
    this.firstDataHasChanged = false,
    required super.dayCount,
    required super.firstValueDateTime,
    required super.repaint,
    required super.scrollController,
  });

  final bool firstDataHasChanged;

  @override
  void paint(Canvas canvas, Size size) {
    setDefaultValue(size);
    drawXLabels(canvas, size, firstDataHasChanged: firstDataHasChanged);
  }

  void drawXLabels(
    Canvas canvas,
    Size size, {
    bool firstDataHasChanged = false,
  }) {
    final weekday = getShortWeekdayList(context);
    final viewModeLimitDay = viewMode.dayCount;
    final dayFromScrollOffset = currentDayFromScrollOffset - toleranceDay;

    DateTime currentDate =
        firstValueDateTime!.add(Duration(days: -dayFromScrollOffset));

    void turnOneBeforeDay() {
      currentDate = currentDate.add(const Duration(days: -1));
    }

    var localSleepData = [];
    // 本地存储
    if (box.read('sleepData') != null) {
      localSleepData = jsonDecode(box.read('sleepData'));
    } else {
      print('x没取到');
    }
    String goal = box.read('sleepGoal') ?? '8.0';
    List<String> time = goal.split('.');
    int goalMinutes = int.parse(time[0]) * 60 + int.parse(time[1]);

    String getEmoji(int score) {
      switch (score) {
        case 0:
          return "😴";
        case 1:
          return "😟";
        case 2:
          return "😕";
        case 3:
          return "😐";
        case 4:
          return "🙂";
        case 5:
          return "😄";

        default:
          return "";
      }
    }

    for (int i = dayFromScrollOffset;
        i <= dayFromScrollOffset + viewModeLimitDay + toleranceDay * 2;
        i++) {
      late String text;
      late String month;
      late String year;
      bool isDashed = true;

      switch (viewMode) {
        case ViewMode.weekly:
          // text = weekday[currentDate.weekday % 7];
          text = currentDate.day.toString();
          month = currentDate.month.toString();
          year = currentDate.year.toString();
          if (currentDate.weekday == DateTime.sunday) isDashed = false;
          turnOneBeforeDay();
          break;
        case ViewMode.monthly:
          text = currentDate.day.toString();
          month = currentDate.month.toString();
          year = currentDate.year.toString();
          turnOneBeforeDay();
          // 월간 보기 모드는 7일에 한 번씩 label 을 표시한다.
          if (i % 7 != (firstDataHasChanged ? 0 : 6)) continue;
      }

      final dx = size.width - (i + 1) * blockWidth!;
      _drawXText(canvas, size, text, text.length == 1 ? dx + 11 : dx + 7);
      late String emojiText = '';
      if (localSleepData.isNotEmpty) {
        int differenceMinute = 0;
        for (var j = 0; j < localSleepData.length; j++) {
          if (localSleepData[j]['end'] != '') {
            DateTime start = DateTime.parse(localSleepData[j]['start']);
            DateTime end = DateTime.parse(localSleepData[j]['end']);
            String endDay = end.day.toString();
            String endMonth = end.month.toString();
            String endYear = end.year.toString();
            if (endDay == text && endMonth == month && endYear == year) {
              differenceMinute = end.difference(start).inMinutes;
              double score =
                  double.parse(localSleepData[j]['score'].toString());
              // print('$text >>>>>>>>>>>>>>>>>> $score');
              if (score > 0) {
                emojiText = getEmoji(score.toInt());
              } else {
                if (differenceMinute >= goalMinutes) {
                  emojiText = getEmoji(5);
                } else {
                  if (goalMinutes - differenceMinute <= 30) {
                    emojiText = getEmoji(4);
                  } else if (goalMinutes - differenceMinute <= 60) {
                    emojiText = getEmoji(3);
                  } else if (goalMinutes - differenceMinute <= 90) {
                    emojiText = getEmoji(2);
                  } else if (goalMinutes - differenceMinute <= 120) {
                    emojiText = getEmoji(1);
                  } else if (goalMinutes - differenceMinute <= 150) {
                    emojiText = getEmoji(0);
                  }
                }
              }
              break;
            }
          }
        }
        _drawXText(
            canvas, Size(size.width, size.height - 15), emojiText, dx + 6);
      }
      _drawVerticalDivideLine(canvas, size, dx, isDashed);
    }
  }

  void _drawXText(Canvas canvas, Size size, String text, double dx) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textTheme.bodyText2!.copyWith(color: kTextColor),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final dy = size.height - textPainter.height;
    textPainter.paint(canvas, Offset(dx + paddingForAlignedBar, dy));
  }

  /// 분할하는 세로선을 그려준다.
  void _drawVerticalDivideLine(
    Canvas canvas,
    Size size,
    double dx,
    bool isDashed,
  ) {
    Paint paint = Paint()
      ..color = kLineColor3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = kLineStrokeWidth;

    Path path = Path();
    path.moveTo(dx, 0);
    path.lineTo(dx, size.height);

    canvas.drawPath(
      isDashed
          ? dashPath(path,
              dashArray: CircularIntervalList<double>(<double>[2, 2]))
          : path,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant XLabelPainter oldDelegate) {
    return true;
  }
}
