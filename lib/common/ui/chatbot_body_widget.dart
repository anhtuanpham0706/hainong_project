import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final GlobalKey webViewKey = GlobalKey();

class ChatbotBodyWidget extends StatefulWidget {
  const ChatbotBodyWidget(this.funDynamicLink, {Key? key, this.chatUrl}) : super(key: key);
  final Function? funDynamicLink;
  final String? chatUrl;

  @override
  State<ChatbotBodyWidget> createState() => _ChatbotBodyWidgetState();
}

class _ChatbotBodyWidgetState extends State<ChatbotBodyWidget> {
  late String title;
  late Uri chatUri;
  String htmlContent = '';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowBackgroundAudioPlaying: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  @override
  void initState() {
    super.initState();
    setData();
    requestAudioPermissions();
  }

  void setData() {
    title = "Trợ lý 2Nông";
    chatUri = Uri.parse(widget.chatUrl ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 0.72.sh,
        width: 1.w,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        margin: EdgeInsets.all(16.h),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          child: Column(
            children: [
              InkWell(
                child: Container(
                    height: 100.h,
                    width: 1.sw,
                    color: StyleCustom.primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.h),
                            child: Text(title,
                                style: const TextStyle(color: Colors.white, fontSize: 14))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.h),
                          child: InkWell(
                            onTap: () {
                              webViewController?.reload();
                              Navigator.of(context).pop();
                            },
                            child: const Icon(Icons.clear, color: Colors.white),
                          ),
                        ),
                      ],
                    )),
              ),
              Expanded(child: FutureBuilder<bool>(
                builder: (context, state) {
                  return InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: WebUri(widget.chatUrl ?? "")),
                      initialSettings: settings,
                      onWebViewCreated: (controller) async {
                        webViewController = controller;
                        if (htmlContent.isNotEmpty == true) {
                          webViewController?.loadData(data: htmlContent);
                        }
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                            resources: request.resources, action: PermissionResponseAction.GRANT);
                      },
                      gestureRecognizers: gestureRecognizers,
                      onLoadStop: (controller, url) async {},
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;
                        if (!["chatbot.hainong.vn"].contains(uri.host)) {
                          webViewController?.reload();
                          Navigator.of(context).pop();
                          if (["cho2nong.page.link"].contains(uri.host)) {
                            FirebaseDynamicLinks.instance.getDynamicLink(uri).then((value) {
                              if (value != null && widget.funDynamicLink != null)
                                widget.funDynamicLink!(value);
                            });
                            return NavigationActionPolicy.CANCEL;
                          } else {
                            await launchUrl(uri);
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      });
                },
              ))
            ],
          ),
        ));
  }

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  Future<void> requestAudioPermissions() async {
    PermissionStatus status = await Permission.microphone.status;
    status = await Permission.microphone.request();
    if (status.isGranted) {
      //print('Quyền truy cập âm thanh đã được cấp');
    } else {
      //print('Quyền truy cập âm thanh không được cấp');
      UtilUI.showCustomDialog(context, 'Bạn vui lòng cấp quyền Microphone để sử dụng tính năng',
          alignMessageText: TextAlign.left);
    }
  }
}
