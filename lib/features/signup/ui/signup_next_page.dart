import 'import_lib_ui_signup.dart';

class SignUpNextPage extends BasePage {
  SignUpNextPage({Key? key}) : super(key: key, pageState: _SignUpNextPageState());
}

class _SignUpNextPageState extends PermissionImagePageState
    implements MultiChoiceCallback {
  final SignUpNextVariant _variant = SignUpNextVariant();
  String _imageUrl = '';
  late MultiChoice _userTypes;
  late MultiChoice _hashTags;

  @override
  void loadFiles(List<File> files) {
    if (files.isEmpty) return;
    _variant.image = files.first.path;
    bloc!.add(LoadImageSignUpEvent());
  }

  @override
  void dispose() {
    _userTypes.clear();
    _hashTags.clear();
    _variant.dispose();
    super.dispose();
  }

  @override
  initState() {
    _userTypes = MultiChoice(this, MultiChoice.userType);
    _hashTags = MultiChoice(this, MultiChoice.hashTag);
    bloc = SignUpBloc();
    setOnlyImage();
    super.initState();
    _variant.locale = constants.localeVILang;
    _variant.catalogueUserType.addAll(Util.getUserTypeOption());
    _setProvinceDistrict(_variant.ctrProvince, languageKey.lblProvince);
    _setProvinceDistrict(_variant.ctrDistrict, languageKey.lblDistrict);
    _blocAddListener();
    bloc!.add(LoadProvinceSignUpEvent());
    bloc!.add(LoadCatalogueSignUpEvent(1));
    bloc!.add(LoadProfileSignUpEvent());
    SharedPreferences.getInstance().then((prefs) {
      _imageUrl = prefs.getString(constants.image)!;
      bloc!.add(LoadImageSignUpEvent());
    });
  }

  Widget createHeaderUI() => subHeaderUI(languageKey.btnSignUp);

  Widget createFooterUI() => SizedBox(height: 60.sp);

  String getButtonNameBodyFooter() => 'btn_next';

  void onPressBodyFooter() => _onClickSignUpNext();

  Widget ignoreUI() => Column(children: [
        SizedBox(height: 60.sp),
        ButtonImageWidget(
            10.sp,
            () => UtilUI.goToPage(context, Main2Page(), null),
            Padding(
                padding: EdgeInsets.all(10.sp),
                child: Text(MultiLanguage.get('btn_ignore'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: StyleCustom.primaryColor,
                        decoration: TextDecoration.underline))))
      ]);

  Widget createFieldsSubBody() {
    final padding = SizedBox(height: 40.sp, width: 20.sp);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
            padding: EdgeInsets.only(top: 40.sp, bottom: 80.sp),
            child: Align(
                alignment: Alignment.center,
                child: Container(
                    decoration:
                        ShadowDecoration(size: 200.sp, bgColor: Colors.black26),
                    child: BlocBuilder(
                        bloc: bloc,
                        buildWhen: (oldState, newState) => newState is LoadImageSignUpState,
                        builder: (context, state) => ButtonImageCircleWidget(
                            250.sp, () => selectImage(_variant.imageTypes),
                            imageFile: _variant.image.isNotEmpty
                                ? File(_variant.image)
                                : null,
                            link: _imageUrl,
                            assetsImageReplace:
                                'assets/images/v2/ic_avatar_drawer_v2.png'))))),
        _createTitle(languageKey.lblWebsite),
        TextFieldCustom(
            _variant.ctrWebsite,
            _variant.focusWebsite,
            _variant.focusAddress,
            MultiLanguage.get('lbl_for_business'),
            padding: EdgeInsets.all(30.sp)),
        _createTitle(languageKey.lblAddress),
        TextFieldCustom(
            _variant.ctrAddress,
            _variant.focusAddress,
            _variant.focusProvince,
            MultiLanguage.get('lbl_get_gift_from_2nong'),
            padding: EdgeInsets.all(30.sp)),
        padding,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _createTitle(languageKey.lblProvince),
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
                          .then((value) => _changedProvince(value!)))
                ])),
            padding,
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _createTitle(languageKey.lblDistrict),
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
                          .then((value) => _setProvinceDistrict(
                              _variant.ctrDistrict, languageKey.lblDistrict,
                              id: value?.id, name: value?.name)))
                ]))
          ],
        ),
        _createTitle(languageKey.lblYouAre),
        BlocBuilder(
            bloc: bloc,
            buildWhen: (oldState, newState) =>
                newState is AddDeleteUserTypeSignUpState,
            builder: (context, state) => _createMultiChoice(_userTypes,
                _variant.catalogueUserType, 'lbl_personal_business')),
        _createTitle(languageKey.lblHashtagsYouCare),
        BlocBuilder(
            bloc: bloc,
            buildWhen: (oldState, newState) =>
                newState is AddDeleteHashTagSignUpState,
            builder: (context, state) => _createMultiChoice(_hashTags,
                _variant.catalogueHashTag, 'lbl_for_you_search_info')),
        padding,
      ],
    );
  }

  Widget _createTitle(String title) => Padding(
      padding: EdgeInsets.only(top: 40.sp, left: 30.sp, bottom: 10.sp),
      child: LabelCustom(MultiLanguage.get(title),
          color: Colors.black54,
          size: 30.sp,
          weight: FontWeight.normal));

  Widget _createMultiChoice(
      MultiChoice choice, List<ItemModel> catalogue, String title) {
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
              40.sp, () => _showDialogChoice(choice, catalogue, tmp),
              child: const Icon(Icons.arrow_drop_down, color: Colors.black54))
        ]));
  }

  void _blocAddListener() {
    bloc!.stream.listen((state) {
      if (state is LoadCatalogueSignUpState)
        _handleLoadCatalogue(state);
      else if (state is LoadProvinceSignUpState)
        _handleLoadProvince(state);
      else if (state is LoadDistrictSignUpState)
        _handleLoadDistrict(state);
      else if (state is ResponseSignUpNextState)
        _handleSignUpNextResponse(state);
      else if (state is LoadProfileSignUpState)
        UtilUI.saveInfo(context, state.response.data, null, null);
    });
  }

  void _showDialogChoice(
      MultiChoice choice, List<ItemModel> catalogue, String title) {
    clearFocus();
    UtilUI.showOptionDialog(context, title, catalogue, '')
        .then((value) => _setItem(value!, choice));
  }

  void _setItem(ItemModel item, MultiChoice choice) {
    if (choice.addItem(item)) _updateMultiChoice(choice.type);
  }

  void deleteItem(int index, String type) => _updateMultiChoice(type);

  void _updateMultiChoice(String type) {
    type == MultiChoice.userType ? bloc!.add(AddDeleteUserTypeSignUpEvent())
    : bloc!.add(AddDeleteHashTagSignUpEvent());
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
      bloc!.add(LoadDistrictSignUpEvent(item.id));
    }
  }

  void _onClickSignUpNext() async {
    clearFocus();
    bloc!.add(OnClickSignUpNextEvent(
        _variant.ctrWebsite.text,
        _variant.ctrAddress.text,
        _variant.values[languageKey.lblProvince]!,
        _variant.values[languageKey.lblDistrict]!,
        _userTypes.list,
        _hashTags.list,
        _variant.image));
  }

  void _handleLoadProvince(LoadProvinceSignUpState state) {
    if (isResponseNotError(state.response!) &&
        state.response!.data.list != null &&
        state.response!.data.list.length > 0) {
      _variant.provinces.addAll(state.response!.data.list);
      _changedProvince(_variant.provinces[0]);
    }
  }

  void _handleLoadDistrict(LoadDistrictSignUpState state) {
    if (isResponseNotError(state.response!) &&
        state.response!.data.list != null &&
        state.response!.data.list.length > 0) {
      _variant.districts.addAll(state.response!.data.list);
      _setProvinceDistrict(_variant.ctrDistrict, languageKey.lblDistrict,
          id: _variant.districts[0].id, name: _variant.districts[0].name);
    }
  }

  void _handleLoadCatalogue(LoadCatalogueSignUpState state) {
    if (state.response!.success && state.response!.data is ItemListModel) {
      List<ItemModel> tmp = state.response!.data.list;
      if (tmp.isNotEmpty) {
        _variant.catalogueHashTag.addAll(tmp);

        if (tmp.length == constants.limitLargePage) bloc!.add(LoadCatalogueSignUpEvent(state.nextPage!));
      }
    }
  }

  void _handleSignUpNextResponse(ResponseSignUpNextState state) {
    if (isResponseNotError(state.response!)) UtilUI.saveInfo(context, state.response!.data, null, null, page: Main2Page());
  }
}
