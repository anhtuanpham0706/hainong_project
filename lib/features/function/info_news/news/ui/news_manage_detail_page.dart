import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/multi_choice.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/home/bloc/home_event.dart';
import 'package:hainong/features/home/bloc/home_state.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import '../news_bloc.dart';
import '../news_model.dart';

class NewsManageDetailPage extends BasePage {
  final NewsModel item;
  final Function funReload;
  final int index;
  NewsManageDetailPage(this.item, this.index, this.funReload, {Key? key}):super(key: key, pageState: _NewsManageDetailPageState());
}

class _NewsManageDetailPageState extends PermissionImagePageState implements MultiChoiceCallback {
  MultiChoice? _choice;
  final TextEditingController _ctrTag = TextEditingController();
  final TextEditingController _ctrTitle = TextEditingController();
  final FocusNode _fcTitle = FocusNode();
  final TextEditingController _ctrContent = TextEditingController();
  final FocusNode _fcContent = FocusNode();
  final TextEditingController _ctrFea = TextEditingController();
  final FocusNode _fcFea = FocusNode();
  final TextEditingController _ctrCat = TextEditingController();
  final FocusNode _fcCat = FocusNode();
  final TextEditingController _ctrStatus = TextEditingController();
  final FocusNode _fcStatus = FocusNode();
  final List<ItemModel> _statuses = [
    ItemModel(id: 'disable', name: 'Tạm ẩn'),
    ItemModel(id: 'pending', name: 'Chờ duyệt')
  ];
  final List<ItemModel> _cats = [], _catsVideo = [], _catsArticle = [];
  final List<ItemModel> _features = [
    ItemModel(id: '0', name: 'Thông thường'),
    ItemModel(id: '1', name: 'Nổi bật')
  ];
  String _feature = '', _cat = '', _status = '';
  bool _lock = false;
  File? _image;

  @override
  openCameraGallery() {
    if (pass) {
      resetCheckPermission();
      final item = (widget as NewsManageDetailPage).item;
      if (item.image.isNotEmpty) bloc!.add(DownloadFilesPostItemEvent([ItemModel(name: item.image)]));
    } else super.openCameraGallery();
  }

  @override
  void loadFiles(List<File> files) {
    if (files.isNotEmpty) {
      _image = files[0];
      bloc!.add(AddImageHomeEvent());
      Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Change Image');
    }
  }

  @override
  void deleteItem(int index, String type) => bloc!.add(ChangeTagManageEvent());

  @override
  void dispose() {
    _ctrTag.dispose();
    _ctrTitle.dispose();
    _fcTitle.dispose();
    _ctrContent.dispose();
    _fcContent.dispose();
    _ctrFea.dispose();
    _fcFea.dispose();
    _ctrCat.dispose();
    _fcCat.dispose();
    _ctrStatus.dispose();
    _fcStatus.dispose();
    _statuses.clear();
    _cats.clear();
    _catsVideo.clear();
    _catsArticle.clear();
    _features.clear();
    _choice?.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = NewsBloc();
    _choice = MultiChoice(this, MultiChoice.hashTag);
    _setRole(isSet: false);
    setOnlyImage();
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadCatManageState) {
        (widget as NewsManageDetailPage).item.classable_type == 'video' ? _catsVideo.addAll(state.list) : _catsArticle.addAll(state.list);
        _cats.addAll(state.list);
      } else if (state is DownloadFilesPostItemState) loadFiles(state.response);
      else if (state is CUDNewsManageState) {
        if (isResponseNotError(state.response)) {
          (widget as NewsManageDetailPage).funReload();
          (widget as NewsManageDetailPage).item.id = state.response.data.id;
          UtilUI.showCustomDialog(context, 'Lưu thành công', title: 'Thông báo');
        }
        _lock = false;
      } else if (state is DeleteNewsState) {
        if (isResponseNotError(state.response, passString: true)) {
          (widget as NewsManageDetailPage).funReload();
          UtilUI.goBack(context, true);
        }
        _lock = false;
      }
    });
    final item = (widget as NewsManageDetailPage).item;
    bloc!.add(LoadCatManageEvent(item.classable_type));
    if (item.id > 0) {
      pass = true;
      checkPermissions(ItemModel(id: languageKey.lblGallery));

      int index = int.parse(item.is_feature);
      if (-1 < index && index < _features.length) _setFeature(ItemModel(id: item.is_feature, name: _features[index].name));

      _setCat(ItemModel(id: item.article_catalogue_id.toString(), name: item.article_catalogue_name));

      index = -1;
      switch(item.status) {
        case 'disable': index = 0; break;
        case 'pending': index = 1; break;
        case 'active': index = 2; break;
      }
      if (index > -1 && index < _statuses.length) _setStatuses(ItemModel(id: _statuses[index].id, name: _statuses[index].name));

      _ctrTitle.text = item.title;
      _ctrContent.text = item.content;
      if (item.tags.isNotEmpty) _choice!.list.addAll(item.tags);
    }
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final page = widget as NewsManageDetailPage;
    String title = 'Tạo mới tin';
    if (page.item.id > 0) title = 'Chi tiết tin ${page.item.classable_type == 'video' ? 'video' : 'nông nghiệp'}';
    return Stack(children: [
      Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0,
          title: UtilUI.createLabel(title, textAlign: TextAlign.center),
          actions: [
            BlocBuilder(bloc: bloc,
              buildWhen: (oldS, newS) => newS is CUDNewsManageState,
              builder: (context, stats) => page.item.id < 0 ? const SizedBox() :
                IconButton(onPressed: _delete, icon: Icon(Icons.delete_forever,
                    color: Colors.white, size: 48.sp)))
          ]),
        backgroundColor: Colors.white, floatingActionButton:
          FloatingActionButton.small(backgroundColor: StyleCustom.primaryColor,
            onPressed: _save, child: BlocBuilder(bloc: bloc,
              buildWhen: (oldS, newS) => newS is CUDNewsManageState,
              builder: (context, stats) => Icon(page.item.id < 0 ? Icons.save :
                Icons.edit, color: Colors.white, size: 48.sp))),
        body: ListView(padding: EdgeInsets.fromLTRB(40.sp, ScreenUtil().statusBarHeight + 40.sp, 40.sp, ScreenUtil().bottomBarHeight + 40.sp),
          children: [
            SizedBox(height: 40.sp),
            UtilUI.createTextField(context, _ctrTitle, _fcTitle, null, 'Nhập tiêu đề*',
              padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 20.sp), maxLength: 200,
              inputAction: TextInputAction.newline, inputType: TextInputType.multiline, maxLines: null),
            SizedBox(height: 40.sp),
            TextFieldCustom(_ctrContent, _fcContent, null, 'Nhập nội dung*',
                inputAction: TextInputAction.newline, type: TextInputType.multiline, maxLength: 500,
                maxLine: 10, padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 20.sp)),
            SizedBox(height: 40.sp),
            TextFieldCustom(_ctrTag, null, null, 'Nhập từ khoá nổi bật',
                suffix: const Icon(Icons.add, color: StyleCustom.primaryColor),
                inputAction: TextInputAction.done, onSubmit: _addTag, onPressIcon: _addTag,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z_-]'))]),
            BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeTagManageState,
              builder: (context, state) => _choice != null && _choice!.list.isNotEmpty ?
                Padding(padding: EdgeInsets.only(top: 40.sp),
                    child: RenderMultiChoice(_choice!)) : const SizedBox()),
            SizedBox(height: 40.sp),
            /*Row(children: [
              Expanded(child: Row(children: [
                UtilUI.createLabel('Là video: ',
                    color: Colors.black87, fontSize: 48.sp, fontWeight: FontWeight.normal),
                ButtonImageWidget(0.0, _setRole, BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeStatusManageState,
                    builder: (context, state) {
                      final isVideo = (widget as NewsManageDetailPage).item.classable_type == 'video';
                      return Icon(isVideo ? Icons.check_box : Icons.check_box_outline_blank, color: StyleCustom.primaryColor, size: 56.sp);
                    }))
              ])),
              SizedBox(width: 40.sp),
              Expanded(child: TextFieldCustom(_ctrStatus, _fcStatus, null, 'Chọn trạng thái',
                  suffix: const Icon(Icons.arrow_drop_down), readOnly: true,
                  onPressIcon: () => UtilUI.showOptionDialog(context, 'Trạng thái',
                      _statuses, _status).then((value) => _setStatuses(value))))
            ]),*/
            TextFieldCustom(_ctrCat, _fcCat, null, 'Chọn danh mục',
                suffix: const Icon(Icons.arrow_drop_down), readOnly: true,
                onPressIcon: () {
                  if (_cats.isNotEmpty) {
                    UtilUI.showOptionDialog(context, 'Danh mục',
                        _cats, _cat).then((value) => _setCat(value));
                  }
                }),
            SizedBox(height: 40.sp),
            Row(children: [
              Expanded(child: TextFieldCustom(_ctrFea, _fcFea, null, 'Chọn Thông thường/Nổi bật',
                  suffix: const Icon(Icons.arrow_drop_down), readOnly: true,
                  onPressIcon: () => UtilUI.showOptionDialog(context, 'Thông thường/Nổi bật',
                      _features, _feature).then((value) => _setFeature(value)))),
              SizedBox(width: 40.sp),
              Expanded(child: TextFieldCustom(_ctrStatus, _fcStatus, null, 'Chọn trạng thái',
                  suffix: const Icon(Icons.arrow_drop_down), readOnly: true,
                  onPressIcon: () => UtilUI.showOptionDialog(context, 'Trạng thái',
                      _statuses, _status).then((value) => _setStatuses(value))))
            ]),
            SizedBox(height: 40.sp),
            Row(children: [
              Expanded(child: ButtonImageWidget(.0, () => _loadImage(languageKey.lblCamera), Container(
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                    border: Border.all(color: StyleCustom.primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(10.sp)
                ),
                child: Icon(Icons.camera_alt_outlined, color: StyleCustom.primaryColor, size: 56.sp),
              ))),
              SizedBox(width: 40.sp),
              Expanded(child: ButtonImageWidget(.0, () => _loadImage(languageKey.lblGallery), Container(
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                    border: Border.all(color: StyleCustom.primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(10.sp)
                ),
                child: Icon(Icons.image_outlined, color: StyleCustom.primaryColor, size: 56.sp),
              )))
            ]),
            SizedBox(height: 40.sp),
            BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is AddImageHomeState,
                builder: (context, state) => _image == null ? const SizedBox() :
                Stack(alignment: Alignment.topRight, children: [
                  Image.memory(_image!.readAsBytesSync(), width: 1.sw,
                      height: 0.58.sw, fit: BoxFit.scaleDown),
                  Container(padding: EdgeInsets.all(10.sp), decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50), color: Colors.black26
                  ), margin: EdgeInsets.only(top: 20.sp, right: 20.sp),
                      child: ButtonImageCircleWidget(50, (){
                        _image = null;
                        bloc!.add(AddImageHomeEvent());
                      }, child: Icon(Icons.clear, color: Colors.white, size: 64.sp)))
                ]))
          ])),
      Loading(bloc)
    ]);
  }

  void _loadImage(String type) {
    pass = false;
    checkPermissions(ItemModel(id: type, name: MultiLanguage.get(type)));
  }

  void _setRole({bool isSet = true}) {
    final item = (widget as NewsManageDetailPage).item;
    if (isSet && item.id < 0) {
      _cats.clear();
      if (item.classable_type == 'video') {
        item.classable_type = 'article';
        if (_catsArticle.isNotEmpty) _cats.addAll(_catsArticle);
        Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Change Type = "Article"');
      } else {
        item.classable_type = 'video';
        if (_catsVideo.isNotEmpty) _cats.addAll(_catsVideo);
        Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Change Type = "Video"');
      }
      if (_cats.isEmpty) bloc!.add(LoadCatManageEvent(item.classable_type));
      _setCat(ItemModel());
    }
    _addFullRole(item.classable_type == 'video' ? 'videos' : 'articles');
    if (_statuses.length < 3 && _status == 'active') _setStatuses(ItemModel());
    if (item.id < 0) bloc!.add(ChangeStatusManageEvent());
  }

  void _addFullRole(String keyType) {
    if (_statuses.length == 3) _statuses.removeAt(2);
    if (Constants().contributeRole!.containsKey(keyType)) {
      if (Constants().contributeRole![keyType] == 'full') _statuses.add(ItemModel(id: 'active', name: 'Công khai'));
    }
  }

  void _setCat(ItemModel? value) {
    if (value != null) {
      _cat = value.id;
      _ctrCat.text = value.name;
      Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Change Catalogue = "${_ctrCat.text}"');
    }
  }

  void _setFeature(ItemModel? value) {
    if (value != null) {
      _feature = value.id;
      _ctrFea.text = value.name;
      Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Change Feature = "${_ctrFea.text}"');
    }
  }

  void _setStatuses(ItemModel? value) {
    if (value != null) {
      _status = value.id;
      _ctrStatus.text = value.name;
      Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Change Status = "${_ctrStatus.text}"');
    }
  }

  void _addTag() {
    if (_ctrTag.text.trim().isEmpty) return;
    _choice?.addItem(ItemModel(id: _ctrTag.text, name: _ctrTag.text));
    bloc!.add(ChangeTagManageEvent());
    Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Add More Tag = "${_ctrTag.text}"');
    _ctrTag.text = '';
  }

  void _save() {
    clearFocus();
    if (_ctrTitle.text.trim().isEmpty) {
      _fcTitle.requestFocus();
      UtilUI.showCustomDialog(context, 'Nhập tiêu đề');
      return;
    }
    if (_ctrContent.text.trim().isEmpty) {
      _fcContent.requestFocus();
      UtilUI.showCustomDialog(context, 'Nhập nội dung');
      return;
    }
    if (_status.isEmpty) {
      _fcStatus.requestFocus();
      UtilUI.showCustomDialog(context, 'Chọn trạng thái');
      return;
    }
    if (_cat.isEmpty) {
      _fcCat.requestFocus();
      UtilUI.showCustomDialog(context, 'Chọn danh mục');
      return;
    }
    if (_feature.isEmpty) {
      _fcFea.requestFocus();
      UtilUI.showCustomDialog(context, 'Chọn Thông thường/Nổi bật');
      return;
    }
    if (_image == null) {
      UtilUI.showCustomDialog(context, 'Chọn một ảnh');
      return;
    }
    if (_lock) return;
    _lock = true;
    final item = (widget as NewsManageDetailPage).item;
    bloc!.add(CUDNewsManageEvent(item.id, _ctrTitle.text, _ctrContent.text,
        _choice!.list, item.classable_type, _status, _cat, _feature, _image!.path));
    Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> ${item.id > 0 ? 'Update' : 'Create'} News');
  }

  void _delete() {
    if (_lock) return;
    UtilUI.showCustomDialog(context, 'Bạn có chắc muốn xoá tin này không?', isActionCancel: true)
        .then((value) {
      if (value != null && value) {
        _lock = true;
        final item = (widget as NewsManageDetailPage).item;
        bloc!.add(DeleteNewsEvent(item.id, item.classable_type));
        Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Dialog Confirm Delete -> Choose Button "OK" -> Delete News With ID = "${item.id}"');
        return;
      }
      Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Dialog Confirm Delete -> Choose Button "Cancel"');
    });
    Util.trackActivities('news_detail', path: 'Manage News Detail Screen -> Show Dialog Confirm Delete');
  }
}