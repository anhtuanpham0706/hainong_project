import 'dart:io';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/features/login/login_page.dart';
import 'game_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:hainong/common/ui/loading.dart';

class GamePage extends BasePage {
  GamePage({Key? key}) : super(key: key, pageState: _GamePageState());
}

class _GamePageState extends BasePageState {
  final List _listGameInfo = [];

  @override
  void dispose() {
    if (Constants().isLogin) Constants().indexPage = null;
    _listGameInfo.clear();
    super.dispose();
  }

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
    _initBloc();
  }

  void _initBloc() {
    bloc = GameBloc();
    bloc!.stream.listen((state) {
      if (state is GameListStatusState) {
        if (isResponseNotError(state.resp)) setState(() => _listGameInfo.addAll(state.resp.data));
        if (constants.isLogin) bloc!.add(CheckMemPackageEvent(''));
      } else if (state is CheckMemPackageState) isResponseNotError(state.resp, passString: true);
    });
    bloc!.add(FetchGameListStatusEvent());
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    Scaffold(appBar: AppBar(elevation: 5, centerTitle: true,
      title: UtilUI.createLabel('Giải trí')),
      body: Stack(children: [
        ListView.builder(shrinkWrap: true, itemCount: _listGameInfo.length,
          itemBuilder: (context, index) => Padding(padding: const EdgeInsets.all(20),
            child: Row(children: [
              Expanded(flex: 2, child: ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.asset(_listGameInfo[index]['image'], fit: BoxFit.cover))),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: Column(children: [
                LabelCustom(_listGameInfo[index]['event_name'], color: Colors.black87, size: 22, weight: FontWeight.w500),
                Padding(padding: const EdgeInsets.symmetric(vertical: 4.8),
                  child: LabelCustom(_listGameInfo[index]['des'], color: Colors.grey, size: 18, weight: FontWeight.w300)),
                GestureDetector(
                  onTap: () async {
                    if (await UtilUI().alertVerifyPhone(context)) return;
                    constants.isLogin ? UtilUI.goToNextPage(context, GameItemPage(_listGameInfo[index]), funCallback: (value) {
                      if (value != null && value) _logout();
                    }) : _timeout();
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.videogame_asset_outlined, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Text("Chơi ngay", textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontSize: 20))
                    ]
                  ))
              ], crossAxisAlignment: CrossAxisAlignment.start))
            ]))),
        Loading(bloc)
      ]));

  void _timeout() => UtilUI.showCustomDialog(context, MultiLanguage.get('msg_login_create_account')).whenComplete(() => _logout());

  void _logout() {
    UtilUI.logout();
    UtilUI.clearAllPages(context);
    UtilUI.goToPage(context, LoginPage(), null);
  }
}

class GameItemPage extends StatefulWidget {
  final dynamic item;
  const GameItemPage(this.item, {Key? key}) : super(key: key);
  @override
  _GameItemPageState createState() => _GameItemPageState();
}

class _GameItemPageState extends State<GameItemPage> {
  WebViewController? _ctr;
  BaseBloc? _bloc;

  @override
  void dispose() {
    _ctr?.runJavascript('''window.location.href = "https://google.com";''');
    _bloc?.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.item['group_name'] == 'millionaire') {
      _bloc = BaseBloc(hasMemPackage: true);
      _bloc!.stream.listen((state) {
        if (state is CheckMemPackageState) {
          if ((state.resp is int && state.resp < 1) || (state.resp is! int && state.resp.containsKey('error'))) {
            UtilUI.showCustomDialog(context, state.resp is int ? 'Bạn cần gia hạn hoặc đăng ký gói cước để sử dụng tiếp tính năng này'
                : state.resp['error']).whenComplete(() => Navigator.of(context).pop(null));
            return;
          }
          if (widget.item['group_name'] == 'millionaire') _bloc!.add(UpdateMemPackageEvent('milions_2nong_event'));
        }
      });
      _bloc!.add(CheckMemPackageEvent(widget.item['group_name'] == 'millionaire' ? 'milions_2nong_event' : 'lucky_wheel_event'));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
      leading: IconButton(onPressed: () => UtilUI.goBack(context, false), icon: const Icon(Icons.close, color: Colors.white)),
      title: Padding(padding: const EdgeInsets.only(right: 48), child: TitleHelper(widget.item['event_name'], url: widget.item['help']))),
      body: WebView(initialUrl: widget.item['url'], javascriptMode: JavascriptMode.unrestricted,
          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          onWebViewCreated: (ctr) {
            _ctr = ctr;
          }, navigationDelegate: (navigate) {
            if (navigate.url.contains('token_timeout.html')) UtilUI.goBack(context, true);
            else if (navigate.url.contains('membership_package_expired.html')) UtilUI.goBack(context, false);
            return NavigationDecision.navigate;
          }));
}
