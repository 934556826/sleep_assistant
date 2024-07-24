import 'package:flutter/material.dart';

class MyIcons {
  // 静态变量可以通过外部直接访问,不需要将类实例化implement
  // 实例化后将无法通过外部直接调用 static 成员
  static const IconData pegasi =
      IconData(0xe600, fontFamily: 'iconfont', matchTextDirection: true);

  static const IconData off =
      IconData(0xe673, fontFamily: 'iconfont', matchTextDirection: true);
}
