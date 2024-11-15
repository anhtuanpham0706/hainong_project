import 'dart:convert';
import 'dart:io';
import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/icon_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/multi_choice.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/tree_list_page.dart';
import 'profile_variant.dart';
import '../profile_bloc.dart';

class ProfileEditPage extends BasePage {
  ProfileEditPage({Key? key}) : super(key: key, pageState: _ProfileEditPageState());
}

class _ProfileEditPageState extends PermissionImagePageState
    implements MultiChoiceCallback, ProfileListenerAll {
  final ProfileVariant _variant = ProfileVariant();
  String _imageUrl = '';
  MultiChoice? _choiceHashTag, _choiceUserType, _choiceTree;

  @override
  deleteItem(int index, String type) {
    switch(type) {
      case MultiChoice.userType: bloc!.add(AddDeleteUserTypeProfileEvent()); break;
      case MultiChoice.hashTag: bloc!.add(AddDeleteHashTagProfileEvent()); break;
      case 'tree': bloc!.add(AddDeleteTreeProfileEvent());
    }
  }

  @override
  void loadFiles(List<File> files) {
    if (files.isEmpty) return;
    _variant.image = files.first.path;
    bloc!.add(LoadImageProfileEvent());
  }

  @override
  void dispose() {
    _choiceHashTag?.list.clear();
    _choiceUserType?.list.clear();
    _choiceTree?.list.clear();
    _variant.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _choiceHashTag = MultiChoice(this, MultiChoice.hashTag);
    _choiceUserType = MultiChoice(this, MultiChoice.userType);
    _choiceTree = MultiChoice(this, 'tree');
    _variant.locale = constants.localeVILang;
    _variant.values.putIfAbsent(languageKey.lblProvince, () => '');
    _variant.values.putIfAbsent(languageKey.lblDistrict, () => '');
    _setBirthday(null);
    _setGenderUserType(
        _variant.ctrGender, languageKey.lblGender, 'male');
    _variant.catalogueUserType.addAll(Util.getUserTypeOption());
    bloc = ProfileBloc(this);
    setOnlyImage();
    super.initState();
    bloc!.add(LoadProfileEvent());
    bloc!.add(LoadProvinceProfileEvent());
    bloc!.add(LoadCatalogueProfileEvent(1));
  }

  @override
  Widget createHeaderUI() => subHeaderUI('Cập nhật thông tin');

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
          buildWhen: (oldState, newState) => newState is LoadImageProfileState,
          builder: (context, state) => ButtonImageCircleWidget(
              250.sp, () => selectImage(_variant.imageTypes),
              imageFile:
                  _variant.image.isNotEmpty ? File(_variant.image) : null,
              link: _imageUrl,
              assetsImageReplace: 'assets/images/v2/ic_avatar_drawer_v2.png')));

  @override
  String getButtonNameBodyFooter() => languageKey.btnSave;

  @override
  onPressBodyFooter() => _onClickUpdate();

  @override
  Widget createFooterUI() => SizedBox(height: 60.sp);

  @override
  Widget createFieldsSubBody() {
    final padding = SizedBox(height: 40.sp);
    return ListView(padding: EdgeInsets.zero, children: [
      TextFieldCustom(
          _variant.ctrFullName,
          _variant.focusFullName,
          _variant.focusBirthday,
          MultiLanguage.get(languageKey.lblFullName) + '*'),
      padding,
      Row(children: [
        Expanded(
            flex: 6,
            child: TextFieldCustom(
                _variant.ctrBirthday,
                _variant.focusBirthday,
                _variant.focusGender,
                MultiLanguage.get(languageKey.lblBirthday),
                readOnly: true,
                suffix: Padding(padding: EdgeInsets.only(right: 40.sp), child: const IconWidget(assetPath: 'assets/images/ic_calendar.png')),
                constraint: BoxConstraints(maxWidth: 100.sp, maxHeight: 100.sp),
                onPressIcon: () => _selectCalendar())),
        SizedBox(width: 20.sp),
        Expanded(
            flex: 4,
            child: TextFieldCustom(
                _variant.ctrGender,
                _variant.focusGender,
                _variant.focusEmail,
                MultiLanguage.get(languageKey.lblGender),
                readOnly: true,
                suffix: const Icon(Icons.arrow_drop_down),
                onPressIcon: () => UtilUI.showOptionDialog(
                        context,
                        MultiLanguage.get(languageKey.lblGender),
                        Util.getGenderOption(),
                        _variant.values[languageKey.lblGender]!)
                    .then((value) => _setGenderUserType(
                        _variant.ctrGender, languageKey.lblGender, value!.id)))),
      ]),
      padding,
      TextFieldCustom(_variant.ctrEmail, _variant.focusEmail,
          _variant.focusPhone, MultiLanguage.get(languageKey.lblEmail),
          type: TextInputType.emailAddress),
      // padding,
      // TextFieldCustom(
      //     _variant.ctrPhone,
      //     _variant.focusPhone,
      //     _variant.focusWebsite,
      //     MultiLanguage.get(languageKey.lblPhoneNumber) + '*'),
      padding,
      TextFieldCustom(
          _variant.ctrWebsite,
          _variant.focusWebsite,
          _variant.focusAddress,
          MultiLanguage.get(languageKey.lblWebsite),
          type: TextInputType.url),
      padding,
      TextFieldCustom(_variant.ctrAcreage, _variant.focusAcreage, _variant.focusAddress, 'Diện tích canh tác',
          type: TextInputType.number, isOdd: true,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^([0-9])*([.])?([0-9]?)*$'))]),
      padding,
      TextFieldCustom(
          _variant.ctrAddress,
          _variant.focusAddress,
          _variant.focusProvince,
          MultiLanguage.get(languageKey.lblAddress)),
      padding,
      TextFieldCustom(
          _variant.ctrProvince,
          _variant.focusProvince,
          _variant.focusDistrict,
          MultiLanguage.get(languageKey.lblProvince),
          padding: EdgeInsets.all(20.sp),
          readOnly: true,
          suffix: const Icon(Icons.arrow_drop_down),
          onPressIcon: () => UtilUI.showOptionDialog(
                  context,
                  MultiLanguage.get(languageKey.lblProvince),
                  _variant.provinces,
                  _variant.values[languageKey.lblProvince]!)
              .then((value) {
                if (value != null) _changedProvince(value);
          })),
      padding,
      TextFieldCustom(
          _variant.ctrDistrict,
          _variant.focusDistrict,
          null,
          MultiLanguage.get(languageKey.lblDistrict),
          readOnly: true,
          padding: EdgeInsets.all(20.sp),
          suffix: const Icon(Icons.arrow_drop_down),
          onPressIcon: () => UtilUI.showOptionDialog(
                  context,
                  MultiLanguage.get(languageKey.lblDistrict),
                  _variant.districts,
                  _variant.values[languageKey.lblDistrict]!)
              .then((value) {
                if (value != null) _setProvinceDistrict(
                    _variant.ctrDistrict, languageKey.lblDistrict,
                    id: value.id, name: value.name);
          })),
      padding,
      BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadProfileState || newState is AddDeleteUserTypeProfileState,
        builder: (context, state) => _createMultiChoice(_choiceUserType!, languageKey.lblYouAre, MultiChoice.userType)),
      padding,
      BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadProfileState || newState is AddDeleteHashTagProfileState,
        builder: (context, state) => _createMultiChoice(_choiceHashTag!, languageKey.lblHashtagsYouCare, MultiChoice.hashTag)),
      padding,
      BlocBuilder(bloc: bloc, buildWhen: (oldState, newState) => newState is LoadProfileState || newState is AddDeleteTreeProfileState,
        builder: (context, state) => _createMultiChoice(_choiceTree!, 'lbl_plant_type', 'tree')),
    ]);
  }

  Widget _createMultiChoice(
      MultiChoice choice, String title, String type) {
    String tmp = MultiLanguage.get(title);
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(10.sp),
        ),
        padding: EdgeInsets.only(
            left: 30.sp, right: 30.sp, top: 20.sp, bottom: 20.sp),
        child: Row(children: [
          Expanded(
              child: choice.list.isNotEmpty
                  ? Wrap(spacing: 20.sp, children: choice.createUIItems())
                  : Text(tmp, style: const TextStyle(color: Colors.black54))),
          ButtonImageCircleWidget(
              40.sp, () => _selectChoice(choice, tmp, type),
              child: const Icon(Icons.arrow_drop_down, color: Colors.black54))
        ]));
  }

  void _selectChoice(MultiChoice choice, String title, String type) {
    switch(type) {
      case MultiChoice.userType: _showDialogChoice(choice, _variant.catalogueUserType, title);
        break;
      case MultiChoice.hashTag: _showDialogChoice(choice, _variant.catalogueHashTag, title);
        break;
      case 'tree':
        UtilUI.goToNextPage(context, TreeListPage(_choiceTree!.list), funCallback: (value) {
          if (value != null && value.isNotEmpty) _addAllTrees(value);
        });
    }
  }

  void _showDialogChoice(MultiChoice choice, List<ItemModel> catalogue, String title) {
    clearFocus();
    UtilUI.showOptionDialog(context, title, catalogue, '').then((value) => _setItem(value!, choice));
  }

  void _setItem(ItemModel item, MultiChoice choice) {
    if (choice.addItem(item)) _updateMultiChoice(choice.type);
  }

  void _updateMultiChoice(String type) => type == MultiChoice.userType ?
    bloc!.add(AddDeleteUserTypeProfileEvent()) : bloc!.add(AddDeleteHashTagProfileEvent());

  void _addAllTrees(list) {
    _choiceTree!.list.addAll(list);
    bloc!.add(AddDeleteTreeProfileEvent());
  }

  void _setBirthday(DateTime? date) {
    if (date != null) {
      if (_variant.locale == constants.localeVILang)
        _variant.ctrBirthday.text =
            Util.dateToString(date, pattern: constants.datePatternVI);
      else
        _variant.ctrBirthday.text = Util.dateToString(date);

      _variant.values.update(languageKey.lblBirthday,
              (value) =>
              Util.dateToString(date, pattern: constants.datePattern),
          ifAbsent: () =>
              Util.dateToString(date, pattern: constants.datePattern));
    } else
      _variant.values.update(languageKey.lblBirthday,
              (value) => '', ifAbsent: () => '');
  }

  void _selectCalendar() {
    try {
      String temp = _variant.values[languageKey.lblBirthday]!;
      if (temp.isEmpty) temp = Util.dateToString(Clock().yearsAgo(20), pattern: constants.datePattern);

      DatePicker.showDatePicker(context,
          minTime: Util.stringToDateTime(constants.dateMinDefault,
              pattern: constants.datePattern),
          maxTime: DateTime.now(),
          showTitleActions: true,
          onConfirm: (DateTime date) => _setBirthday(date),
          currentTime: Util.stringToDateTime(temp, pattern: constants.datePattern),
          locale: LocaleType.vi);
    } catch (_) {}
  }

  void _setGenderUserType(TextEditingController ctr, String key, String value) {
    ctr.text = MultiLanguage.get(value);
    _variant.values.update(key, (oldValue) => value, ifAbsent: () => value);
  }

  void _setProvinceDistrict(TextEditingController ctr, String key,
      {id = '', name = ''}) {
    ctr.text = name;
    _variant.values.update(key, (value) => id, ifAbsent: () => id);
  }

  void _changedProvince(ItemModel item) {
    if (item.id != _variant.values[languageKey.lblProvince]) {
      _setProvinceDistrict(_variant.ctrProvince, languageKey.lblProvince,
          id: item.id, name: item.name);

      _variant.districts.clear();
      _variant.values
          .update(languageKey.lblDistrict, (value) => '', ifAbsent: () => '');
      _variant.ctrDistrict.text = '';
      bloc!.add(LoadDistrictProfileEvent(item.id));
    }
  }

  @override
  void handleLoadProvince(LoadProvinceProfileState state) {
    if (isResponseNotError(state.response) &&
        state.response.data.list != null &&
        state.response.data.list.length > 0) {
      _variant.provinces.addAll(state.response.data.list);
    }
  }

  @override
  void handleLoadDistrict(LoadDistrictProfileState state) {
    if (isResponseNotError(state.response) &&
        state.response.data.list != null &&
        state.response.data.list.length > 0) {
      _variant.districts.addAll(state.response.data.list);

      ItemModel district;
      String id = _variant.values[languageKey.lblDistrict]!;
      if (id.isEmpty)
        district = _variant.districts[0];
      else
        district = ItemModel(id: id, name: _variant.ctrDistrict.text);

      _setProvinceDistrict(_variant.ctrDistrict, languageKey.lblDistrict,
          id: district.id, name: district.name);
    }
  }

  @override
  void handleLoadCatalogue(LoadCatalogueProfileState state) {
    if (state.response.success && state.response.data is ItemListModel) {
      List<ItemModel> tmp = state.response.data.list;
      if (tmp.isNotEmpty) {
        _variant.catalogueHashTag.addAll(tmp);
        if (tmp.length == constants.limitLargePage) bloc!.add(LoadCatalogueProfileEvent(state.nextPage));
      }
    }
  }

  void _onClickUpdate() {
    clearFocus();
    Util.trackActivities('profile', path: 'Profile Edit Screen -> Update Information');

    if (_variant.ctrFullName.text.isEmpty) {
      UtilUI.showCustomDialog(
              context, MultiLanguage.get(languageKey.msgInputFullName))
          .then((value) => _variant.focusFullName.requestFocus());
      return;
    }

    // if (_variant.ctrPhone.text.isEmpty) {
    //   UtilUI.showCustomDialog(
    //           context, MultiLanguage.get(languageKey.msgInputPhoneNumber))
    //       .then((value) => _variant.focusPhone.requestFocus());
    //   return;
    // }

    if (_variant.ctrAcreage.text.isEmpty) _variant.ctrAcreage.text = '0';

    bloc!.add(UpdateProfileEvent(
        _variant.image,
        _variant.ctrFullName.text,
        _variant.ctrPhone.text,
        _variant.values[languageKey.lblBirthday]!,
        _variant.values[languageKey.lblGender]!,
        _variant.ctrEmail.text,
        _variant.ctrWebsite.text,
        _variant.ctrAddress.text,
        _variant.values[languageKey.lblProvince]!,
        _variant.values[languageKey.lblDistrict]!,
        _choiceUserType!.list,
        _choiceHashTag!.list,
        _choiceTree!.list, TextFieldCustom.stringToDouble(_variant.ctrAcreage.text, isOdd: true)));
  }

  @override
  void handleUpdateProfile(UpdateProfileState state) {
    if (isResponseNotError(state.response)) {
      UtilUI.saveInfo(context, state.response.data, null, null);
      UtilUI.goBack(context, true);
    }
  }

  @override
  void loadProfile(LoadProfileState state) {
    final user = state.user;
    _choiceHashTag!.list.addAll(user.has_tash_list!.list);
    _choiceTree!.list.addAll(user.tree_list!.list);
    if (user.user_type.isNotEmpty) {
      final List list = json.decode(user.user_type);
      list.forEach((item) => _choiceUserType?.addItem(ItemModel(
          id: item.toString(), name: MultiLanguage.get(item.toString()))));
    }

    _imageUrl = user.image;
    bloc!.add(LoadImageProfileEvent());

    if (user.birthdate.isNotEmpty) _setBirthday(Util.stringToDateTime(user.birthdate));

    if (user.gender.isNotEmpty) {
      _variant.ctrGender.text = MultiLanguage.get(user.gender);
      _setGenderUserType(_variant.ctrGender, languageKey.lblGender, user.gender);
    }

    if (user.district_id.isNotEmpty)
      _setProvinceDistrict(_variant.ctrDistrict, languageKey.lblDistrict,
          id: user.district_id, name: user.district_name);

    if (user.province_id.isNotEmpty) {
      _setProvinceDistrict(_variant.ctrProvince, languageKey.lblProvince,
          id: user.province_id, name: user.province_name);
      bloc!.add(LoadDistrictProfileEvent(user.province_id));
    } else if (_variant.provinces.isNotEmpty)
      bloc!.add(LoadDistrictProfileEvent(_variant.provinces[0].id));

    _variant.ctrFullName.text = user.name;
    _variant.ctrPhone.text = user.phone;
    _variant.ctrAddress.text = user.address;
    _variant.ctrEmail.text = user.email;
    _variant.ctrWebsite.text = user.website;
    if (user.acreage > 0)_variant.ctrAcreage.text = Util.doubleToString(user.acreage, digit: 3);
  }
}
