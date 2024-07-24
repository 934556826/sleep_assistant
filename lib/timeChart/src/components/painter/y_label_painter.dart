import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/timeChart/src/components/painter/chart_engine.dart';
import 'package:path_drawing/path_drawing.dart';
import '/timeChart/src/components/painter/chart_engine.dart';
import '/timeChart/src/components/translations/translations.dart';
import '/timeChart/src/components/view_mode.dart';

abstract class YLabelPainter extends ChartEngine {
  YLabelPainter({
    required super.viewMode,
    required super.context,
    required this.topHour,
    required this.bottomHour,
  });

  final int topHour;
  final int bottomHour;

  @override
  @nonVirtual
  void paint(Canvas canvas, Size size) {
    setRightMargin();
    drawYLabels(canvas, size);
  }

  void drawYLabels(Canvas canvas, Size size);

  /// Y 축의 텍스트 레이블을 그린다.
  void drawYText(Canvas canvas, Size size, String text, double y) {
    TextSpan span = TextSpan(
      text: text,
      style: textTheme.bodyText2!.copyWith(color: kTextColor),
    );

    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();

    tp.paint(
      canvas,
      Offset(
        size.width - rightMargin + kYLabelMargin + 30,
        y - textTheme.bodyText2!.fontSize! / 2,
      ),
    );
  }

  /// 그래프의 수평선을 그린다
  void drawHorizontalLine(Canvas canvas, Size size, double dy) {
    Paint paint = Paint()
      // ..color = kLineColor1
      ..color = const Color.fromARGB(255, 130, 152, 250)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = kLineStrokeWidth;

    Path path = Path();
    path.moveTo(0, dy);
    path.lineTo(size.width - rightMargin + 36, dy);

    // 绘制虚线
    canvas.drawPath(
      dashPath(path, dashArray: CircularIntervalList<double>(<double>[2, 2])),
      paint,
    );

    // canvas.drawLine(Offset(0, dy), Offset(size.width - rightMargin, dy), paint);
  }

  @override
  bool shouldRepaint(covariant YLabelPainter oldDelegate) {
    return oldDelegate.topHour != topHour ||
        oldDelegate.bottomHour != bottomHour;
  }
}
