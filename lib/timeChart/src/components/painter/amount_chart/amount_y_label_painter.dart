import 'package:flutter/material.dart';
import '/timeChart/src/components/painter/y_label_painter.dart';
import '../chart_engine.dart';
import 'package:get_storage/get_storage.dart';

class AmountYLabelPainter extends YLabelPainter {
  AmountYLabelPainter({
    required super.context,
    required super.viewMode,
    required super.topHour,
    required super.bottomHour,
  });

  final box = GetStorage();

  String zeroPadding(int num) {
    return num < 10 ? '0$num' : '$num';
  }

  @override
  void drawYLabels(Canvas canvas, Size size) {
    final String hourSuffix = translations.shortHour;
    final String minuteSuffix = translations.shortMinute;
    final double labelInterval =
        (size.height - kXLabelHeight) / (topHour - bottomHour);
    final int hourDuration = topHour - bottomHour;
    final int timeStep;
    if (hourDuration >= 12) {
      timeStep = 3;
    } else if (hourDuration >= 8) {
      timeStep = 2;
    } else {
      timeStep = 1;
    }
    double posY = 0;

    String goal = box.read('sleepGoal') ?? '8.0';
    List<String> time = goal.split('.');
    late double posYY;
    if ((double.parse(goal) * 100) >= hourDuration * 100) {
      posYY = 0;
    } else {
      posYY = size.height -
          kXLabelHeight -
          ((labelInterval * (double.parse(goal) * 100)) / 100);
    }

    if (int.parse(time[1]) > 0) {
      drawYText(
          canvas,
          size,
          '${time[0]} $hourSuffix\n${zeroPadding(int.parse(time[1]))} $minuteSuffix',
          posYY - 8);
    } else {
      drawYText(canvas, size, '${time[0]} $hourSuffix', posYY);
    }

    drawHorizontalLine(canvas, size, posYY);

    // for (int time = topHour; time >= bottomHour; time = time - timeStep) {
    //   drawYText(canvas, size, '$time $hourSuffix', posY);
    //   if (topHour > time && time > bottomHour) {
    //     print('posY $size $posY');
    //     drawHorizontalLine(canvas, size, posY);
    //   }

    //   posY += labelInterval * timeStep;
    // }
  }
}
