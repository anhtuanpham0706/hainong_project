import 'dart:async';
import 'dart:io';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/features/main/ui/main_page.dart';
import 'notification_item_page.dart';
import '../notification_bloc.dart';
import '../notification_model.dart';

class NotificationListPage extends BasePage {
  NotificationListPage(Map<String, ModuleModel> modules, {Key? key}) : super(key: key, pageState: _NotificationListPageState(modules));
}

class _NotificationListPageState extends BasePageState {
  int _page = 1, _shopId = -1;
  final Map<String, ModuleModel> modules;
  final ScrollController _scroller = ScrollController();
  final List<NotificationModel> _list = [];
  final HomeBloc _blocHome = HomeBloc(HomeState());
  late StreamSubscription _stream;
  bool _lock = false;

  _NotificationListPageState(this.modules);

  @override
  void dispose() {
    _list.clear();
    _blocHome.close();
    _scroller.dispose();
    _stream.cancel();
    Util.clearPermission();
    super.dispose();
  }

  @override
  initState() {
    Util.getPermission();
    SharedPreferences.getInstance().then((value) {
      _shopId = value.getInt(Constants().shopId)??-1;
    });
    bloc = NotificationBloc(isList: true);
    super.initState();
    _stream = BlocProvider.of<MainBloc>(context).stream.listen((state) {
      if (state is CountNotificationMainState && (state.loadList == null || state.loadList!)) _initLoadList();
    });
    bloc!.stream.listen((state) {
      if (state is LoadNotificationsState) {
        _handleResponse(state.response, _handleLoadList);
        _lock = false;
      } else if (state is DeleteAllNotificationsState) {
        _handleResponse(state.response, _handleAll, passString: true);
      } else if(state is ReadAllNotificationState) {
        _handleResponse(state.response, _handleAll, passString: true);
      }
    });
    _blocHome.stream.listen((state) {
      if (state is SharePostHomeState) {
        _postCallback(state);
      } else if (state is WarningPostHomeState && isResponseNotError(state.response)) {
        UtilUI.showCustomDialog(
            context, MultiLanguage.get(languageKey.msgWarningPostSuccess),
            title: MultiLanguage.get(languageKey.ttlAlert));
      } else if (state is TransferPointState && isResponseNotError(state.response, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_transfer'),
            title: MultiLanguage.get(languageKey.ttlAlert));
      }
    });
    _initLoadList();
    _scroller.addListener(() {
      if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) bloc!.add(LoadNotificationsEvent(_page));
    });
  }

  _initLoadList() {
    if (_lock) return;
    _lock = true;
    _page = 1;
    if (_list.isNotEmpty) setState(() => _list.clear());
    bloc!.add(LoadNotificationsEvent(_page));
  }

  _handleResponse(BaseResponse base, Function funHandleDetail, {bool passString = false}) {
    if (base.checkTimeout()) {
      if (constants.errorMsg == null || constants.errorMsg != 'timeout') constants.errorMsg = 'timeout';
      UtilUI.showDialogTimeout(context);
    } else if (base.checkOK(passString: passString)) {
      constants.errorMsg?.clear();
      constants.errorMsg = null;
      funHandleDetail(base);
    } else {
      final now = DateTime.now();
      if (constants.errorMsg != null) {
        if (constants.errorMsg['msg'] != base.data || now.difference(constants.errorMsg['time']).inMilliseconds > 3000) {
          UtilUI.showCustomDialog(context, base.data);
        }
      } else UtilUI.showCustomDialog(context, base.data);
      constants.errorMsg = {'msg': base.data, 'time': now};
    }
  }

  _handleLoadList(BaseResponse base) {
    final List<NotificationModel> listTemp = base.data.list;
    if (listTemp.isNotEmpty) {
      _list.addAll(listTemp);
      listTemp.length == constants.limitPage ? _page++ : _page = 0;
    } else _page = 0;
  }

  _handleAll(base) => BlocProvider.of<MainBloc>(context).add(CountNotificationMainEvent());

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    Scaffold(appBar: AppBar(automaticallyImplyLeading: false, elevation: 10, title: Row(children: [
        ButtonImageWidget(200, () => UtilUI.goBack(context, false),
          Row(children: [
            Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white),
            Image.asset('assets/images/ic_logo.png', width: 200.sp, fit: BoxFit.fill)
          ])),
        //Image.asset('assets/images/ic_logo.png', width: 200.sp, fit: BoxFit.fill),
        Expanded(child: UtilUI.createLabel(MultiLanguage.get('ttl_notifications'), textAlign: TextAlign.center)),
        SizedBox(width: 72.sp + 24)
      ]), centerTitle: false, actions: [IconButton(onPressed: () {_selectOption(context);}, icon: Icon(Icons.more_vert, color: Colors.white, size: 54.sp))]),
        backgroundColor: StyleCustom.primaryColor,
        body: RefreshIndicator(child: BlocBuilder(bloc: bloc, buildWhen: (state1, state2) => state2 is LoadNotificationsState,
        builder: (context, state) => ListView.builder(padding: EdgeInsets.only(top: 40.sp),
          controller: _scroller, itemCount: _list.length, physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            String temp = _list[index].sending_group;
            if (temp.isEmpty) temp = _list[index].notification_type;
            return NotificationItemPage(_list[index], _shopId, _blocHome, _openMainTab, module: modules[temp]);
          })),
        onRefresh: () async => _initLoadList())),
    Loading(bloc)
  ]);

  //void _openMainTab(int index) => BlocProvider.of<MainBloc>(context).add(ChangeIndexEvent(index: index));
  void _openMainTab(int index) => UtilUI.goToNextPage(context, MainPage(index: index, funDynamicLink: Constants().funChatBotLink));

  void _selectOption(BuildContext context) async {
    List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_read_all.png', " Đọc tất cả", () {
      _readAll();
    }, false));
    options.add(ItemOption('assets/images/ic_delete_outline.png', " Xóa tất cả",(){
      _deleteAll();
    }, false));

    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
  }

  void _deleteAll() {
    Navigator.of(context).pop();
    if (_list.isNotEmpty) {
      UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá hết tất cả các thông báo không?', isActionCancel: true)
          .then((value) {
            if (value != null && value) bloc!.add(DeleteAllNotificationsEvent());
      });
    }
  }

  void _readAll() {
    Navigator.of(context).pop();
    if (_list.isNotEmpty) bloc!.add(ReadAllNotificationEvent());
  }

  void _postCallback(state) {
    final BaseResponse base = state.response as BaseResponse;
    if (!base.checkTimeout() && base.checkOK(passString: true)) Navigator.of(context).pop(state);
  }
}
