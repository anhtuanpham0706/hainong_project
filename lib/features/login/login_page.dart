import 'package:hainong/common/database_helper.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/login_with_others.dart';
import 'package:hainong/features/signup/ui/import_lib_ui_signup.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hainong/common/local_auth_api.dart';
import 'package:hainong/features/signup/ui/signup_page.dart';
import 'package:zalo_flutter/zalo_flutter.dart';
import 'package:flutter/services.dart';
import '../reset_password_page.dart';
import 'bloc/login_bloc.dart';

class LoginPage extends BasePage {
  LoginPage({Key? key}):super(pageState: _LoginPageState(), key:key);
}

class _LoginPageState extends BasePageState {
  final TextEditingController _ctrLoginKey = TextEditingController(), _ctrPassword = TextEditingController();
  final FocusNode _focusLoginKey = FocusNode(), _focusPass = FocusNode();
  String _email = '', _imei = '';
  String? _finger, _passFinger;
  int _countDown = 45;

  @override
  void dispose() {
    _focusLoginKey.removeListener(_listenerText);
    _focusPass.removeListener(_listenerText);
    _ctrLoginKey.dispose();
    _ctrPassword.dispose();
    _focusLoginKey.dispose();
    _focusPass.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = LoginBloc();
    super.initState();
    _blocAddListener();
    SharedPreferences.getInstance().then((prefs) async {
      if (prefs.containsKey(constants.isRemember) && prefs.getBool(constants.isRemember)!) {
        if (prefs.containsKey(constants.loginKey))
          _ctrLoginKey.text = prefs.getString(constants.loginKey)??'';
        if (prefs.containsKey(constants.password))
          _ctrPassword.text = prefs.getString(constants.password)??'';
        _checkedRememberPassword(true);
      }
      if (prefs.containsKey(constants.loginKeyFinger)) {
        String temp = prefs.getString(constants.loginKeyFinger) ?? '';
        if (temp.isNotEmpty) _ctrLoginKey.text = temp;
      }
    });
    _checkFinger();
    _focusLoginKey.addListener(_listenerText);
    _focusPass.addListener(_listenerText);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => GestureDetector(child: Scaffold(
    body: Stack(alignment: Alignment.bottomRight, children: [
      Column(children: [
        Expanded(flex: 3, child: Image.asset('assets/images/ic_line_header.png', fit: BoxFit.fill, width: 1.sw)),
        Expanded(flex: 7, child: Container(color: StyleCustom.backgroundColor))
      ]),
      createUI(),
      /*BlocBuilder(builder: (context, state) {
        bool focus = false;
        if (state is FocusTextLoginState) focus = state.value;
        if (!focus) return const SizedBox();
        return IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.green, size: 86.sp));
      }, bloc: bloc, buildWhen: (oldS, newS) => newS is FocusTextLoginState),*/
      Loading(bloc)
    ]), resizeToAvoidBottomInset: false), onTap: clearFocus);

  @override
  Widget createUI() => Column(children: [
    subBodyHeaderUI(),
    createBodyUI(),
    ignoreUI(),
    const Divider(height: 1, color: Color(0xFFEAEAEA)),
    createFooterUI()
  ]);

  int? _count;
  @override
  Widget subBodyHeaderUI() => Padding(padding: EdgeInsets.only(top: WidgetsBinding.instance.window.padding.top.sp),
      child: InkWell(onTap: () async {
        _count ??= 0;
        _count = _count! + 1;
        if (_count != null && _count! > 19) {
          _count = null;
          final List<ItemModel> list = [
            ItemModel(id: 'dev', name: 'Develop'),
            ItemModel(id: 'staging', name: 'Staging'),
            ItemModel(id: 'uat', name: 'UAT'),
            ItemModel(name: 'Live')
          ];
          UtilUI.showOptionDialog(context, 'Chọn môi trường', list, (await SharedPreferences.getInstance()).getString('env')??'', allowOff: false).then((value) async {
            if (value != null) {
              final prefs = await SharedPreferences.getInstance();
              final env = prefs.getString('env')??'';
              if (env != value.id) {
                Util.chooseEnv(value.id);
                prefs.setString('env', value.id);
                DBHelperUtil().clearAdsModule();
              }
            }
          });
        }
      }, child: Image.asset('assets/images/ic_logo_login.png', height: 120.sp, width: 260.sp)));

  @override
  Widget createBodyUI() => Expanded(child: ListView(children: [
    Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.sp), color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))
        ]),
        padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 80.sp), margin: EdgeInsets.symmetric(horizontal: 40.sp),
        child: Column(children: [
          LabelCustom('ĐĂNG NHẬP', size: 55.sp, color: const Color(0xFF363636), align: TextAlign.center),
          Padding(padding: EdgeInsets.only(top: 40.sp, bottom: 40.sp),
              child: TextFieldCustom(_ctrLoginKey, _focusLoginKey, _focusPass, MultiLanguage.get('lbl_username'))),
          BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is ShowPasswordLoginState,
              builder: (context, state) => TextFieldCustom(_ctrPassword, _focusPass, null, MultiLanguage.get(languageKey.lblPassword),
                  isPassword: !(state as LoginState).isShowPassword, inputAction: TextInputAction.done,
                  suffix: ButtonImageWidget(10, () => bloc!.add(ShowPasswordLoginEvent(!state.isShowPassword)),
                      Padding(padding: EdgeInsets.all(20.sp), child: Image.asset(state.isShowPassword ?
                      constants.assetsEyeOpen : constants.assetsEyeClose, width: 60.sp, height: 60.sp))),
                  constraint: BoxConstraints(maxWidth: 100.sp, maxHeight: 100.sp), onSubmit: _onClickLogin)),
          Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: Row(children: [
            BlocBuilder(
                bloc: bloc,
                buildWhen: (oldState, newState) => newState is RememberPasswordLoginState,
                builder: (context, state) => Checkbox(
                  value: (state as LoginState).isRememberPassword,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: StyleCustom.primaryColor,
                  onChanged: (value) => _checkedRememberPassword(value!),
                )),
            Expanded(child: LabelCustom(
                MultiLanguage.get('lbl_remember'),
                color: StyleCustom.textColor19,
                weight: FontWeight.normal)),
            TextButton(onPressed: _showDialogForgetPassword,
                child: LabelCustom(
                    MultiLanguage.get('lbl_forget_pass'),
                    color: StyleCustom.primaryColor,
                    weight: FontWeight.w500))
          ])),
          ButtonImageWidget(15.sp, onPressBodyFooter, Container(width: 1.sw, padding: EdgeInsets.all(32.sp),
              child: LabelCustom('Đăng Nhập', size: 51.sp, color: const Color(0xFF363636), align: TextAlign.center,
                  weight: FontWeight.w500)), color: const Color(0xFFFFCF55)),
        ])),
    LoginWithOthers(_signInWithFaceBook, _signInWithGoogle, _signInWithApple, _signInWithZalo),
    /*BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowFingerLoginState,
      builder: (context, state) => (state is ShowFingerLoginState) ?
         ButtonImageWidget(5, _loginFingerprint, Row(children: [
           const Icon(Icons.fingerprint, color: Colors.green),
           LabelCustom('Đăng nhập bằng vâng tay', size: 42.sp, color: Colors.black54, weight: FontWeight.normal)
         ], mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min)) : const SizedBox())*/
  ], padding: EdgeInsets.zero));

  @override
  Widget ignoreUI() => ButtonImageWidget(10.sp, () => UtilUI.goToPage(context, Main2Page(), null), Padding(
      padding: EdgeInsets.all(48.sp),
      child: Text('Tiếp tục với tư cách của khách', style: TextStyle(
          fontWeight: FontWeight.w500, color: const Color(0xFF363636),
          decoration: TextDecoration.underline, fontSize: 45.sp))));

  @override
  String getButtonNameBodyFooter() => languageKey.btnLogin;

  @override
  void onPressBodyFooter() => _onClickLogin();

  @override
  String getMessageFooter() => 'msg_do_not_account';

  @override
  String getButtonNameFooter() => languageKey.btnSignUp;

  @override
  void onPressFooter() {
    clearFocus();
    UtilUI.goToNextPage(context, SignUpPage());
  }

  void _blocAddListener() {
    bloc!.stream.listen((state) {
      if (state is ForgetPasswordLoginState) _handleForgetPasswordResponse(state);
      else if (state is VerifyCodeLoginState) _handleVerifyCodeResponse(state);
      else if (state is SaveDeviceLoginState && isResponseNotError(state.response!)) {
        SharedPreferences.getInstance().then((prefs) {
          if (state.isFinger!) {
            _finger = prefs.getString(constants.loginKeyFinger);
            _passFinger = prefs.getString(constants.passwordFinger);
            bloc!.add(OnClickLoginEvent(_finger!, _passFinger!, _imei));
          } else bloc!.add(OnClickLoginEvent(_ctrLoginKey.text, _ctrPassword.text, _imei));
        });
      } else if (state is ResponseLoginState) _handleLoginResponse(state);
      else if (state is FingerprintLoginState) {
        state.result.isNotEmpty ? UtilUI.showCustomDialog(context, MultiLanguage.get(state.result)) : _login(true);
      }
    });
  }

  void _listenerText() => bloc!.add(FocusTextLoginEvent(_focusLoginKey.hasFocus || _focusPass.hasFocus));

  void _checkedRememberPassword(bool value) => bloc!.add(RememberPasswordLoginEvent(value));

  void _showDialogForgetPassword() {
    clearFocus();
    UtilUI.showConfirmDialog(
            context,
            MultiLanguage.get('msg_input_registered_phone'),
            MultiLanguage.get(languageKey.lblPhoneNumber), MultiLanguage.get(languageKey.msgInputPhoneNumber),
            title: MultiLanguage.get('lbl_forget_pass'),
            inputType: TextInputType.phone)
        .then((value) {
      if (value is String) {
        _email = value;
        bloc!.add(ForgetPasswordLoginEvent(_email));
      }
    });
  }

  void _showDialogVerifyCode() =>
    UtilUI.showConfirmDialog(context, MultiLanguage.get(languageKey.msgCallOtp),
            MultiLanguage.get(languageKey.lblOtpCode), MultiLanguage.get(languageKey.ttlOtp),
            title: MultiLanguage.get(languageKey.ttlOtp),
            alignMessage: Alignment.center, alignMessageText: TextAlign.center,
            colorMessage: StyleCustom.primaryColor, hasSubOK: true, autoClose: false,
            inputType: TextInputType.number, countDown: _countDown,
            funSetCountDown: _setCountDown, maxLength: constants.otpMaxLength)
        .then((value) {
      if (value is String) {
        bloc!.add(VerifyCodeLoginEvent(value));
      } else if (value is bool && value) bloc!.add(ForgetPasswordLoginEvent(_email));
    });

  void _setCountDown(int value) => _countDown = value;

  void _handleForgetPasswordResponse(ForgetPasswordLoginState state) {
    _countDown = 45;
    if (isResponseNotError(state.response!, showError: false)) _showDialogVerifyCode();
    else UtilUI.showCustomDialog(context, state.response!.data).then((value) => _showDialogForgetPassword());
  }

  void _handleVerifyCodeResponse(VerifyCodeLoginState state) {
    if (isResponseNotError(state.response!, showError: false)) {
      _countDown = 45;
      UtilUI.saveInfo(context, state.response!.data, _email, null);
      UtilUI.goToNextPage(context, ResetPasswordPage(state.otp));
    } else UtilUI.showCustomDialog(context, state.response!.data).then((value) => _showDialogVerifyCode());
  }

  void _handleLoginResponse(ResponseLoginState state) {
    if (isResponseNotError(state.response!)) {
      UtilUI.saveInfo(context, state.response!.data, _finger ?? _ctrLoginKey.text, _passFinger ?? _ctrPassword.text, page: Main2Page());
    }
  }

  void _onClickLogin() {
    clearFocus();

    if (_ctrLoginKey.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_username'))
          .then((value) => _focusLoginKey.requestFocus());
      return;
    }

    if (_ctrPassword.text.isEmpty) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInputPassword))
          .then((value) => _focusPass.requestFocus());
      return;
    }

    _login(false);
  }

  void _login(bool isFinger) async {
    bloc!.add(ShowLoadingLoginEvent());
    var info = await UtilUI.getDeviceInfo();
    _imei = info['imei']??'';
    final token = info['token']??'';
    if (_imei.isEmpty || token.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgErrorGetDeviceId));
      bloc!.add(ShowLoadingLoginEvent(value: false));
      return;
    } else {
      bloc!.add(SaveDeviceLoginEvent(
          _imei,
          info['name']??'',
          info['type']??'',
          info['os']??'',
          info['version']??'',
          token, isFinger, 
          info['apns_topic']??'',
          info['apple_notice_token']??''
      ));
    }
  }

  void _checkFinger() async {
    final isAvailable = await LocalAuthApi.hasBiometrics();
    final biometrics = await LocalAuthApi.getBiometrics();
    final hasFingerprint = biometrics.contains(BiometricType.fingerprint) || biometrics.contains(BiometricType.strong);
    if (isAvailable && hasFingerprint) bloc!.add(ShowFingerLoginEvent());
  }

  void _loginFingerprint() => bloc!.add(FingerprintLoginEvent());
  void _signInWithGoogle() => bloc!.add(SignInOthersEvent('google'));
  void _signInWithFaceBook() => bloc!.add(SignInOthersEvent('facebook'));
  void _signInWithApple() => bloc!.add(SignInOthersEvent('apple'));
  //void _signInWithZalo() => bloc!.add(SignInOthersEvent('zalo'));
  void _signInWithZalo() async {
    final env = (await SharedPreferences.getInstance()).getString('env')??'';
    if (env != 'dev' || Platform.isIOS) bloc!.add(SignInOthersEvent('zalo'));
    else {
      final hashKey = await ZaloFlutter.getHashKeyAndroid();
      UtilUI.showCustomDialog(context, hashKey).whenComplete(() {
        Clipboard.setData(ClipboardData(text: hashKey));
        bloc!.add(SignInOthersEvent('zalo'));
      });
    }
  }
  //staging         : iSFzYzZxpD/j8bXQ6toQPPUH74Q=
  //release         : B55lsnH5mQRj6CgQRztMPWrB8YE=
  //debug at office : dIiQJerfzsW/I317WoeN5Xvz3vw=
  //debug at office : 3518CUlXsp2G7D0wOQAr3WLphDE=
  //debug at home   : jQkhhg1fNOx77DwWTzoyOvEXEeM=
}
