import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/tab_item.dart';
import 'package:hainong/features/referrer/referrer_bloc.dart';
import 'package:hainong/features/referrer/referrer_event.dart';
import 'package:hainong/features/referrer/referrer_state.dart';
import 'package:hainong/features/referrer/ui/history/referrer_history_give_point_page.dart';
import 'package:hainong/features/referrer/ui/history/referrer_history_new_user_page.dart';
import 'package:hainong/features/referrer/ui/history/referrer_history_receive_point_page.dart';

class ReferrerHistoryViewPagerPage extends BasePage {
  ReferrerHistoryViewPagerPage({Key? key})
      : super(pageState: _ReferrerHistoryViewPagerPageState(), key: key);
}

class _ReferrerHistoryViewPagerPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final List<bool> _selectTab = [true, false, false];

  @override
  void dispose() {
    _scroller.dispose();
    _ctrSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ReferrerBloc(ReferrerState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is ChangeTabReferrerHistoryState) {
        _selectTab[state.index] = state.status;
      }
    });
  }

  _changeTab(int index) {
    if (_selectTab[index]) return;
    bloc!.add(ChangeTabReferrerHistoryEvent(0, false));
    bloc!.add(ChangeTabReferrerHistoryEvent(1, false));
    bloc!.add(ChangeTabReferrerHistoryEvent(2, false));
    bloc!.add(ChangeTabReferrerHistoryEvent(index, !_selectTab[index]));
  }

  @override
  Widget createFieldsSubBody() => BlocBuilder(
      bloc: bloc,
      buildWhen: (oldState, newState) => newState is ChangeTabReferrerHistoryState,
      builder: (context, state) => _selectTabUI());

  Widget _selectTabUI() {
    if (_selectTab[0]) {
      return ReferrerHistoryNewUserPage();
    } else if (_selectTab[1]) {
      return ReferrerHistoryReceiveGivePage();
    } else if (_selectTab[2]) {
      return ReferrerHistoryReceivePointPage();
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      body: GestureDetector(
          onTap: clearFocus,
          onHorizontalDragDown: (_) => clearFocus(),
          onVerticalDragDown: (_) => clearFocus(),
          child: Scaffold(
              backgroundColor: color,
              appBar: AppBar(
                elevation: 0,
                titleSpacing: 0,
                centerTitle: true,
                title: UtilUI.createLabel('Lịch sử giới thiệu'),
              ),
              body:
                  Column(children: [SizedBox(width: 1.sw, child: subBodyUI()), createBodyUI()]))));

  @override
  Widget createBodyUI() => Expanded(
      child: Container(padding: EdgeInsets.only(top: 20.sp), child: createFieldsSubBody()));

  @override
  Widget subBodyUI() => Stack(children: [
        GestureDetector(
            onTap: clearFocus,
            onHorizontalDragDown: (_) => clearFocus(),
            onVerticalDragDown: (_) => clearFocus(),
            child: BlocBuilder(bloc: bloc,
              buildWhen: (state1, state2) => state2 is ChangeTabReferrerHistoryState,
              builder: (context, state) {
                return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  TabItem(MultiLanguage.get("lbl_new_user"),0,_selectTab[0],_changeTab,size: 38.sp,expanded: false,),
                  TabItem(MultiLanguage.get("lbl_give_point"),1,_selectTab[1],_changeTab,size: 38.sp,),
                  TabItem(MultiLanguage.get("lbl_reciver_point"),2,_selectTab[2],_changeTab,size: 38.sp,),
                ]);
              },
            )),
        Loading(bloc)
      ]);
}
