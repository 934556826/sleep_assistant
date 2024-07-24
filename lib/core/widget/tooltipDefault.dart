import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class myTooltipDefault extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final double height;
  const myTooltipDefault({
    Key? key,
    required this.message,
    required this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> arr = message.split(';');
    DateTime start = DateTime.parse(arr[2]);
    String startTime = DateFormat('yyyy-MM-dd HH:mm').format(start);
    double sleepTimeMin = double.parse(arr[1]);
    String sleepTime = sleepTimeMin % 60 == 0
        ? '${(sleepTimeMin ~/ 60)}h'
        : '${(sleepTimeMin ~/ 60)}h ${(sleepTimeMin % 60).toInt()}min';
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 0),
      child: Card(
          margin: EdgeInsets.all(0),
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.loose,
            children: [
              // Image(
              //   image: AssetImage("images/images.jpg"),
              //   width: 300,
              //   height: height <= 100 ? 100 : height,
              //   fit: BoxFit.cover,
              // ),
              Container(
                  // width: 300,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  margin: margin,
                  decoration: decoration,
                  child: Center(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Column(
                      children: [
                        Text(
                          '開始時間: ${startTime}',
                          style: TextStyle(
                              color: Color(0xffffffff),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          'Pegasi起動時間: ${arr[0]}min',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 192, 0),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          '睡眠時間: ${sleepTime}',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ))
            ],
          )),
    );
  }
}
