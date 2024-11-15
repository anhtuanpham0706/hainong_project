import 'package:clock/clock.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/ui/button_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/features/login/login_page.dart';
import 'import_lib_ui_signup.dart';

class SignUpPage extends BasePage {
  SignUpPage({this.referralCode, this.referralType, Key? key}) : super(key: key, pageState: _SignUpPageState());

  final String? referralCode;
  final String? referralType;
}

class _SignUpPageState extends PermissionImagePageState {
  final SignUpVariant _variant = SignUpVariant();
  bool _isLock = false;
  int _term = 1;
  String? _compare;

  @override
  void loadFiles(List<File> files) {
    if (files.isEmpty) return;
    _variant.image = files.first.path;
    bloc!.add(LoadImageSignUpEvent());
  }

  @override
  void dispose() {
    //clearFocus();
    _variant.dispose();
    _variant.focusFullName.removeListener(_listenerText);
    _variant.focusReferrarCode.removeListener(_listenerText);
    _variant.focusPhoneNumber.removeListener(_listenerText);
    _variant.focusPassword.removeListener(_listenerText);
    _variant.focusRepeatPassword.removeListener(_listenerText);
    _variant.focusEmail.removeListener(_listenerText);
    super.dispose();
  }

  @override
  void initState() {
    bloc = SignUpBloc();
    bloc!.stream.listen((state) {
      if (state is SaveDeviceSignUpState) {
        if (isResponseNotError(state.response!)) {
          bloc!.add(OnClickSignUpEvent(
              _variant.ctrFullName.text,
              _variant.values[languageKey.lblBirthday] ?? '',
              _variant.ctrEmail.text,
              (widget as SignUpPage).referralType ?? "code",
              _variant.ctrReferrarCode.text,
              _variant.values[languageKey.lblGender] ?? 'male',
              _variant.ctrPhoneNumber.text,
              _variant.ctrPassword.text,
              _variant.ctrRepeatPassword.text,
              _variant.image,
              state.response!.data.device_id, _term.toString()));
        } else _isLock = false;
      } else if (state is ResponseSignUpState) _handleSignUpResponse(state);
      else if (state is RequireOTPSignUpState) _handleRequireOTPResponse(state);
      else if (state is VerifyCodeSignUpState) _handleVerifyCodeResponse(state);
    });
    setOnlyImage();
    super.initState();
    _variant.locale = constants.localeVILang;
    _setReferralCode();
    _setBirthday(const Clock().yearsAgo(20), setDisplay: false);
    _setBirthday(null, setDisplay: false);
    _setGenderUserType(_variant.ctrGender, languageKey.lblGender, 'male');
    _variant.focusFullName.addListener(_listenerText);
    _variant.ctrReferrarCode.addListener(_listenerText);
    _variant.focusPhoneNumber.addListener(_listenerText);
    _variant.focusPassword.addListener(_listenerText);
    _variant.focusRepeatPassword.addListener(_listenerText);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) =>
    GestureDetector(child: WillPopScope(onWillPop: () {
        onPressFooter();
        return Future(() => false);
    }, child: Scaffold(body: Stack(alignment: Alignment.bottomRight, children: [
       Column(children: [
            Expanded(flex: 3, child: Image.asset('assets/images/ic_line_header.png', fit: BoxFit.fill, width: 1.sw)),
            Expanded(flex: 7, child: Container(color: StyleCustom.backgroundColor))
       ]),
       createUI(),
       /*BlocBuilder(builder: (context, state) {
            bool focus = false;
            if (state is FocusTextState) focus = state.value;
            if (!focus) return const SizedBox();
            return IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.green, size: 86.sp));
       }, bloc: bloc, buildWhen: (oldS, newS) => newS is FocusTextState),*/
       Loading(bloc)
    ]), resizeToAvoidBottomInset: false)), onTap: clearFocus);

  @override
  Widget ignoreUI() => Row(children: [
        Transform.scale(
            scale: 1.2,
            child: BlocBuilder(
                bloc: bloc,
                buildWhen: (oldState, newState) => newState is ChangeTermState,
                builder: (context, state) => Checkbox(
                      value: _term == 1,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: StyleCustom.primaryColor,
                      onChanged: (value) => _changeTerm(value ?? false),
                    ))),
        Expanded(
            child: LabelCustom('Tôi xác nhận đã đồng ý các điều khoản sử dụng',
                color: Colors.blue, weight: FontWeight.normal, size: 38.sp))
        //]), padding: EdgeInsets.only(left: 20.sp, right: 40.sp));
      ]);

  @override
  Widget createHeaderUI() => subHeaderUI(languageKey.btnSignUp);

  @override
  String getButtonNameBodyFooter() => languageKey.btnSignUp;

  @override
  void onPressBodyFooter() => _onClickSignUp();

  @override
  String getMessageFooter() => 'msg_already_have_account';

  @override
  String getButtonNameFooter() => languageKey.btnLogin;

  @override
  void onPressFooter() => UtilUI.showCustomDialog(context, 'Tiếp tục đăng ký tài khoản 2 Nông', isActionCancel: true).then((value) {
    if (value == null || !value) {
      Navigator.of(context).canPop() ? UtilUI.goBack(context, false) : UtilUI.goToPage(context, LoginPage(), null);
    }
  });

  @override
  Widget subBodyFooterUI() => Container(width: 1.sw, padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
      child: ButtonCustom(onPressBodyFooter, MultiLanguage.get(getButtonNameBodyFooter()), size: 52.sp));

  @override
  Widget subBodyUI() => Column(children: [
    subBodyHeaderUI(),
    Align(alignment: Alignment.center, child: Container(margin: EdgeInsets.only(top: 40.sp),
        decoration: ShadowDecoration(size: 200.sp, bgColor: Colors.black26),
        child: BlocBuilder( bloc: bloc, buildWhen: (oldState, newState) => newState is LoadImageSignUpState,
            builder: (context, state) => ButtonImageCircleWidget(200.sp, () => selectImage(_variant.imageTypes),
                imageFile: _variant.image.isNotEmpty ? File(_variant.image) : null,
                assetsImageReplace: 'assets/images/v2/ic_avatar_drawer_v2.png')))),
    subBodyBodyUI(),
    //ignoreUI(),
    subBodyFooterUI()
  ]);

  @override
  Widget createFieldsSubBody() {
    final padding = SizedBox(height: 40.sp);
    return ListView(padding: EdgeInsets.zero, children: [
      TextFieldCustom(_variant.ctrFullName, _variant.focusFullName, _variant.focusPhoneNumber,
          MultiLanguage.get(languageKey.lblFullName) + '*'),
      padding,
      TextFieldCustom(_variant.ctrPhoneNumber, _variant.focusPhoneNumber, _variant.focusPassword,
          MultiLanguage.get(languageKey.lblPhoneNumber) + '*',
          type: TextInputType.number),
      padding,
      BlocBuilder(
          bloc: bloc,
          buildWhen: (oldState, newState) =>
              newState is ShowPasswordSignUpState,
          builder: (context, state) => TextFieldCustom(
              _variant.ctrPassword,
              _variant.focusPassword,
              _variant.focusRepeatPassword,
              MultiLanguage.get(languageKey.lblPassword) + '*',
              isPassword: !(state as SignUpState).isShowPassword,
              suffix: ButtonImageWidget(10, () => bloc!.add(ShowPasswordSignUpEvent(!state.isShowPassword)),
                Padding(padding: EdgeInsets.all(20.sp), child: Image.asset(state.isShowPassword ?
                constants.assetsEyeOpen : constants.assetsEyeClose, width: 60.sp, height: 60.sp))),
                constraint: BoxConstraints(maxWidth: 100.sp, maxHeight: 100.sp),
                //onPressIcon: () => bloc!.add(ShowPasswordSignUpEvent(!state.isShowPassword))
          )),
      padding,
      BlocBuilder(
          bloc: bloc,
          buildWhen: (oldState, newState) =>
              newState is ShowRepeatPasswordSignUpState,
          builder: (context, state) => TextFieldCustom(
              _variant.ctrRepeatPassword,
              _variant.focusRepeatPassword,
              _variant.focusReferrarCode,
              MultiLanguage.get(languageKey.lblRepeatPassword) + '*',
              isPassword: !(state as SignUpState).isShowRepeatPassword,
              suffix: ButtonImageWidget(10, () => bloc!.add(ShowRepeatPasswordSignUpEvent(!state.isShowRepeatPassword)),
                  Padding(padding: EdgeInsets.all(20.sp), child: Image.asset(state.isShowRepeatPassword ?
                  constants.assetsEyeOpen : constants.assetsEyeClose, width: 60.sp, height: 60.sp))),
              constraint: BoxConstraints(maxWidth: 100.sp, maxHeight: 100.sp)
              //onPressIcon: () => bloc!.add(ShowRepeatPasswordSignUpEvent(!state.isShowRepeatPassword))
          )),
      // padding,
      //  TextFieldCustom(
      //     _variant.ctrEmail,
      //     _variant.focusEmail,
      //     _variant.focusReferrerCode,
      //     'Email',
      //     type: TextInputType.emailAddress),
      padding,
      TextFieldCustom(_variant.ctrReferrarCode, _variant.focusReferrarCode, null, 'Mã giới thiệu',
          isEnable: (widget as SignUpPage).referralType != "link",
          type: TextInputType.text,
          inputAction: TextInputAction.done,
          onSubmit: () => _onClickSignUp()),
      padding,
      ignoreUI()
    ]);
  }

  void _listenerText() => bloc!.add(FocusTextEvent(_variant.focusFullName.hasFocus ||
      _variant.focusReferrarCode.hasFocus ||
      _variant.focusPhoneNumber.hasFocus ||
      _variant.focusPassword.hasFocus ||
      _variant.focusRepeatPassword.hasFocus ||
      _variant.focusEmail.hasFocus));

  void _setBirthday(DateTime? date, {bool setDisplay = true}) {
    if (setDisplay && date != null) {
      _variant.ctrBirthday.text = _variant.locale == constants.localeVILang ?
            Util.dateToString(date, pattern: constants.datePatternVI) : Util.dateToString(date);
    }

    String temp = '';
    if (date != null) temp = Util.dateToString(date, pattern: constants.datePattern);

    _variant.values.update(languageKey.lblBirthday, (value) => temp, ifAbsent: () => temp);
  }

  void _setReferralCode() {
    if ((widget as SignUpPage).referralCode?.isNotEmpty == true) {
      _variant.ctrReferrarCode.text = (widget as SignUpPage).referralCode ?? "";
    }
  }

  void _selectCalendar() {
    try {
      String temp = _variant.values[languageKey.lblBirthday]!;
      if (temp.isEmpty) temp = Util.dateToString(const Clock().yearsAgo(20), pattern: constants.datePattern);

      DatePicker.showDatePicker(context,
          minTime: Util.stringToDateTime(constants.dateMinDefault,
              pattern: constants.datePattern),
          maxTime: DateTime.now(),
          showTitleActions: true,
          onConfirm: (DateTime date) => _setBirthday(date),
          currentTime: Util.stringToDateTime(temp,
              pattern: constants.datePattern),
          locale: LocaleType.vi);
    } catch (_) {}
  }

  void _setGenderUserType(TextEditingController ctr, String key, String value) {
    ctr.text = MultiLanguage.get(value);
    _variant.values.update(key, (oldValue) => value, ifAbsent: () => value);
  }

  void _onClickSignUp() async {
    clearFocus();

    if (_variant.ctrFullName.text.isEmpty) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInputFullName))
          .then((value) => _variant.focusFullName.requestFocus());
      return;
    }
    if (_variant.ctrPhoneNumber.text.isEmpty) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInputPhoneNumber))
          .then((value) => _variant.focusPhoneNumber.requestFocus());
      return;
    }
    String phone = _variant.ctrPhoneNumber.text.replaceAll('+', '');
    if (phone.length < 10 || phone.contains(' ') || Util.stringToDouble(phone) <= 0) {
      UtilUI.showCustomDialog(
          context, MultiLanguage.get('msg_invalid_phone'))
          .then((value) => _variant.focusPhoneNumber.requestFocus());
      return;
    }
    if (_variant.ctrPassword.text.isEmpty) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInputPassword))
          .then((value) => _variant.focusPassword.requestFocus());
      return;
    }
    if (_variant.ctrPassword.text.length < constants.passwordMaxLength) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInvalidPassword))
          .then((value) => _variant.focusPassword.requestFocus());
      return;
    }
    if (_variant.ctrRepeatPassword.text.isEmpty) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInputRepeatPassword))
          .then((value) => _variant.focusRepeatPassword.requestFocus());
      return;
    }
    if (_variant.ctrRepeatPassword.text != _variant.ctrPassword.text) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgRepeatPasswordNotMatch))
          .then((value) => _variant.focusRepeatPassword.requestFocus());
      return;
    }
    if (_term == 0) {
      UtilUI.showCustomDialog(context, 'Bạn phải chọn "Tôi xác nhận đã đồng ý các điều khoản sử dụng" mới có thể tiếp tục được');
      return;
    }

    var info = await UtilUI.getDeviceInfo();
    final String _imei = info['imei']??'';
    if (_imei.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgErrorGetDeviceId));
      return;
    }

    SharedPreferences.getInstance().then((prefs) {
        prefs.setString('device_id', _imei);
        String token = prefs.getString('fb_token')??'';
        if (token.isEmpty) {
          UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgErrorGetDeviceId));
          return;
        }
        if (_isLock) return;
        _isLock = true;
        bloc!.add(SaveDeviceSignUpEvent(
            _imei,
            info['name']!,
            info['type']!,
            info['os']!,
            info['version']!,
            token,
            info['apns_topic']!,
            info['apple_notice_token']!));
      });
  }

  void _handleSignUpResponse(ResponseSignUpState state) {
    _isLock = false;
    if (isResponseNotError(state.response!)) {
      _compare = null;
      bloc!.add(RequireOTPSignUpEvent(_variant.ctrPhoneNumber.text));
    }
  }

  void _handleRequireOTPResponse(RequireOTPSignUpState state) {
    if (isResponseNotError(state.response, passString: true, showError: false)) {
      _compare = state.response.data;
      _showDialogVerifyCode();
    } else {
      UtilUI.showCustomDialog(context, state.response.data, isActionCancel: true)
          .then((value) {
        if (value != null && value) {
          _compare = null;
          bloc!.add(RequireOTPSignUpEvent(_variant.ctrPhoneNumber.text));
        }
      }); }
  }

  void _showDialogVerifyCode() => UtilUI.showConfirmDialog(
        context,
        MultiLanguage.get(languageKey.msgCallOtp),
        MultiLanguage.get(languageKey.lblOtpCode), MultiLanguage.get(languageKey.ttlOtp),
        title: MultiLanguage.get(languageKey.ttlOtp),
        alignMessage: Alignment.center,
        alignMessageText: TextAlign.center,
        colorMessage: StyleCustom.primaryColor,
        hasSubOK: true,
        autoClose: false,
        inputType: TextInputType.number,
        maxLength: constants.otpMaxLength, compareValue: _compare)
    .then((value) {
      if (value is String) {
        bloc!.add(VerifyCodeSignUpEvent(value, _variant.ctrPhoneNumber.text));
      } else if (value is bool && value) {
        bloc!.add(RequireOTPSignUpEvent(_variant.ctrPhoneNumber.text)); }
    });

  void _handleVerifyCodeResponse(VerifyCodeSignUpState state) {
    if (isResponseNotError(state.response, showError: false)) {
      UtilUI.clearAllPages(context);
      UtilUI.saveInfo(context, state.response.data, _variant.ctrPhoneNumber.text,
          _variant.ctrPassword.text, page: Main2Page());
    } else { UtilUI.showCustomDialog(context, state.response.data).then((value) =>
        _showDialogVerifyCode()); }
  }

  void _changeTerm(bool value) {
    _term = value ? 1 : 0;
    bloc!.add(ChangeTermEvent(_term));
  }
}
