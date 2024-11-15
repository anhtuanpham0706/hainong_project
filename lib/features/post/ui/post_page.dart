import 'dart:typed_data';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:traceability_module/common/label_custom.dart';

import 'import_lib_ui_post.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PostPage extends BasePage {
  final String shopName, shopImage, permission;
  final Post? item;
  final bool openGallery;

  PostPage(this.shopName, this.shopImage, {Key? key, this.item, this.permission = '', this.openGallery = false})
      : super(key: key, pageState: _PostPageState());
}

class _PostPageState extends PermissionImagePageState {
  final _ctrDescription = TextEditingController();
  final _focusDescription = FocusNode();
  final List<FileByte> _images = [];
  final List<dynamic> _catalogue = [];
  final List<dynamic> _thumbnail = [];
  final PostItemBloc _itemBloc = PostItemBloc(PostItemState());
  final List<AlbumModel> _albums = [];
  bool _checkPostAuto = false;
  //int _indexCatalogues = -1;
  String _idAlbum = '';

  int _getSize() {
    int maxSize = 0;
    for (var file in _images) {
      maxSize += file.bytes.length;
    }
    return maxSize;
  }

  @override
  void clearFocus() {
    super.clearFocus();
    _hideFilter();
  }

  @override
  void showLoadingPermission({bool value = true}) => bloc!.add(ShowLoadingHomeEvent(value));

  @override
  void loadFiles(List<File> files) async {
    showLoadingPermission();
    bool overSize = false;
    int size = _getSize();
    for (int i = 0; i < files.length; i++) {
      if (size + files[i].lengthSync() > 102400000) {
        overSize = true;
        break;
      }
      size += files[i].lengthSync();

      if (_isMOV(files[i].path)) {
        MediaInfo? mediaInfo = await VideoCompress.compressVideo(files[i].path, quality: VideoQuality.MediumQuality);
        _images.add(FileByte(mediaInfo!.file!.readAsBytesSync(), mediaInfo.file!.path));
        await VideoCompress.deleteAllCache();
      } else _images.add(FileByte(files[i].readAsBytesSync(), files[i].path));

      if (Util.isImage(files[i].path)) {
        _thumbnail.add(null);
      } else {
        final listByte = await VideoThumbnail.thumbnailData(video: files[i].path, quality: 80);
        _thumbnail.add(listByte);
      }
    }
    bloc!.add(AddImageHomeEvent());
    if (overSize) UtilUI.showCustomDialog(context, MultiLanguage.get('msg_file_100mb'));
  }

  @override
  void openCameraGallery() {
    if (pass) {
      resetCheckPermission();
      Post? post = (widget as PostPage).item;
      if (post != null && post.images.list.isNotEmpty) {
        showLoadingPermission();
        _itemBloc.add(DownloadFilesPostItemEvent(post.images.list));
      }
    } else super.openCameraGallery();
  }

  @override
  void dispose() {
    _albums.clear();
    _itemBloc.close();
    _images.clear();
    _catalogue.clear();
    _ctrDescription.dispose();
    _focusDescription.dispose();
    _thumbnail.clear();
    super.dispose();
  }

  @override
  void initState() {
    multiSelect = true;
    pass = true;
    bloc = HomeBloc(HomeState());
    checkPermissions(ItemModel(id: languageKey.lblGallery));
    Post? post = (widget as PostPage).item;
    if (post != null) _ctrDescription.text = post.title;
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePostHomeState && isResponseNotError(state.response)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(MultiLanguage.get('msg_'+(_checkPostAuto?'':'in')+'active_process_post_auto'))));
        Navigator.of(context).pop(state.response);
      } else if (state is LoadCatalogueHomeState)
        _catalogue.addAll(state.response);
      else if (state is DownloadFilesPostItemState)
        loadFiles(state.response);
      else if (state is LoadAlbumUserState && state.response.data.isNotEmpty)
        _albums.addAll(state.response.data);
      else if (state is CheckProcessPostAutoState) {
        _checkPostAuto = state.isActive ?? false;
        _selectAlbum();
      }
    });
    _itemBloc.stream.listen((state) {
      if (state is DownloadFilesPostItemState) loadFiles(state.response);
    });
    bloc!.add(LoadCatalogueHomeEvent());
    bloc!.add(LoadAlbumUserEvent(0, 0));
    Timer(const Duration(milliseconds: 1000), () {
      if ((widget as PostPage).openGallery) _selectImage();
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    GestureDetector(onTap: _hideFilter, child: Scaffold(
      //appBar: TaskBarWidget('btn_create_post', lblButton: 'btn_post', onPressed: clickButtonPost).createUI(),
      appBar: AppBar(title: Row(children: [
          Expanded(child: UtilUI.createLabel('Tạo Tin Đăng', textAlign: TextAlign.center)),
          ButtonImageWidget(20, clickButtonPost, Padding(padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 15.sp),
            child: Row(children: [
              Icon(Icons.send_outlined, color: Colors.white, size: 48.sp),
              LabelCustom(' Đăng', weight: FontWeight.w500, size: 48.sp)
            ])), color: Colors.orangeAccent)
      ])),
      body: Container(color: StyleCustom.backgroundColor, child: Column(children: [
        Padding(
                          padding: EdgeInsets.only(top: 40.sp, left: 40.sp, right: 40.sp, bottom: 40.sp),
                          child: Row(children: [
                            AvatarCircleWidget(link: (widget as PostPage).shopImage, size: 150.sp),
                            Padding(padding: EdgeInsets.all(10.sp)),
                            Expanded(
                                child: UtilUI.createLabel((widget as PostPage).shopName, color: Colors.black, fontSize: 45.sp)),
                          ])),
        SizedBox(
                          height: 120.sp,
                          child: BlocBuilder(
                              bloc: bloc,
                              buildWhen: (oldState, newState) =>
                                  newState is LoadCatalogueHomeState || newState is ChangeIndexHomeState,
                              builder: (context, state) {
                                return ListView.builder(
                                    padding: EdgeInsets.only(left: 30.sp, bottom: 30.sp),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _catalogue.length,
                                    itemBuilder: (context, index) => CatalogueItem(
                                        _catalogue[index], false, _changeIndexCatalogues, index,
                                        openPage: false));
                              })),
        Expanded(child: Padding(padding: EdgeInsets.only(left: 40.sp, right: 40.sp),
          child: ListView(children: [
                                TextField(
                                    style: TextStyle(fontSize: 35.sp),
                                    controller: _ctrDescription,
                                    focusNode: _focusDescription,
                                    decoration: InputDecoration(
                                        focusColor: Colors.grey,
                                        hintText: MultiLanguage.get(languageKey.msgInputShareDescription)),
                                    minLines: 1,
                                    maxLines: 100,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    onChanged: (value) => _textChanged(value)),
                                BlocBuilder(
                                    bloc: bloc,
                                    buildWhen: (oldState, newState) => newState is AddHashTagHomeState,
                                    builder: (context, state) {
                                      List<dynamic> filters = [];
                                      String key = '';
                                      if (state is AddHashTagHomeState && state.key != null) {
                                        filters.addAll(state.filters!);
                                        key = state.key!;
                                      }
                                      return filters.isEmpty ? Container() : _createFilters(filters, key);
                                    }),
                                SizedBox(height: 120.sp),
                                BlocBuilder(bloc: bloc,
                                    buildWhen: (oldState, newState) => newState is AddImageHomeState,
                                    builder: (context, state) => _createImages())
          ]))),
        Container(
                          width: 1.sw,
                          decoration: BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3), spreadRadius: 3, blurRadius: 7, offset: const Offset(0, 3))
                          ]),
                          child: OutlinedButton(
                              onPressed: _selectImage,
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  padding: EdgeInsets.zero),
                              child: Column(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(top: 40.sp),
                                      width: 0.18.sw,
                                      height: 8.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(20.sp),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 60.sp, bottom: 60.sp),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.image, color: Colors.deepOrangeAccent),
                                          Text(MultiLanguage.get('lbl_image_video_from_gallery'),
                                              style: TextStyle(fontSize: 40.sp))
                                        ],
                                      ))
                                ],
                              )))
      ])))),
    Loading(bloc)
  ]);

  Widget _createFilters(List<dynamic> list, String key) {
    List<Widget> widgets = [];
    for (var item in list) {
      widgets.add(_createFilterItem(item, key));
    }
    return Container(
        decoration: ShadowDecoration(opacity: 0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets));
  }

  Widget _createFilterItem(dynamic item, String key) => OutlinedButton(
      style: OutlinedButton.styleFrom(
          side: const BorderSide(
        color: Colors.transparent,
      )),
      onPressed: () => _selectItemFilter(item['name']??'', key),
      child: Row(children: [Text(item['name']??'', style: TextStyle(fontSize: 40.sp, color: Colors.black))]));

  Widget _createImages() {
    switch (_images.length) {
      case 0:
        return Container();
      case 1:
        return _create1Images();
      case 2:
        return _create2Images();
      case 3:
        return _create3Images();
      default:
        return _create4Images();
    }
  }

  Widget _create1Images() => _createImage(1.sw, 0.4.sh, _images[0].name, 0);

  Widget _create2Images() => Row(children: [
        Expanded(child: _createImage(0.5.sw, 0.25.sh, _images[0].name, 0)),
        Padding(padding: EdgeInsets.all(2.sp)),
        Expanded(child: _createImage(0.5.sw, 0.25.sh, _images[1].name, 1)),
      ]);

  Widget _create3Images() => Row(children: [
        Expanded(flex: 6, child: _createImage(0.6.sw, 0.5.sh, _images[0].name, 0)),
        Padding(padding: EdgeInsets.all(2.sp)),
        Expanded(flex: 4, child: Column(children: [
              _createImage(0.4.sw, 0.25.sh - 2.sp, _images[1].name, 1),
              Padding(padding: EdgeInsets.all(2.sp)),
              _createImage(0.4.sw, 0.25.sh, _images[2].name, 2)
            ]))
      ]);

  Widget _create4Images() => Row(children: [
        Expanded(flex: 1, child: Column(children: [
              _createImage(0.5.sw, 0.25.sh, _images[0].name, 0),
              Padding(padding: EdgeInsets.all(2.sp)),
              _createImage(0.5.sw, 0.25.sh, _images[1].name, 1),
            ])),
        Padding(padding: EdgeInsets.all(2.sp)),
        Expanded(flex: 1, child: Column(children: [
              _createImage(0.5.sw, 0.25.sh, _images[2].name, 2),
              Padding(padding: EdgeInsets.all(2.sp)),
              Stack(alignment: Alignment.center, children: [
                _createImage(0.5.sw, 0.25.sh, _images[3].name, 3),
                _images.length > 4 ? Container(alignment: Alignment.center,
                  child: UtilUI.createLabel('+' + (_images.length - 4).toString(), fontSize: 60.sp)) : Container()
              ])
            ])),
      ]);

  Widget _createImage(double width, double height, String url, int index) {
    try {
      final bool isImage = Util.isImage(url);
      return Stack(alignment: Alignment.topRight, children: [
        Container(width: width, height: height, alignment: Alignment.center,
          decoration: BoxDecoration(image: DecorationImage(image: (
            isImage || _thumbnail[index] == null ? Image.file(File(_images[index].name), width: width, height: height) :
            Image.memory(_thumbnail[index] as Uint8List, width: width, height: height)
          ).image, fit: BoxFit.cover)),
          child: isImage ? const SizedBox() : _blurredBackground(width, height, index, Icon(Icons.play_circle_filled,
                color: index == 3 && _images.length > 4 ? Colors.white54 : Colors.white, size: 120.sp))),
        _deleteWidget(index),
        if (!isImage) _editWidget(index)
      ]);
    } catch (_) {}
    return const SizedBox();
  }

  Widget _blurredBackground(double width, double height, int index, Widget child) => Container(
      width: width, height: height, child: child, color: index == 3 && _images.length > 4 ? Colors.black45 : Colors.transparent);

  Widget _deleteWidget(int index) => Container(
      width: 25,
      height: 25,
      margin: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
      child: ButtonImageCircleWidget(25, () => _deleteImageVideo(index),
          child: const Icon(Icons.close, color: Colors.white, size: 20)));

  Widget _editWidget(int index) => Container(
      width: 25,
      height: 25,
      margin: EdgeInsets.only(top: 100.sp, right: 20.sp),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
      child: ButtonImageCircleWidget(25, () async {
        final directory = await getApplicationDocumentsDirectory();
        final String path = directory.path + '/images/';
        final Directory folder = Directory(path);
        if (!folder.existsSync()) folder.createSync();
        File file = File(path + _images[index].name.split('/').last);
        if (!file.existsSync()) {
          file.createSync();
          file.writeAsBytesSync(_images[index].bytes, flush: true);
        }
        UtilUI.goToNextPage(context, TrimmerView(file, index), funCallback: _editVideoCallback);
      }, child: const Icon(Icons.edit, color: Colors.white, size: 16)));

  bool _isMOV(String url) => url.contains('.mov');

  void _selectImage() {
    clearFocus();
    pass = false;
    checkPermissions(ItemModel(id: languageKey.lblGallery));
  }

  void _deleteImageVideo(int index, {bool render = true}) {
    clearFocus();
    _images.removeAt(index);
    _thumbnail.removeAt(index);
    if (render) bloc!.add(AddImageHomeEvent());
  }

  void _editVideoCallback(dynamic value) {
    if (value != null) {
      _deleteImageVideo(value[1], render: false);
      loadFiles([value[0]]);
    }
  }

  void clickButtonPost() => bloc!.add(CheckProcessPostAutoEvent());

  void _selectAlbum() {
    if (_idAlbum.isNotEmpty) {
      _onClickPost(idAlbum: _idAlbum);
      return;
    }

    bool hasImage = false;
    for (int i = _images.length - 1; i > -1; i--) {
      if (Util.isImage(_images[i].name)) {
        hasImage = true;
        break;
      }
    }
    if (_images.isEmpty || _albums.isEmpty || !hasImage) {
      _onClickPost();
    } else {
      UtilUI.showOptionDialog(context, 'Tải ảnh vào album', _albums, '').then((value) {
        if (value != null) _idAlbum = value.id.toString();
      }).whenComplete(() => _onClickPost(idAlbum: _idAlbum));
    }
  }

  void _onClickPost({String idAlbum = ''}) async {
    clearFocus();
    final String content = _ctrDescription.text.trim();
    if (content.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_alert_input_share_description'))
          .then((value) => _focusDescription.requestFocus());
      return;
    }
    String id = '';
    final post = (widget as PostPage).item;
    if (post != null) id = post.id;
    final List<String> hashTags = Util.createHashTags(content);
    if (hashTags.isEmpty) {
      UtilUI.showCustomDialog(context, MultiLanguage.get('msg_hashtag_empty')).then((value) => _focusDescription.requestFocus());
      return;
    }
    if (await UtilUI().alertVerifyPhone(context)) return;
    bloc!.add(CreatePostHomeEvent([], hashTags, content, '', id,
        realFiles: _images, permission: (widget as PostPage).permission, idAlbum: idAlbum));
    _idAlbum = '';
  }

  void _textChanged(String value) {
    _hideFilter();
    List<String> arr = value.split(RegExp(r'[ \n]'));
    String key = arr[arr.length - 1];
    List<dynamic> filters = _catalogue.where((element) {
      return key.isNotEmpty && !(key == '#') && ('#' + element['name']??'').toLowerCase().contains(key.toLowerCase());
    }).toList();
    if (filters.isNotEmpty) bloc!.add(AddHashTagHomeEvent(filters: filters, key: key));
  }

  void _selectItemFilter(String name, String key) {
    _ctrDescription.text = _ctrDescription.text.replaceFirst(key, '', _ctrDescription.text.length - key.length);
    _ctrDescription.text += '#$name ';
    _ctrDescription.selection = TextSelection.collapsed(offset: _ctrDescription.text.length);
  }

  void _hideFilter() => bloc!.add(AddHashTagHomeEvent(filters: []));

  void _changeIndexCatalogues(int index) {
    //_indexCatalogues = index;
    //bloc!.add(ChangeIndexHomeEvent(index));
    if (!_focusDescription.hasFocus) {
      _ctrDescription.text += ' #'+(_catalogue[index]['name']??'')+' ';
      return;
    }
    int current = _ctrDescription.selection.base.offset;
    String temp = _ctrDescription.text.substring(0, current);
    String temp2 = _ctrDescription.text.substring(current, _ctrDescription.text.length);
    String temp3 = ' #' + (_catalogue[index]['name']??'') + ' ';
    _ctrDescription.text = temp + temp3 + temp2;
    _ctrDescription.selection = TextSelection.collapsed(offset: current + temp3.length);
  }
}
