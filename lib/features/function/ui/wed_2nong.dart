import 'package:hainong/common/util/util_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class Web2Nong extends StatelessWidget {
  final String url;
  final bool hasTitle, isClose;
  const Web2Nong(this.url, {this.hasTitle = false, this.isClose = false, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(elevation: 0, centerTitle: true,
      title: UtilUI.createLabel('Hướng dẫn', textAlign: TextAlign.center),
      leading: isClose ? IconButton(onPressed: () => UtilUI.goBack(context, false),
          icon: const Icon(Icons.close, color: Colors.white)) : const SizedBox()),
      body: WebView(initialUrl: url, javascriptMode: JavascriptMode.unrestricted));
}