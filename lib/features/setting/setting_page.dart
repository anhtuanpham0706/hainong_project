import 'package:hainong/common/local_auth_api.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/divider_widget.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/task_bar_widget.dart';
import 'package:hainong/features/login/login_page.dart';
import 'package:hainong/features/reset_password_page.dart';
import 'package:local_auth/local_auth.dart';
import 'setting_bloc.dart';

class SettingPage extends BasePage {
  SettingPage({Key? key}) : super(key: key, pageState: _SettingPageState());
}

class _SettingPageState extends BasePageState {
  final List<int> values = [0, 0, 0, 1];

  @override
  initState() {
    bloc = SettingBloc(SettingState());
    bloc!.stream.listen((state) {
      if (state is UpdateSettingState && isResponseNotError(state.response)) {
        SharedPreferences.getInstance().then((prefs) {
            prefs.setInt('hidden_phone', values[0]);
            prefs.setInt('hidden_email', values[1]);
            prefs.setInt(constants.hideToolbar, values[2]);
            prefs.setInt(constants.autoPlayVideo, values[3]);
            prefs.setInt(constants.shopHiddenPhone, values[0]);
            prefs.setInt(constants.shopHiddenEmail, values[1]);
            prefs.setInt(constants.shopHideToolbar, values[2]);
            UtilUI.goBack(context, true);
          });
      } else if(state is DeleteAccountState) {
        UtilUI.logout(isRemove: true);
        UtilUI.goToPage(context, LoginPage(), null);
      }
    });
    super.initState();
    //_checkFinger();
    SharedPreferences.getInstance().then((prefs) {
      if(prefs.containsKey('hidden_phone')) values[0] = prefs.getInt('hidden_phone')??0;
      if(prefs.containsKey('hidden_email')) values[1] = prefs.getInt('hidden_email')??0;
      if(prefs.containsKey(constants.hideToolbar))
        values[2] = prefs.getInt(constants.hideToolbar)??0;
      if(prefs.containsKey(constants.autoPlayVideo))
        values[3] = prefs.getInt(constants.autoPlayVideo)??1;
      _onChangeValue(values[0], 0);
      _onChangeValue(values[1], 1);
      _onChangeValue(values[2], 2);
      _onChangeValue(values[3], 3);
    });
    bloc!.add(ShowDeleteEvent());
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Material(
        child: Scaffold(
            appBar: TaskBarWidget('lbl_setting',
                lblButton: languageKey.btnSave, onPressed: _save)
                .createUI(),
            body: Stack(children: [
              Container(
                  color: StyleCustom.backgroundColor,
                  child: ListView(children: [
                    _createItem(
                        'assets/images/ic_phone.png',
                        MultiLanguage.get('lbl_show_phone'),
                        0,
                        context,
                        _onChangeValue),
                    const DividerWidget(),
                    _createItem(
                        'assets/images/ic_email.png',
                        MultiLanguage.get('lbl_show_email'),
                        1,
                        context,
                        _onChangeValue),
                    const DividerWidget(),
                    _createItem(
                        '',
                        MultiLanguage.get('lbl_scroll_toolbar'),
                        2,
                        context,
                        _onChangeValue, icon: Icons.height, color: Colors.green),
                    const DividerWidget(),
                    _createItem(
                        '',
                        MultiLanguage.get('lbl_auto_play_video'),
                        3,
                        context,
                        _onChangeValue, icon: Icons.play_circle_fill, color: Colors.black),
                    const DividerWidget(),
                    /*BlocBuilder(bloc: bloc,
                        buildWhen: (oldFingerState, newFingerState) => newFingerState is ShowFingerSettingState,
                        builder: (context, fingerState) {
                          return fingerState is ShowFingerSettingState ?
                          Column(children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(30.sp, 10.sp, 10.sp, 10.sp),
                                child: Row(children: <Widget>[
                                  Icon(Icons.fingerprint, size: 60.sp, color: StyleCustom.primaryColor),
                                  SizedBox(width: 16.sp),
                                  Expanded(child: Text(MultiLanguage.get('lbl_setup_finger'),
                                      style: TextStyle(fontSize: 35.sp, color: StyleCustom.textColor1F))),
                                  BlocBuilder(bloc: bloc,
                                      buildWhen: (oldState, newState) => newState is HasSetupFingerSettingState,
                                      builder: (context, state) {
                                        bool value = false;
                                        if (state is HasSetupFingerSettingState) value = state.value;
                                        return Switch(value: value,
                                            onChanged: (newValue) => _setupFinger(newValue));
                                      })
                                ])),
                            const DividerWidget()
                          ]) : const SizedBox();
                        }),*/
                    ButtonImageCircleWidget(0,
                      _changePassword,
                      child: Container(
                          padding: EdgeInsets.fromLTRB(30.sp, 40.sp, 10.sp, 40.sp),
                          child: Row(children: <Widget>[
                           Icon(Icons.lock_outline_sharp, size: 60.sp, color: Colors.orange),
                            SizedBox(width: 18.sp),
                            Expanded(
                                child: Row(children: [
                                  Text('Đổi mật khẩu',
                                      style: TextStyle(
                                          fontSize: 48.sp, color: const Color(0xFF1F1F1F))),
                                ])),
                          ])),
                    ),
                    const DividerWidget(),
                    ButtonImageCircleWidget(0,
                      _deleteAccount,
                      child: Container(
                          padding: EdgeInsets.fromLTRB(30.sp, 40.sp, 10.sp, 40.sp),
                          child: Row(children: <Widget>[
                            Icon(Icons.person_add_disabled, size: 60.sp, color: const Color(0xFF6C00C0)),
                            SizedBox(width: 18.sp),
                            Expanded(
                                child: Row(children: [
                                  Text('Xóa tài khoản',
                                      style: TextStyle(
                                          fontSize: 48.sp, color: const Color(0xFF1F1F1F))),
                                ])),
                          ])),
                    )
                  ])),
              Loading(bloc)
            ])));
  }

  Widget _createItem(String assetPath, String text, int index,
          BuildContext context, Function onPressed, {icon, color}) =>
      Material(
          child: Container(
              padding: EdgeInsets.fromLTRB(30.sp, 10.sp, 10.sp, 10.sp),
              child: Row(children: <Widget>[
                icon == null ?
                Image.asset(assetPath, height: 60.sp, width: 60.sp)
                : Icon(icon, size: 60.sp, color: color),
                SizedBox(width: 16.sp),
                Expanded(
                    child: Row(children: [
                  Text(text,
                      style: TextStyle(
                          fontSize: 48.sp, color: const Color(0xFF1F1F1F))),
                ])),
                BlocBuilder(
                    bloc: bloc,
                    buildWhen: (state1, state2) =>
                        state2 is ChangeValueSettingState && state2.index == index,
                    builder: (context, state) => Switch(
                        value: values[index] == 1 ? true : false,
                        onChanged: (value) => onPressed(value ? 1 : 0, index)))
              ])));

  _onChangeValue(int value, int index) {
    values[index] = value;
    bloc!.add(ChangeValueSettingEvent(index));
    String content = '';
    switch (index){
      case 0:content = 'Show Phone number'; break;
      case 1:content = 'Show Email'; break;
      case 2:content = 'Enable toolbar scrolling'; break;
      case 3:content = 'Auto Open Video Content'; break;
    }
    trackActivities('setting', path: 'Setting screen -> Turn ${values[index]== 1 ? 'On' : 'OFF'} $content');
  }

  void _save() {
    bloc!.add(UpdateSettingEvent(values[0], values[1], values[2], values[3]));
    trackActivities('setting', path: 'Setting screen -> Save All Change Setting');
  }

  void _changePassword() {
    UtilUI.goToNextPage(context, ResetPasswordPage('',isChangeCurrent: true,));
  }

  void _checkFinger() async {
    final isAvailable = await LocalAuthApi.hasBiometrics();
    final biometrics = await LocalAuthApi.getBiometrics();
    final hasFingerprint = biometrics.contains(BiometricType.fingerprint) || biometrics.contains(BiometricType.strong);
    if (isAvailable && hasFingerprint) {
      bloc!.add(ShowFingerSettingEvent());
      SharedPreferences.getInstance().then((prefs) {
        if (prefs.containsKey(constants.loginKeyFinger) &&
            prefs.containsKey(constants.passwordFinger) &&
            (prefs.getString(constants.loginKeyFinger)??'').isNotEmpty &&
            (prefs.getString(constants.passwordFinger)??'').isNotEmpty)
          bloc!.add(HasSetupFingerSettingEvent(true));
      });
    }
  }

  void _setupFinger(bool check) async {
    if (check) {
      final value = await LocalAuthApi.authenticate();
      if (value) {
        SharedPreferences.getInstance().then((prefs) {
          final langKey = LanguageKey();
          prefs.setString(constants.loginKeyFinger,
              prefs.getString(constants.loginKey) ?? '');
          prefs.setString(constants.passwordFinger,
              prefs.getString(constants.password) ?? '');
          bloc!.add(HasSetupFingerSettingEvent(true));
          UtilUI.showCustomDialog(
              context, MultiLanguage.get('msg_auth_finger_success'),
              title: MultiLanguage.get(langKey.ttlAlert));
        });
      }
    } else { SharedPreferences.getInstance().then((prefs) {
      prefs.remove(constants.loginKeyFinger);
      prefs.remove(constants.passwordFinger);
      bloc!.add(HasSetupFingerSettingEvent(false));
    }); }
  }

  void _deleteAccount() {
    UtilUI.showCustomDialog(
        context, MultiLanguage.get('msg_delete_account'),
        isActionCancel: true, alignMessageText: TextAlign.left).then((value) {
      if (value != null && value){
        bloc!.add(DeleteAccountEvent());
      }
    });
  }
}
