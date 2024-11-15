import 'package:hainong/common/ui/task_bar_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../profile_bloc.dart';

class ContactPage extends BasePage {
  ContactPage({Key? key}) : super(pageState: _ContactPageState(), key: key);
}

class _ContactPageState extends BasePageState implements ProfileListenerAll {
  final TextEditingController _ctrName = TextEditingController();
  final TextEditingController _ctrPhone = TextEditingController();
  final TextEditingController _ctrEmail = TextEditingController();
  final TextEditingController _ctrContent = TextEditingController();
  final FocusNode _fnName = FocusNode();
  final FocusNode _fnPhone = FocusNode();
  final FocusNode _fnEmail = FocusNode();
  final FocusNode _fnContent = FocusNode();

  @override
  void dispose() {
    _ctrName.dispose();
    _ctrPhone.dispose();
    _ctrEmail.dispose();
    _ctrContent.dispose();
    _fnName.dispose();
    _fnPhone.dispose();
    _fnEmail.dispose();
    _fnContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final lang = LanguageKey();
    final textStyle = TextStyle(fontSize: 44.sp, color: Colors.black);
    final hintStyle = TextStyle(fontSize: 44.sp, color: Colors.black54);
    return Scaffold(appBar: const TaskBarWidget('ttl_contact').createUI(),
      backgroundColor: Colors.white,
      body: ListView(padding: EdgeInsets.all(60.sp), children:[
        UtilUI.createTextField(
            context,
            _ctrName,
            _fnName,
            _fnPhone,
            MultiLanguage.get(lang.lblFullName)),
        SizedBox(height: 40.sp),
        UtilUI.createTextField(
            context,
            _ctrPhone,
            _fnPhone,
            _fnEmail,
            MultiLanguage.get(lang.lblPhoneNumber), inputType: TextInputType.phone),
        SizedBox(height: 40.sp),
        UtilUI.createTextField(
            context,
            _ctrEmail,
            _fnEmail,
            _fnContent,
            'Email', inputType: TextInputType.emailAddress),
        SizedBox(height: 40.sp),
        TextField(controller: _ctrContent, focusNode: _fnContent,
            style: textStyle,
            textInputAction: TextInputAction.newline, maxLines: 5,
            decoration: InputDecoration(enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0.sp),
                borderSide: BorderSide(color: StyleCustom.borderTextColor, width: 0.5.sp)),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0.sp),
                borderSide: BorderSide(color: StyleCustom.borderTextColor, width: 0.5.sp)),
                hintStyle: hintStyle,
                hintText: MultiLanguage.get('lbl_content'),
                counterText: '', isDense: true, contentPadding: EdgeInsets.all(30.sp))),
        SizedBox(height: 40.sp),
        UtilUI.createButton(_send, MultiLanguage.get('btn_send'))
      ])
    );
  }

  @override
  void initState() {
    bloc = ProfileBloc(this);
    bloc!.stream.listen((state) {
      if (state is SendContactState && isResponseNotError(state.response, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_sent'),
            title: MultiLanguage.get(LanguageKey().ttlAlert)).then((value) {
          UtilUI.goBack(context, false);
          Util.trackActivities('contact', method: 'onTap', path: 'Send Contact and Feedback');
            }
          );
      } else if (state is LoadProfileState) {
        _ctrName.text = state.user.name;
        _ctrPhone.text = state.user.phone;
        _ctrEmail.text = state.user.email;
      }
    });
    super.initState();
    bloc!.add(LoadProfileEvent());
  }

  void _send() {
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgInputFullName)).then((value) => _fnName.requestFocus());
      return;
    }
    if (_ctrPhone.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgInputPhoneNumber)).then((value) => _fnPhone.requestFocus());
      return;
    }
    if (_ctrEmail.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_email')).then((value) => _fnEmail.requestFocus());
      return;
    }
    if (_ctrContent.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_input_content')).then((value) => _fnContent.requestFocus());
      return;
    }
    bloc!.add(SendContactEvent(_ctrName.text, _ctrPhone.text, _ctrEmail.text, _ctrContent.text));
  }

  @override
  void handleLoadCatalogue(LoadCatalogueProfileState state) {}

  @override
  void handleLoadDistrict(LoadDistrictProfileState state) {}

  @override
  void handleLoadProvince(LoadProvinceProfileState state) {}

  @override
  void handleUpdateProfile(UpdateProfileState state) {}

  @override
  void loadProfile(LoadProfileState state) {}
}
