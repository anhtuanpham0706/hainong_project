import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'features/main2/ui/main2_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    ApiClient().checkVersion().then((url) {
      if (url.isEmpty) return _onAfterBuild();
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_new_version'),
        isActionCancel: true,title: MultiLanguage.get('ttl_notify')).then((value) {
          if (value != null && value) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }).whenComplete(() => _onAfterBuild());
    });
  }

  @override
  Widget build(BuildContext context) => Image.asset('assets/images/v2/bg_splash_v2.png', fit: BoxFit.cover);

  void _onAfterBuild() => Timer(const Duration(seconds: 1), () =>
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main2Page())));
}
