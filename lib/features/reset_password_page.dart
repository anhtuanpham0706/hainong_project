import 'package:hainong/common/ui/button_custom.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import '../common/ui/button_image_widget.dart';
import 'signup/bloc/sign_up_bloc.dart';

class ResetPasswordPage extends BasePage {
  final String otp;
  final bool isChangeCurrent;
  ResetPasswordPage(this.otp, {this.isChangeCurrent = false,Key? key}) : super(key: key, pageState: _ResetPasswordPageState());
}

class _ResetPasswordPageState extends BasePageState {
  final TextEditingController _ctrPassword = TextEditingController();
  final TextEditingController _ctrRepeatPassword = TextEditingController();
  final TextEditingController _ctrCurrentPassword = TextEditingController();
  final FocusNode _focusPassword = FocusNode();
  final FocusNode _focusRepeatPassword = FocusNode();
  final FocusNode _focusCurrentPassword = FocusNode();
  bool _isPartNerLogin = false;
  String _current = '';

  @override
  void dispose() {
    _ctrPassword.dispose();
    _ctrRepeatPassword.dispose();
    _ctrCurrentPassword.dispose();
    _focusPassword.dispose();
    _focusRepeatPassword.dispose();
    _focusCurrentPassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = SignUpBloc();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is ResponseSignUpState) {
        _handleChangedPasswordResponse(state);
      } else if(state is ChangeCurrentPasswordState){
        _handleChangedCurrentPassword(state);
      }
    });
    _checkTypeLogin();
  }

  void _checkTypeLogin() {
    SharedPreferences.getInstance().then((pref) {
      _isPartNerLogin = pref.getString('partner_type') == '' ? false : true;
      _current = pref.getString('current_password')??'';
      _isPartNerLogin ? _isPartNerLogin = _current.isEmpty : (_current = pref.getString('password')??'');
      setState(() {});
    });
  }

  @override
  Widget createUI() => Scaffold(backgroundColor: StyleCustom.backgroundColor,
      appBar: AppBar(title: LabelCustom(MultiLanguage.get('ttl_reset_password'), size: 50.sp), centerTitle: true),
      body: ListView(padding: EdgeInsets.fromLTRB(50.sp, 150.sp, 50.sp, 50.sp),
          children: [
            (widget as ResetPasswordPage).isChangeCurrent && !_isPartNerLogin ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 30.sp),
                    child: LabelCustom(
                        MultiLanguage.get('lbl_current_password'),
                        color: StyleCustom.textColor19,
                        weight: FontWeight.normal)),
                BlocBuilder(
                    bloc: bloc,
                    builder: (context, state) => TextFieldCustom(
                      _ctrCurrentPassword,
                      _focusCurrentPassword,
                      _focusPassword,
                      '', maxLength: 20,
                      isPassword: !(state as SignUpState).isShowCurrentPassword,
                      suffix: ButtonImageWidget(10, () => bloc!.add(ShowCurrentPasswordEvent(!state.isShowCurrentPassword)),
                          Padding(padding: EdgeInsets.all(20.sp), child: Image.asset(state.isShowCurrentPassword ?
                          constants.assetsEyeOpen : constants.assetsEyeClose, width: 60.sp, height: 60.sp))),
                      constraint: BoxConstraints(maxWidth: 100.sp, maxHeight: 100.sp),
                      //onPressIcon: () => bloc!.add(ShowCurrentPasswordEvent(!state.isShowCurrentPassword))
                    )),
              ]
            ) : const SizedBox(),
            Padding(
                padding: EdgeInsets.only(bottom: 30.sp,top: 60.sp),
                child: LabelCustom(
                    MultiLanguage.get('lbl_new_password'),
                    color: StyleCustom.textColor19,
                    weight: FontWeight.normal)),
            BlocBuilder(
                bloc: bloc,
                builder: (context, state) => TextFieldCustom(
                  _ctrPassword,
                  _focusPassword,
                  _focusRepeatPassword,
                  '', maxLength: 20,
                  isPassword: !(state as SignUpState).isShowPassword,
                  suffix: ButtonImageWidget(10, () => bloc!.add(ShowPasswordSignUpEvent(!state.isShowPassword)),
                      Padding(padding: EdgeInsets.all(20.sp), child: Image.asset(state.isShowPassword ?
                      constants.assetsEyeOpen : constants.assetsEyeClose, width: 60.sp, height: 60.sp))),
                  constraint: BoxConstraints(maxWidth: 100.sp, maxHeight: 100.sp),
                  //onPressIcon: () => bloc!.add(ShowPasswordSignUpEvent(!state.isShowPassword))
                )),
            Padding(
                padding: EdgeInsets.only(top: 60.sp, bottom: 30.sp),
                child: LabelCustom(
                    MultiLanguage.get(languageKey.lblRepeatPassword),
                    color: StyleCustom.textColor19,
                    weight: FontWeight.normal)),
            BlocBuilder(
                bloc: bloc,
                builder: (context, state) => TextFieldCustom(
                  _ctrRepeatPassword,
                  _focusRepeatPassword,
                  null,
                  '', maxLength: 20,
                  isPassword: !(state as SignUpState).isShowRepeatPassword,
                  suffix: ButtonImageWidget(10, () => bloc!.add(ShowRepeatPasswordSignUpEvent(!state.isShowRepeatPassword)),
                      Padding(padding: EdgeInsets.all(20.sp), child: Image.asset(state.isShowRepeatPassword ?
                      constants.assetsEyeOpen : constants.assetsEyeClose, width: 60.sp, height: 60.sp))),
                  constraint: BoxConstraints(maxWidth: 100.sp, maxHeight: 100.sp),
                  inputAction: TextInputAction.done,
                  onSubmit: _onClickChangedPassword,
                  //onPressIcon: () => bloc!.add(ShowRepeatPasswordSignUpEvent(!state.isShowRepeatPassword))
                )),
            Container(width: 1.sw,
                padding: EdgeInsets.only(top: 60.sp),
                child: ButtonCustom(
                        () => _onClickChangedPassword(),
                    MultiLanguage.get(languageKey.btnOK)))
          ]
      )
  );

  void _onClickChangedPassword() {
    final page = widget as ResetPasswordPage;
    if(!_isPartNerLogin) {
      if (_ctrCurrentPassword.text.isEmpty && page.isChangeCurrent) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_current_password'))
            .then((value) => _focusCurrentPassword.requestFocus());
        return;
      }
      if (_ctrCurrentPassword.text.length < constants.passwordMaxLength && page.isChangeCurrent) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_invalid_current_password'))
            .then((value) => _focusCurrentPassword.requestFocus());
        return;
      }
      if (_ctrCurrentPassword.text == _ctrPassword.text && page.isChangeCurrent) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_current_password_cannot_password'))
            .then((value) => _focusCurrentPassword.requestFocus());
        return;
      }
      if (_ctrCurrentPassword.text != _current && page.isChangeCurrent) {
        UtilUI.showCustomDialog(context, 'Mật khẩu không đúng').then((value) => _focusCurrentPassword.requestFocus());
        return;
      }
    }

    if (_ctrPassword.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgInputPassword))
          .then((value) => _focusPassword.requestFocus());
      return;
    }
    if (_ctrPassword.text.length < constants.passwordMaxLength) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgInvalidPassword))
          .then((value) => _focusPassword.requestFocus());
      return;
    }
    if (_ctrRepeatPassword.text.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgInputRepeatPassword))
          .then((value) => _focusRepeatPassword.requestFocus());
      return;
    }
    if (_ctrRepeatPassword.text != _ctrPassword.text) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(languageKey.msgRepeatPasswordNotMatch))
          .then((value) => _focusRepeatPassword.requestFocus());
      return;
    }

    if(page.isChangeCurrent) {
      bloc!.add(ChangeCurrentPasswordEvent(_isPartNerLogin ? _current : _ctrCurrentPassword.text, _ctrPassword.text, _ctrRepeatPassword.text));
    } else {
      SharedPreferences.getInstance().then((prefs) {
        bloc!.add(OnClickChangePasswordSignUpEvent(prefs.getString(constants.loginKey)??'', _ctrPassword.text, page.otp));
      });
    }
  }

  void _handleChangedPasswordResponse(ResponseSignUpState state) {
    if (isResponseNotError(state.response!)) {
      UtilUI.saveInfo(context, state.response!.data, null, _isPartNerLogin ? null : _ctrPassword.text, currentPas: _isPartNerLogin ? _ctrPassword.text : null);
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_updating_password_ok'),
              title: MultiLanguage.get(languageKey.ttlAlert)).then((value) => Navigator.of(context).pop());
    }
  }
  void _handleChangedCurrentPassword(ChangeCurrentPasswordState state) {
    if (isResponseNotError(state.response)) {
      UtilUI.saveInfo(context, state.response.data, null, _isPartNerLogin ? null : _ctrPassword.text, currentPas: _isPartNerLogin ? _ctrPassword.text : null);
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_updating_password_ok'),
          title: MultiLanguage.get(languageKey.ttlAlert)).then((value) => Navigator.of(context).pop());
    }
  }
}
