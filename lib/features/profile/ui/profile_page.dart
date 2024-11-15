import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_custom.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/multi_choice.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/features/shop/ui/import_ui_shop.dart';
import 'profile_edit_page.dart';
import 'show_avatar_page.dart';
import '../profile_bloc.dart';

abstract class ProfilePageCallback {
  updateProfile();
}

class ProfilePage extends BasePage {
  final bool isMain2, showEditPhone;
  final Function? checkPhone;
  final ProfilePageCallback? callback;
  ProfilePage({this.callback, this.isMain2 = false, this.showEditPhone = false, this.checkPhone, Key? key}):super(key: key, pageState: _ProfilePageState());
}

class _ProfilePageState extends BasePageState implements ProfileListener {
  String _phone = '';

  @override
  void dispose() {
    final check = (widget as ProfilePage).checkPhone;
    if (check != null) check();
    super.dispose();
  }

  @override
  void initState() {
    bloc = ProfileBloc(this);
    super.initState();
    bloc!.add(LoadProfileEvent());
    bloc!.stream.listen((state) {
      if(state is ChangePhoneState){
        _handleChangePhoneResponse(state);
      }
      else if(state is VerifyCodePhoneState) {
        _handleVerifyCodeResponse(state);
      }
      else if(state is UpdatePhoneState){
        _handleUpdatePhoneResponse(state);
      }
    });
    if ((widget as ProfilePage).showEditPhone) Timer(const Duration(milliseconds: 1500), () => _showDialogChangePhone());
  }

  @override
  Widget createHeaderUI() => subHeaderUI(languageKey.ttlDetails);

  @override
  Widget subHeaderUI(String title, {hasIcon = false}) => Padding(padding: EdgeInsets.only(top: WidgetsBinding.instance.window.padding.top.sp, left: 40.sp),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(onPressed: () => UtilUI.goBack(context, false),
                icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white)),
            Expanded(child: LabelCustom(MultiLanguage.get(title), size: 50.sp, align: TextAlign.center)),
            SizedBox(width: 40 + 40.sp)
          ]));

  @override
  Widget subBodyHeaderUI() => Container(
      margin: EdgeInsets.only(top: 100.sp),
      decoration: ShadowDecoration(size: 200.sp, bgColor: Colors.black26, shadowColor: Colors.white),
      child: BlocBuilder(
          bloc: bloc,
          buildWhen: (oldState, newState) => newState is LoadProfileState,
          builder: (context, state) {
            final user = (state as ProfileState).user;
            return user != null && user.id > 0
                ? ButtonImageCircleWidget(
                250.sp, () => _showAvatar(user.image),
                link: user.image,
                assetsImageReplace: 'assets/images/v2/ic_avatar_drawer_v2.png')
                : const SizedBox();
          }));

  @override
  String getButtonNameBodyFooter() => 'btn_update';

  @override
  void onPressBodyFooter() => UtilUI.goToNextPage(context, ProfileEditPage(), funCallback: getValueFromSecondPage);

  @override
  Widget createFooterUI() => SizedBox(height: 60.sp);

  @override
  Widget createFieldsSubBody() => BlocBuilder(bloc: bloc,
      buildWhen: (oldState, newState) => newState is LoadProfileState,
      builder: (context, state) {
        final user = (state as ProfileState).user;
        return user != null && user.id > 0
            ? ListView(padding: EdgeInsets.zero, children: [
                _createTitle(languageKey.lblFullName),
                _createValue(user.name),
                _createTitle(languageKey.lblBirthday),
                _createValue(_formatBirthday(user.birthdate)),
                _createTitle(languageKey.lblGender),
                _createValue(_formatOption(user.gender)),
                _createTitle(languageKey.lblEmail),
                _createValue(user.email),
                _createTitle(languageKey.lblPhoneNumber),
                user.phone.isEmpty ? Row(
                  children: [
                    Expanded(child:_createValue(user.phone),flex: 2),
                    SizedBox(width: 16.sp,),
                    ButtonCustom(
                      _showDialogChangePhone,
                      user.phone.isEmpty?'Cập nhập' : 'Thay đổi',
                      size: 30.sp,
                      radius: 10.sp,
                      elevation: 0.0,)
                  ],
                ) : _createValue(user.phone),
                _createTitle(languageKey.lblWebsite),
                _createValue(user.website),
                _createTitle('Diện tích canh tác'),
                _createValue(user.acreage > 0 ? Util.doubleToString(user.acreage, digit: 3) : ''),
                _createTitle(languageKey.lblAddress),
                _createValue(user.address),
                _createTitle(languageKey.lblProvince),
                _createValue(user.province_name),
                _createTitle(languageKey.lblDistrict),
                _createValue(user.district_name),
                _createTitle(languageKey.lblYouAre),
                _createUserType(user.user_type),
                _createTitle(languageKey.lblHashtagsYouCare),
                _createHashTag(user.has_tash_list?.list),
                _createTitle('lbl_plant_type'),
                _createHashTag(user.tree_list?.list),
                _createTitle('lbl_referral_code'),
                _createReferralCode(code: user.current_referral_code, link: user.referral_link)
              ])
            : const SizedBox();
      });

  @override
  void getValueFromSecondPage(value) {
    if(value != null && value) {
      bloc!.add(LoadProfileEvent());
      (widget as ProfilePage).callback?.updateProfile();
    }
  }

  @override
  void loadProfile(LoadProfileState state) {}

  Widget _createTitle(String title) => Padding(
      padding: EdgeInsets.only(top: 60.sp, left: 30.sp, bottom: 10.sp),
      child: LabelCustom(MultiLanguage.get(title),
          color: Colors.black54,
          size: 30.sp,
          weight: FontWeight.normal));

  Widget _createValue(String? value) => Container(padding: EdgeInsets.all(30.sp),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.sp),color: const Color(0xFFFAFAFA)),
      child: LabelCustom(value!, color: Colors.black, weight: FontWeight.normal));
  Widget _createLinkValue(String? value) => Container(padding: EdgeInsets.all(30.sp),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.sp), color: const Color(0xFFFAFAFA)),
      child: const LabelCustom("Chia sẻ link giới thiệu", color: Colors.black, weight: FontWeight.normal));

  Widget _createUserType(String? userType) {
    final MultiChoice choice = MultiChoice(null, MultiChoice.userType);
    if (userType != null && userType.isNotEmpty) {
      final List list = json.decode(userType);
      list.forEach((item) => choice.addItem(ItemModel(
          id: item.toString(), name: MultiLanguage.get(item.toString()))));
    }
    return RenderMultiChoice(choice);
  }

  Widget _createHashTag(List<ItemModel>? hashTags) {
    final MultiChoice choice = MultiChoice(null, MultiChoice.hashTag);
    choice.list.addAll(hashTags!);
    return RenderMultiChoice(choice);
  }

  Widget _createReferralCode({String? code, String? link}) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(height: 20.sp),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _createValue(code),
          SizedBox(width: 20.sp),
          GestureDetector(
              onTap: () => handleCopyClipboard(code ?? ""),
              child: const Icon(
                Icons.copy,
                color: Colors.black87,
                size: 20,
              ))
        ],
      ),
      SizedBox(height: 20.sp),
      GestureDetector(
        onTap:() => _shareTo(link),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _createLinkValue(link),
            SizedBox(width: 20.sp),
            Icon(Icons.share_sharp, color: Colors.black87, size: 20)
          ],
        ),
      ),
    ]);
  }

  String _formatBirthday(String? birthday) {
    if (birthday != null && birthday.isNotEmpty) {
      final date = Util.stringToDateTime(birthday);
      birthday = Util.dateToString(date,
          pattern: constants.datePatternVI);
    }
    return birthday!;
  }

  String _formatOption(String? value) {
    if (value != null && value.isNotEmpty) value = MultiLanguage.get(value);
    return value!;
  }

  void _showAvatar(String url) => UtilUI.goToNextPage(context, ShowAvatarPage(url), );

  void _showDialogChangePhone(){
    clearFocus();
    UtilUI.showConfirmDialog(
        context,
        'Thay đổi số điện thoại',
        MultiLanguage.get(languageKey.lblPhoneNumber), MultiLanguage.get(languageKey.msgInputPhoneNumber),
        title: 'Thay đổi số điện thoại',
        inputType: TextInputType.phone)
        .then((value) {
      if (value is String) {
        _phone = value;
        bloc!.add(ChangePhoneEvent(_phone));
      }
    });
  }

  void _handleUpdatePhoneResponse(UpdatePhoneState state) {
    if (isResponseNotError(state.response, showError: false)) {
      UtilUI.saveInfo(context, state.response.data, _phone, null);
      UtilUI.showCustomDialog(context, 'Thay đổi số điện thoại thành công').then((value) => bloc!.add(LoadProfileEvent()));

    } else UtilUI.showCustomDialog(context, state.response.data).then((value) => _showDialogVerifyCode());
  }

  void _handleChangePhoneResponse(ChangePhoneState state) {
    if (isResponseNotError(state.baseResponse, showError: false, passString: true)) _showDialogVerifyCode();
    else {
      UtilUI.showCustomDialog(context, state.baseResponse.data).then((value) => _showDialogChangePhone());
    }
  }

  void _showDialogVerifyCode() =>
      UtilUI.showConfirmDialog(
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
          maxLength: constants.otpMaxLength)
          .then((value) {
        if (value is String) {
          bloc!.add(VerifyCodePhoneEvent(value));
        } else if (value is bool && value) {
          bloc!.add(ChangePhoneEvent(_phone));
        }
      });

  void _handleVerifyCodeResponse(VerifyCodePhoneState state) {
    if (isResponseNotError(state.baseResponse, showError: false)) {
      UtilUI.saveInfo(context, state.baseResponse.data, _phone, null);
      bloc!.add(UpdatePhoneEvent(_phone));
    } else {
      UtilUI.showCustomDialog(context, state.baseResponse.data).then((value) => _showDialogVerifyCode());
    }
  }

  void handleCopyClipboard(String refefferCode) {
    Clipboard.setData(ClipboardData(text: refefferCode));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã giới thiệu đã được lưu")));
  }

  void _shareTo(String? link) {
    if(link?.isNotEmpty == true){
      UtilUI.shareDeeplinkTo(context, link!, 'Profile Referral Link -> Option Share Dialog -> Choose "Share"', 'profile');
    }
  }
}
