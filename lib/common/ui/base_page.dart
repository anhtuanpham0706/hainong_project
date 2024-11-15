import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/features/comment/ui/comment_item_page.dart';
import 'package:hainong/features/main/bloc/main_bloc.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/features/function/ui/wed_2nong.dart';
import '../import_lib_system.dart';
import '../base_response.dart';
import 'button_custom.dart';
import 'label_custom.dart';
import 'loading.dart';

abstract class ChangeUICallback {
  void collapseHeader(bool value);

  void collapseFooter(bool value);
}

abstract class ScrollCallback {
  void scrollTop();
}

class BasePage extends StatefulWidget {
  final BasePageState pageState;

  const BasePage({required this.pageState, Key? key}):super(key:key);

  @override
  BasePageState createState() => pageState;

  void search(String key) => pageState.search(key);

  void dispose() => pageState.dispose();
}

class BasePageState extends State<BasePage> with AutomaticKeepAliveClientMixin {
  BaseBloc? bloc;
  final Constants constants = Constants();
  final LanguageKey languageKey = LanguageKey();
  ChangeUICallback? callback;
  bool? alive;

  @override
  bool get wantKeepAlive => true;

  @override
  dispose() {
    constants.errorMsg?.clear();
    constants.errorMsg = null;
    if (bloc is! MainBloc) bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    if (alive != null) return super.build(context);
    return Scaffold(
        body: GestureDetector(
            onVerticalDragDown: (details) {clearFocus();},
            onTapDown: (value) {clearFocus();},
            child: Stack(children: [
              Column(children: [
                Expanded(flex: 4, child: Image.asset('assets/images/ic_line_header.png',
                    fit: BoxFit.fill, width: 1.sw)),
                Expanded(flex: 6, child: Container(color: StyleCustom.backgroundColor))
              ]),
              createUI(),
              Loading(bloc)
            ])));
  }

  Widget createUI() => Column(children: [
      createHeaderUI(),
      createBodyUI(),
      createFooterUI()
  ]);

  Widget createHeaderUI() => const SizedBox();

  Widget subHeaderUI(String title, {hasIcon = false}) =>
      Padding(padding: EdgeInsets.only(top: 40.sp + WidgetsBinding.instance.window.padding.top.sp),
          child: hasIcon ? Image.asset(title, height: 120.sp)
              : LabelCustom(MultiLanguage.get(title), size: 50.sp));

  Widget createBodyUI() => Expanded(child: Container(
      decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.sp),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 1) // changes position of shadow
                )
              ]),
      margin: EdgeInsets.fromLTRB(60.sp, 40.sp, 60.sp, 0),
      child: subBodyUI()));

  Widget subBodyUI() => Column(children: [
    subBodyHeaderUI(),
    subBodyBodyUI(),
    ignoreUI(),
    subBodyFooterUI(),
  ]);

  Widget ignoreUI() => const SizedBox();

  Widget subBodyHeaderUI() => const SizedBox();

  Widget subBodyBodyUI() => Expanded(
    child: Padding(
      padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0),
      child: createFieldsSubBody(),
    ),
  );

  Widget createFieldsSubBody() => const SizedBox();

  Widget subBodyFooterUI() => Container(width: 1.sw, padding: EdgeInsets.all(40.sp),
      child: ButtonCustom(onPressBodyFooter, MultiLanguage.get(getButtonNameBodyFooter()), size: 52.sp));

  String getButtonNameBodyFooter() => '';

  void onPressBodyFooter() {}

  Widget createFooterUI() => Padding(
      padding: EdgeInsets.all(30.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LabelCustom(MultiLanguage.get(getMessageFooter()),
              color: StyleCustom.textColor6E, weight: FontWeight.w300),
          TextButton(
              onPressed: onPressFooter,
              child: LabelCustom(MultiLanguage.get(getButtonNameFooter()),
                  color: StyleCustom.primaryColor, size: 46.sp))
        ]
      ));

  String getMessageFooter() => '';

  String getButtonNameFooter() => '';

  void onPressFooter() {}

  void goToSubPage(StatelessWidget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => page))
          .then((value) {getValueFromSecondPage(value);});

  bool isResponseNotError(BaseResponse state, {bool passString = false, bool showError = true}) {
    if (state.checkTimeout()) {
      if (constants.errorMsg == null || constants.errorMsg != 'timeout') constants.errorMsg = 'timeout';
      if (showError) UtilUI.showDialogTimeout(context);
      return false;
    }

    if (state.checkOK(passString: passString)) {
      constants.errorMsg?.clear();
      constants.errorMsg = null;
      return true;
    }

    if (showError && state.data != null) {
      final now = DateTime.now();
      if (constants.errorMsg != null) {
        if (constants.errorMsg['msg'] != state.data || now.difference(constants.errorMsg['time']).inMilliseconds > 3000) {
          UtilUI.showCustomDialog(context, state.data);
        }
      } else UtilUI.showCustomDialog(context, state.data);
      constants.errorMsg = {'msg': state.data, 'time': now};
      return false;
    }

    if (showError && state.data != null && (state.data.contains('cần tham gia') || state.data.contains('hết')) &&
        state.data.contains('tính năng này')) UtilUI.showCustomDialog(context, state.data);

    return false;
  }

  void clearFocus() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) FocusManager.instance.primaryFocus!.unfocus();
    if (CommentItemPageState.idComment != null) {
      BlocProvider.of<MainBloc>(context).add(HideTextFieldEvent(CommentItemPageState.idComment == -1));
    }
  }

  void search(String key) {}

  void getValueFromSecondPage(value) {}

  void trackActivities(String function, {String method = 'onTap', String path = ''}) => bloc?.add(TrackEvent(path, function, method: method));

  Widget buttonHelper({String url = 'https://help.hainong.vn'}) =>
      ButtonImageWidget(100, () => UtilUI.goToNextPage(context, Web2Nong(url, hasTitle: true, isClose: true)),
          Icon(Icons.info_outline, color: Colors.white, size: 56.sp));
}

class TempPage extends BasePage {
  TempPage({Key? key}) : super(pageState: _TempPageState(), key: key);
}
class _TempPageState extends BasePageState {
  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => const SizedBox();
}
