import 'package:hainong/features/comment/model/comment_model.dart';
import 'package:hainong/features/comment/ui/comment_page.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/profile/ui/show_avatar_page.dart';
import 'package:hainong/features/rating/create_rating_page.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx/webviewx.dart';
import '../technical_process_model.dart';

class TechnicalProcessDetailPage extends StatefulWidget {
  final TechnicalProcessModel item;
  const TechnicalProcessDetailPage(this.item, {Key? key}) :super(key: key);
  @override
  _TechnicalProcessDetailPageState createState() => _TechnicalProcessDetailPageState();
}
class _TechnicalProcessDetailPageState extends State<TechnicalProcessDetailPage> {
  final NewsBloc bloc = NewsBloc();
  WebViewXController? _controller;
  bool _isFinished = false;
  String name = '';

  @override
  void dispose() {
    bloc.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        name = pref.getString(Constants().name)?? 'User';
      });
    });
    if (Constants().isLogin) {
      bloc.stream.listen((state) {
        if (state is LoadTechProDtlState) widget.item.copy(state.response.data);
      });
      bloc.add(LoadTechProDtlEvent(widget.item.id));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0, title: UtilUI.createLabel(
          MultiLanguage.get('lbl_details'), textAlign: TextAlign.center), centerTitle: true),
          body: ListView(children: [
            /*Container(height: 0.2.sh, decoration: BoxDecoration(
              image: DecorationImage(image: FadeInImage.assetNetwork(image: Util.getRealPath(widget.item.image),
                  placeholder: 'assets/images/ic_default.png').image, fit: BoxFit.fill)
            )),*/
            Container(padding: EdgeInsets.fromLTRB(20.sp, 40.sp, 20.sp, 20.sp),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.item.title, style: TextStyle(fontSize: 54.sp, color: StyleCustom.primaryColor, fontWeight: FontWeight.w500)),
                  SizedBox(height: 15.sp),
                  Row(children: [
                    Icon(Icons.calendar_today, color: StyleCustom.textColor6C, size: 24.sp),
                    SizedBox(width: 10.sp),
                    Text(Util.dateToString(Util.stringToDateTime(widget.item.created_at),
                        locale: Constants().localeVI, pattern: 'dd/MM/yyyy HH:mm:ss'),
                        style: TextStyle(color: StyleCustom.textColor6C, fontSize: 30.sp))
                  ]),
                  BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is SetHeightState,
                      builder: (context, state) {
                        double height = 10, hasHeight = 0;
                        if (state is SetHeightState) {
                          height = state.height;
                          hasHeight = 1;
                        }
                        return Container(margin: EdgeInsets.only(top: 20.sp), width: 1.sw, height: height, child:
                          WebViewX(jsContent: {EmbeddedJsContent(js: Constants().jvWebView, mobileJs: Constants().jvWebView)},
                            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.alwaysAllow,
                            initialContent: widget.item.content,
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
                              if (await canLaunchUrl(Uri.parse(http))) {
                                Util.isImage(http) ? UtilUI.goToNextPage(context, ShowAvatarPage(http)) : launchUrl(Uri.parse(http), mode: LaunchMode.externalApplication);
                              }
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
                        )
                        );
                      })
            ])),
            Container(color: Colors.white, padding: EdgeInsets.symmetric(vertical: 60.sp), //margin: EdgeInsets.only(top: 20.sp),
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.all(20.sp),
                      child: UtilUI.createLabel(
                          '$name ơi\n'+MultiLanguage.get('msg_what_do_you_think'),
                          color: Colors.black,
                          line: 3,
                          fontWeight: FontWeight.normal)),
                  BlocBuilder(bloc: bloc,
                      buildWhen: (state1, state2) => state2 is ChangeTagManageState || state2 is LoadTechProDtlState,
                      builder: (context, state) => UtilUI.createStars(
                          onClick: (index) => _clickStart(index),
                          hasFunction: true,
                          rate: widget.item.comment.rate,
                          size: 65.sp))
                ])),
            Padding(padding: EdgeInsets.all(20.sp),
                child: Text(MultiLanguage.get('comment'), style: TextStyle(fontSize: 48.sp, color: Colors.black, fontWeight: FontWeight.w500))),
            BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is SetHeightState ,
                builder: (context, state) => state is SetHeightState || _isFinished ?
                CommentPage(Post(classable_id: widget.item.id, classable_type: widget.item.classable_type), height: 0.42.sh, hasHeader: false, showTime: false) : const SizedBox())
          ])
      )
    ]);
  }

  void _clickStart(int index) {
    if (widget.item.comment.rate > 0) return;
    Constants().isLogin ? _goToProductList(CreateRatingPage(index, widget.item.classable_type, int.parse(widget.item.id), widget.item.comment.id)) :
    UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgLoginOrCreate));
  }

  void _goToProductList(dynamic page) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => page))
          .then((value) => _pageCallback(value, context));

  void _pageCallback(value, final BuildContext context) {
    if (value != null && value is CommentModel) {
      widget.item.comment.id = value.id;
      widget.item.comment.rate = value.rate;
      bloc.add(ChangeTagManageEvent());
      BlocProvider.of<MainBloc>(context).add(ReloadListCommentEvent());
    }
  }
}