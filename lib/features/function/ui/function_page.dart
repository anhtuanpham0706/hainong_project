import 'dart:io';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_modules.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/features/function/tool/map_task/map_task_page.dart';
import 'package:hainong/features/function/ui/wed_2nong.dart';
import 'package:hainong/features/login/login_page.dart';
import 'function_item.dart';

class FunctionPage extends StatefulWidget {
  final dynamic modules;
  const FunctionPage(this.modules, {Key? key}):super(key: key);
  @override
  _FunctionPageState createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {

  @override
  void dispose() {
    if (Constants().isLogin) Constants().indexPage = null;
    Util.clearPermission();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = Container(height: 0.5, color: Colors.black12, margin: EdgeInsets.symmetric(vertical: 40.sp));
    return Scaffold(backgroundColor: Colors.white, appBar: AppBar(elevation: 5,
        leading: ButtonImageWidget(200, () => UtilUI.goBack(context, false),
            Row(children: [
              SizedBox(width: 40.sp),
              Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white),
              Image.asset('assets/images/ic_logo.png', width: 200.sp, fit: BoxFit.fill)
            ])),
        leadingWidth: 240.sp + 24, automaticallyImplyLeading: false,
        title: Padding(padding: EdgeInsets.only(right: 240.sp + 24), child: const TitleHelper('ttl_function'))),
        body: ListView.separated(padding: EdgeInsets.all(40.sp),
            itemCount: widget.modules.length, separatorBuilder: (context, index) => line,
            itemBuilder: (context, index) => _GroupItem(widget.modules[index])));
  }
}

class _GroupItem extends StatelessWidget {
  final Map<String, ModuleModel> list;
  const _GroupItem(this.list, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: EdgeInsets.only(bottom: 40.sp), child:
    Text(list.entries.first.value.group_name.toUpperCase(), style: TextStyle(fontSize: 50.sp, color: StyleCustom.primaryColor))),
    Wrap(runSpacing: 40.sp, alignment: WrapAlignment.start, children: _getItems(context))
  ], crossAxisAlignment: CrossAxisAlignment.start);

  List<Widget> _getItems(BuildContext context) {
    final List<Widget> temp = [];
    list.forEach((key, value) => temp.add(_getItem(context, value)));
    return temp;
  }

  Widget _getItem(BuildContext context, ModuleModel item) {
    switch(item.app_type) {
      case 'news': return FunctionItem(item.name, item.icon, () => _nextPage(context, NewsListPage(), 'Function Screen -> Open List News Screen'));
      //case 'video': return FunctionItem(item.name, item.icon, () => _nextPage(context, NewsListPage(isVideo: true), 'Function Screen -> Open List Videos Screen'));
      case 'market_price': return FunctionItem(item.name, item.icon, () => _nextPage(context, MarketPricePage(), 'Function Screen -> Open Market Price'));
      case 'weather': return FunctionItem(item.name, item.icon, () => _nextPage(context, WeatherListPage(), 'Function Screen -> Open Weather Screen'));
      case 'technical_process': return FunctionItem(item.name, item.icon, () => _nextPage(context, TechnicalProcessListPage(), 'Function Screen -> Open Technical Process Screen'));
      case 'short_video': return FunctionItem(item.name, item.icon, () => _nextPage(context, VideoListPage(), 'Function Screen -> Open Short Video Screen'));

      case 'npk': return FunctionItem(item.name, item.icon,
        () => _nextPage(context, HomeNPKPage(url: Constants().baseUrl,
            title: const Padding(padding: EdgeInsets.only(right: 48),
                child: TitleHelper('Phối trộn phân bón NPK',
                url: 'https://help.hainong.vn/muc/4'))),
        'Function Screen -> Open NPK Module Screen'));
      case 'traceability': return FunctionItem(item.name, item.icon, () =>
        _nextPage(context, TraceabilityPage(url: Constants().baseUrl,isLogin: Constants().isLogin), 'Function Screen -> Open NPK Module Screen'));
      case 'traning_data': return FunctionItem(item.name, item.icon, () => _nextPage(context, DiagnosePestsPage(), 'Function Screen -> Open Diagnose Pests Screen'));
      //case 'diagnostic_map': return FunctionItem(item.name, item.icon, () => _nextPage(context, const MapPage(), 'Function Screen -> Open Pests Map'));
      case 'farming_manager': return FunctionItem(item.name, item.icon, () => _nextPage(context, const FarmManagePage(), 'Function Screen -> Open Farming Management Screen', checkLogin: true));
      case 'knowledge_handbook': return FunctionItem(item.name, item.icon, () => _nextPage(context, const HandbookPage(), 'Function Screen -> Open Hand Books Screen'));
      case 'online_counseling': return FunctionItem(item.name, item.icon, () => _openVideoCall(context));
      case 'business_association': return FunctionItem(item.name, item.icon, () => _nextPage(context, BAListPage(), 'Function Screen -> Open Business Association Screen'));
      case 'handbook_of_pest': return FunctionItem(item.name, item.icon, () => _nextPage(context, PestsHandbookListPage(''), 'Function Screen -> Open Pests Hand Books Screen'));
      case 'mini_game': return FunctionItem(item.name, item.icon, () => _nextPage(context, GamePage(), 'Function Screen -> Open Mini Game Screen'));
      case 'shop_gitf': return FunctionItem(item.name, item.icon, () => _nextPage(context, GiftShopPage(), 'Function Screen -> Open Gift Shop Screen', checkLogin: true));
      case 'mission': return FunctionItem(item.name, item.icon, () => _nextPage(context, const MissionPage(), 'Function Screen -> Open Mission Screen'));
      case 'contribution_mission': return FunctionItem(item.name, item.icon, () => _nextPage(context, ExeContributionListPage(),
          'Function Screen -> Open Contribution Mission Screen', checkLogin: true));
      case 'chat_message': return FunctionItem(item.name, item.icon, () => _nextPage(context, FriendListPage(),
          'Function Screen -> Open FriendPage Screen', checkLogin: true));
      case 'farming_map': return FunctionItem(item.name, item.icon, () => _nextPage(context, MapTaskPage(), 'Function Screen -> Open Task Map'));
      default: return const SizedBox();
    }
  }

  void _nextPage(BuildContext context, dynamic page, String path, {bool checkLogin = false}) {
    if (checkLogin && !Constants().isLogin) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_login_create_account'));
      return;
    }
    UtilUI.goToNextPage(context, page);
    if (path.isNotEmpty) Util.trackActivities('modules', path: path);
  }

  void _openWeb2Nong(BuildContext context, String url) {
    UtilUI.goToNextPage(context, Web2Nong(url));
    Util.trackActivities('modules', path: 'Function Screen -> Open Web 2Nong');
  }

  _openVideoCall(BuildContext context) async {
    if (Constants().isLogin) {
      const trackBookScreen = 'Function Screen -> Open Hand Books Screen';
      const trackCallScreen = 'Function Screen -> Open Call Expert';
      UtilUI.chatCallNavigation(context, () {
        _nextPage(context, ExpertPage(
            callBackContact: () {
              _nextPage(context, const HandbookPage(), trackBookScreen);
            },
            callBackLogin: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()))),
          trackCallScreen,
        );
      });
    } else UtilUI.showCustomDialog(context, MultiLanguage.get('msg_login_create_account'));
  }
}
