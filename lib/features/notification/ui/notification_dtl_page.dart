import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/features/profile/ui/show_avatar_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx/webviewx.dart';

class NotificationDtlPage extends StatefulWidget {
  final String title, content, createdAt;
  const NotificationDtlPage(this.title, this.content, this.createdAt, {Key? key}):super(key: key);
  @override
  _NotifyDtlPageState createState() => _NotifyDtlPageState();
}

class _NotifyDtlPageState extends State<NotificationDtlPage> {
  bool _isFinished = false;
  WebViewXController? _controller;
  final NewsBloc bloc = NewsBloc();

  @override
  void dispose() async {
    bloc.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(elevation: 5.sp, titleSpacing: 0, title: UtilUI.createLabel('Chi tiết thông báo'),
        centerTitle: true), backgroundColor: Colors.white,
        body: ListView(padding: EdgeInsets.all(40.sp), children: [
          LabelCustom(widget.title, color: Colors.black, size: 64.sp),
          SizedBox(height: 20.sp),
          Row(children: [
            Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp),
            SizedBox(width: 20.sp),
            LabelCustom(Util.strDateToString(widget.createdAt, pattern: 'dd/MM/yyyy HH:mm'), color: Colors.grey, size: 42.sp, weight: FontWeight.normal)
          ]),
          SizedBox(height: 40.sp),
          if (widget.content.isNotEmpty) BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is SetHeightState,
              builder: (context, state) {
                double height = 10, hasHeight = 0;
                if (state is SetHeightState) {
                  height = state.height;
                  hasHeight = 1;
                }
                return SizedBox(width: 1.sw, height: height, child: WebViewX(
                    jsContent: {EmbeddedJsContent(js: Constants().jvWebView, mobileJs: Constants().jvWebView)},
                    initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.alwaysAllow,
                    initialContent: '<style >html,body{padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px;}</style>' + widget.content,
                    initialSourceType: SourceType.html,
                    height: height,
                    width: 1.sw,
                    onWebViewCreated: (controller) => _controller = controller,
                    webSpecificParams: const WebSpecificParams(webAllowFullscreenContent: false),
                    mobileSpecificParams: const MobileSpecificParams(
                      androidEnableHybridComposition: true,
                    ),
                    navigationDelegate: (navigation) async {
                      if (!_isFinished) return NavigationDecision.navigate;
                      String http = navigation.content.source;
                      if (!http.contains('http')) http = 'https://$http';
                      //if (await canLaunchUrl(Uri.parse(http))) launchUrl(Uri.parse(http));
                      //if (await canLaunchUrl(Uri.parse(http))) {
                        Util.isImage(http) ? UtilUI.goToNextPage(context, ShowAvatarPage(http)) : launchUrl(Uri.parse(http), mode: LaunchMode.externalApplication);
                      //}
                      return NavigationDecision.prevent;
                    },
                    onPageFinished: (value) async {
                      _isFinished = true;
                      if (hasHeight == 0) {
                        //await _controller?.evalRawJavascript(Constants().jvWebView);
                        //await Future.delayed(const Duration(seconds: 1));
                        await _controller?.scrollBy(0, 10);
                        String heightStr = await _controller?.evalRawJavascript(
                            "document.documentElement.scrollHeight") ?? "0";
                        bloc.add(SetHeightEvent(double.parse(heightStr)));
                      }
                    }
                ));
              })
        ]));
  }
}