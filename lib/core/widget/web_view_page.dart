import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

class WebViewPage extends StatefulWidget {
  WebViewPage();
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String url = Get.parameters['url']!;
    print(url);
    return new MaterialApp(
      routes: {
        "/": (_) => new WebviewScaffold(
              url: url,
              appBar: AppBar(
                title: Text(Get.parameters['title']!,
                    style: TextStyle(fontSize: 15)),
                titleSpacing: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Get.back();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Share.share(url);
                      }),
                ],
              ),
            ),
      },
    );
    // WebviewScaffold(
    //   url: url,
    //   withLocalStorage: true,
    //   withJavascript: true,
    //   hidden: true,
    //   key: _scaffoldKey,
    //   appBar: AppBar(
    //     title: Text(Get.parameters['title']!, style: TextStyle(fontSize: 15)),
    //     titleSpacing: 0,
    //     actions: <Widget>[
    //       IconButton(
    //           icon: Icon(Icons.share),
    //           onPressed: () {
    //             Share.share(url);
    //           }),
    //     ],
    //   ),
    // )
    ;
  }
}
