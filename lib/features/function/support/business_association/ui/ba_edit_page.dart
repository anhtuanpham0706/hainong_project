import 'dart:async';
import 'dart:io';
import 'package:hainong/features/function/support/mission/mission_bloc.dart';
import 'package:hainong/features/product/ui/edit_to_html_page.dart';
import 'package:hainong/features/profile/ui/show_avatar_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/features/home/bloc/home_bloc.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:webviewx/webviewx.dart';
import '../ba_bloc.dart';
import '../ba_model.dart';

class BAEditPage extends BasePage {
  final dynamic detail;
  BAEditPage(this.detail, {Key? key}) : super(pageState: _BAEditPageState(), key: key);
}

class _BAEditPageState extends PermissionImagePageState {
  final TextEditingController _ctrName = TextEditingController(), _ctrPhone = TextEditingController(),
      _ctrEmail = TextEditingController(), _ctrAddress = TextEditingController(),
      _ctrWebsite = TextEditingController(), _ctrContent = TextEditingController(),
      _ctrProvince = TextEditingController(), _ctrDistrict = TextEditingController();
  final FocusNode _fcName = FocusNode(), _fcPhone = FocusNode(), _fcEmail = FocusNode(),
      _fcAddress = FocusNode(), _fcWebsite = FocusNode(), _fcContent = FocusNode(),
      _fcProvince = FocusNode(), _fcDistrict = FocusNode();
  final List<ItemModel> _provinces = [], _districts = [];
  final ItemModel _province = ItemModel(), _district = ItemModel();
  bool _isFinished = false;
  WebViewXController? _controller;

  @override
  void dispose() {
    _ctrName.dispose();
    _fcName.dispose();
    _fcPhone.dispose();
    _ctrPhone.dispose();
    _fcEmail.dispose();
    _ctrEmail.dispose();
    _fcWebsite.dispose();
    _ctrAddress.dispose();
    _fcAddress.dispose();
    _ctrWebsite.dispose();
    _fcContent.dispose();
    _ctrContent.dispose();
    _fcProvince.dispose();
    _ctrProvince.dispose();
    _fcDistrict.dispose();
    _ctrDistrict.dispose();
    _provinces.clear();
    _districts.clear();
    images?.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = BABloc('detail');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is DownloadFilesPostItemState) {
        loadFiles(state.response);
      } else if (state is EditState && isResponseNotError(state.response)) {
        (widget as BAEditPage).detail.setValue(state.response.data);
        UtilUI.goBack(context, (widget as BAEditPage).detail);
      } else if (state is LoadProvinceState) {
        _provinces.addAll(state.list);
      } else if (state is LoadDistrictState) {
        _districts.addAll(state.list);
      }
    });
    bloc!.add(LoadProvinceEvent());
    _initData();
  }

  @override
  void showLoadingPermission({bool value = true}) => bloc!.add(LoadingEvent(value));

  @override
  void loadFiles(List<File> files) {
    showLoadingPermission();
    bool overSize = false;
    int size = getSize();
    for(int i = 0; i < files.length; i++) {
      if (size + files[i].lengthSync() > 102400000) {
        overSize = true;
        break;
      }
      size += files[i].lengthSync();
      images!.add(FileByte(files[i].readAsBytesSync(), files[i].path));
    }
    bloc!.add(AddImageHomeEvent());
    if (overSize) UtilUI.showCustomDialog(context, MultiLanguage.get('msg_file_100mb'));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      appBar: AppBar(elevation: 10, titleSpacing: 0, centerTitle: true,
          actions: [
            IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))
          ],
          title: UtilUI.createLabel('Thông tin doanh nghiệp')),
      backgroundColor: Colors.white, body: Stack(children: [createUI(), Loading(bloc)]));

  @override
  Widget createUI() {
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Column(children: [
      Expanded(child: ListView(padding: EdgeInsets.symmetric(vertical: 40.sp), children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
        Row(children: [_title('Tên doanh nghiệp'), require])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrName, _fcName, null, 'Nhập tên doanh nghiệp',
                size: 42.sp, color: color, borderColor: color, maxLine: 0, inputAction: TextInputAction.newline,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Số điện thoại')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrPhone, _fcPhone, _fcEmail, 'Nhập số điện thoại',
                size: 42.sp, color: color, borderColor: color)),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Email')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrEmail, _fcEmail, _fcAddress, 'Nhập email',
                size: 42.sp, color: color, borderColor: color)),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Tình/ Thành phố')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrProvince, _fcProvince, null, 'Chọn Tỉnh/ Thành phố',
                size: 42.sp, color: color, borderColor: color, readOnly: true,
                type: TextInputType.multiline, inputAction: TextInputAction.newline, maxLine: 0,
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp),
                onPressIcon: _selectProvince, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Quận/ Huyện')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrDistrict, _fcDistrict, null, 'Chọn quận/ Huyện',
                size: 42.sp, color: color, borderColor: color, readOnly: true,
                type: TextInputType.multiline, inputAction: TextInputAction.newline, maxLine: 0,
                suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp),
                onPressIcon: _selectDistrict, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: _title('Địa chỉ')),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrAddress, _fcAddress, null, 'Nhập địa chỉ',
                size: 42.sp, color: color, borderColor: color, maxLine: 0, inputAction: TextInputAction.newline,
                type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
          Row(children: [_title('Địa chỉ website'), require])),
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 40.sp),
            child: TextFieldCustom(_ctrWebsite, _fcWebsite, _fcContent, 'Nhập địa chỉ website',
                size: 42.sp, color: color, borderColor: color)),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: Row(children: [
          _title('Giới thiệu'),
          SizedBox(width: 20.sp),
          ButtonImageWidget(0, () => UtilUI.goToNextPage(context, EditorToHtmlPage(result: _ctrContent.text),
              funCallback: _updateContent), Image.asset('assets/images/ic_edit_post.png', color: Colors.green, width: 52.sp, height: 52.sp))
        ])),
        Container(margin: EdgeInsets.fromLTRB(40.sp, 16.sp, 40.sp, 0), color: color,
            child: BlocBuilder(bloc: bloc,
                buildWhen: (oldState, newState) => newState is SetHeightState,
                builder: (context, state) {
                  double height = 10;
                  if (state is SetHeightState) height = state.height;
                  if (height < 0) {
                    _isFinished = false;
                    _controller = null;
                    Timer(const Duration(milliseconds: 1500), () => bloc!.add(SetHeightEvent(10)));
                    return const SizedBox();
                  }
                  return WebViewX(jsContent: {EmbeddedJsContent(js: Constants().jvWebView, mobileJs: Constants().jvWebView)},
                      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.alwaysAllow,
                      initialContent: _ctrContent.text.isNotEmpty ? _ctrContent.text : 'Nhập mô tả ...',
                      initialSourceType: SourceType.html,
                      height: height, width: 1.sw,
                      onWebViewCreated: (controller) {
                        _controller ??= controller;
                      },
                      webSpecificParams: const WebSpecificParams(webAllowFullscreenContent: false),
                      mobileSpecificParams: const MobileSpecificParams(
                          androidEnableHybridComposition: true
                      ),
                      navigationDelegate: (navigation) async {
                        if (!_isFinished) return NavigationDecision.navigate;
                        String http = navigation.content.source;
                        if (!http.contains('http')) http = 'https://$http';
                        //if (await canLaunchUrl(Uri.parse(http))) launchUrl(Uri.parse(http));
                        if (await canLaunchUrl(Uri.parse(http))) {
                          Util.isImage(http) ? UtilUI.goToNextPage(context, ShowAvatarPage(http)) : launchUrl(Uri.parse(http), mode: LaunchMode.externalApplication);
                        }
                        return NavigationDecision.prevent;
                      },
                      onPageFinished: (value) async {
                        if (!_isFinished) {
                          _isFinished = true;
                          //await _controller?.evalRawJavascript(constants.jvWebView);
                          //await Future.delayed(const Duration(seconds: 1));
                          await _controller?.scrollBy(0, 10);
                          String heightStr = await _controller
                              ?.evalRawJavascript(
                              "document.documentElement.scrollHeight") ?? "0";
                          bloc!.add(SetHeightEvent(double.parse(heightStr)));
                        }
                      }
                  );
                })),

        imageUI(_selectImage, _deleteImage)
      ])),

      const Divider(height: 0.5, color: Colors.black12),
      Padding(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(16.sp, _save,
          Container(padding: EdgeInsets.all(40.sp), width: 1.sw, child: LabelCustom('Lưu',
              color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)),
    ]);
  }

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _initData() {
    setOnlyImage();
    multiSelect = false;
    images = [];
    final detail = (widget as BAEditPage).detail as BAModel;
    if (detail.image.isNotEmpty) bloc!.add(DownloadFilesPostItemEvent([ItemModel(name: detail.image)]));
    _ctrName.text = detail.name;
    _ctrPhone.text = detail.phone;
    _ctrEmail.text = detail.email;
    _ctrAddress.text = detail.address;
    _ctrWebsite.text = detail.website;
    _ctrContent.text = detail.content;
    _setProvince(ItemModel(id: detail.province, name: detail.proName));
    _setDistrict(ItemModel(id: detail.district, name: detail.disName));
  }

  void _selectProvince() => UtilUI.showOptionDialog(context, 'Chọn tỉnh/ Thành phố', _provinces, _province.id).then((value) {
    if (value != null) _setProvince(value);
  });

  void _setProvince(ItemModel value, {bool loadDistrict = true}) {
    if (_province.id != value.id) {
      _ctrProvince.text = value.name;
      _province.setValue(value.id, value.name);

      if (loadDistrict) {
        _districts.clear();
        _ctrDistrict.text = '';
        _district.setValue('', '');
        bloc!.add(LoadDistrictEvent(_province.id));
      }
    }
  }

  void _selectDistrict() => UtilUI.showOptionDialog(context, 'Chọn quận/ Huyện', _districts, _district.id).then((value) {
    if (value != null) _setDistrict(value);
  });

  void _setDistrict(ItemModel value) {
    if (_province.id != value.id) {
      _ctrDistrict.text = value.name;
      _district.setValue(value.id, value.name);
    }
  }

  void _selectImage() {
    if (images != null && images!.isNotEmpty) return;
    clearFocus();
    selectImage([
      ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)),
      ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery))
    ]);
  }

  void _deleteImage(int index) {
    clearFocus();
    images!.removeAt(index);
    bloc!.add(AddImageHomeEvent());
  }

  void _updateContent(dynamic value) {
    SharedPreferences.getInstance().then((prefs) => prefs.remove('hainong_url'));
    if (_ctrContent.text == value.toString()) return;
    _ctrContent.text = value.toString();
    bloc!.add(SetHeightEvent(-1));
  }

  void _save() {
    clearFocus();
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên doanh nghiệp').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_ctrWebsite.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập địa chỉ website').whenComplete(() => _fcWebsite.requestFocus());
      return;
    }
    bloc!.add(EditEvent(BAModel(id: (widget as BAEditPage).detail.id, name: _ctrName.text,
      phone: _ctrPhone.text, email: _ctrEmail.text, address: _ctrAddress.text,
      website: _ctrWebsite.text, content: _ctrContent.text, province: _province.id,
      district: _district.id), images));
  }
}