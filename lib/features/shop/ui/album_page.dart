import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/features/profile/ui/show_avatar_page.dart';
import '../album_model.dart';
import '../bloc/album_bloc.dart';
import '../bloc/shop_bloc.dart';

class AlbumPage extends BasePage {
  final int album_id;
  final bool is_user;
  final String title;
  final List<AlbumModel> listAlbum;
  final Function reloadAlbum;
  AlbumPage(this.listAlbum,this.reloadAlbum,{this.album_id = 0,this.is_user = false,this.title = "Danh sách ảnh",Key? key}):super(key: key, pageState: _AlbumState());
}

class _AlbumState extends PermissionImagePageState {
  List<ItemModel> _listImage = [];
  final List<FileByte> _images = [];
  final List<ItemModel> _imageTypes = [];
  List<AlbumModel> _listAlbum = [];
  bool isReload = false;
  int _page = 1;
  final ScrollController _scroller = ScrollController();

  @override
  void dispose() {
    (widget as AlbumPage).reloadAlbum(true);
    _images.clear();
    _listImage.clear();
    _scroller.dispose();
    _imageTypes.clear();
    super.dispose();
  }

  @override
  void initState() {
    _initImageTypes();
    _fillterAlbum((widget as AlbumPage).listAlbum);
    bloc = AlbumBloc(AlbumState());
    bloc!.stream.listen((state) {
      if(state is LoadListImageAlbumState && isResponseNotError(state.response)){
        _handleLoadList(state.response.data);
      } else if(state is RemoveImageAlbumState) {
        if(state.response.success){
          UtilUI.showCustomDialog(context, 'Xóa ảnh thành công',title: "Thông báo").then((value)  {
            if(value != null && value){
              _loadNew();
            }
          });
        } else {
          UtilUI.showCustomDialog(context, 'Xóa ảnh không thành công',title: "Thông báo");
        }
      } else if(state is UpdateNameAlbumState && isResponseNotError(state.response,passString: true)){
        Navigator.of(context).pop(true);
      } else if(state is MoveImageAlbumState && isResponseNotError(state.response,passString: true)){
        Navigator.of(context).pop(true);
      } else if(state is AddImageAlbumState) {
        if(state.response.success){
          UtilUI.showCustomDialog(context, 'Thêm ảnh thành công',title: "Thông báo").then((value)  {
            if(value != null && value){
              _loadNew();
            }
          });
        } else {
          UtilUI.showCustomDialog(context, 'Thêm ảnh không thành công',title: "Thông báo");
        }
      } else if(state is RemoveAlbumState) {
        if(state.response.success){
          UtilUI.showCustomDialog(context, 'Xóa album thành công',title: "Thông báo").then((value)  {
            if(value != null && value){
              Navigator.of(context).pop(true);
            }
          });
        } else {
          UtilUI.showCustomDialog(context, 'Xóa album không thành công',title: "Thông báo");
        }
      }
    });
    _loadMore();
    super.initState();
    _scroller.addListener(_listenerScroll);
  }

  _initImageTypes() {
    setOnlyImage();
    _imageTypes.add(ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery)));
  }
  void _fillterAlbum(List<AlbumModel> list) {
    if(list != []){
      for(int i = 0; i < list.length; i++){
        if(list[i].id != (widget as AlbumPage).album_id){
          _listAlbum.add(list[i]);
        }
      }
    }
  }
  void _removeImage(String id){
    UtilUI.showCustomDialog(context, 'Bạn có chắc xóa ảnh đã chọn?', isActionCancel: true,title: "Thông báo")
        .then((value) {
      if (value != null && value) bloc!.add(RemoveImageAlbumEvent((widget as AlbumPage).album_id.toString(), id));
    });
  }

  _uploadImage() {
    multiSelect = true;
    selectImage(_imageTypes);
  }

  void _listenerScroll() {
    if (_page > 0 && _scroller.position.pixels == _scroller.position.maxScrollExtent) _loadMore();
  }
  void _loadMore() {
    if (_page > 0) bloc!.add(LoadListImageAlbumEvent((widget as AlbumPage).album_id, _page));
  }
  void _loadNew() {
    _listImage.clear();
    _page = 1;
    bloc!.add(LoadListImageAlbumEvent((widget as AlbumPage).album_id, _page));
  }
  void _handleLoadList(ItemListModel data) {
    if (data.list.isNotEmpty) {
      _listImage.addAll(data.list);
      data.list.length == constants.limitPage*2 ? _page++ : _page = 0;
    } else _page = 0;
  }
  _selectOptionAlbum(BuildContext context) async {
    final List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_add.png', ' Thêm ảnh', () {
      Navigator.of(context).pop();
      _uploadImage();
    }, false));
    options.add(ItemOption('assets/images/ic_read_all.png', ' Đổi tên album', () {
      Navigator.of(context).pop();
      _showDialogAddAlbum((widget as AlbumPage).title);
    }, false));
    options.add(ItemOption('assets/images/ic_delete_outline.png', ' Xóa album', () {
      Navigator.of(context).pop();
      UtilUI.showCustomDialog(context, 'Bạn có chắc xóa album ?', isActionCancel: true,title: "Thông báo")
          .then((value) {
        if (value != null && value) bloc!.add(RemoveAlbumEvent((widget as AlbumPage).album_id.toString()));
      });
    }, false));
    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
  }
  void _showDialogAddAlbum(String title) {
    clearFocus();
    UtilUI.showConfirmDialog(
      context,
      "Nhập tên mới",
      title, "Tên album không thể để trắng",
      title: "Đổi tên album",
      inputType: TextInputType.text,)
        .then((value) {
      if (value is String) {
        bloc!.add(UpdateNameAlbumEvent((widget as AlbumPage).album_id.toString(), value));
      }
    });
  }

  _selectOptionImage(BuildContext context,String id) async {
    final List<ItemOption> options = [];
    options.add(ItemOption('assets/images/ic_location.png', ' Di chuyển', () {
      Navigator.of(context).pop();
      showOptionAlbum(
          context,
          "Chọn album di chuyển đến",
          _listAlbum,
          '0')
          .then((value) {
        if (value != null) bloc!.add(MoveImageAlbumEvent((widget as AlbumPage).album_id.toString(),value.toString(),id));
      });
    }, false));
    options.add(ItemOption('assets/images/ic_delete_outline.png', ' Xóa ảnh', () {
      Navigator.of(context).pop();
      _removeImage(id);
    }, false));
    UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), options);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleCustom.primaryColor,
        title: Text((widget as AlbumPage).title,
          style: TextStyle(color: Colors.white, fontSize: 50.sp),),
          actions: (widget as AlbumPage).is_user ? [IconButton(onPressed: () {
            _selectOptionAlbum(context);
          }, icon: Image.asset('assets/images/ic_menu.png',
            width: 60.sp,height: 60.sp,color: Colors.white,))] : []
      ),
      body: GestureDetector(
          onVerticalDragDown: (details) {clearFocus();},
          onTapUp: (value) {clearFocus();},
          child: Stack(children: [
            Column(
              children: [
                Expanded(
                  child: BlocBuilder(bloc: bloc,
                      buildWhen: (oldState, newState) => newState is LoadListImageAlbumState,
                      builder: (context, state) =>  AlignedGridView.count(
                          padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 0.sp), controller: _scroller,
                          crossAxisCount: 3, mainAxisSpacing: 8.sp, crossAxisSpacing: 8.sp, itemCount: _listImage.length,
                          itemBuilder: (BuildContext context, int index) => _listImage.isEmpty ? const SizedBox() :
                          InkWell(
                            onLongPress: () {
                              if((widget as AlbumPage).is_user){
                                _selectOptionImage(context,_listImage[index].id);
                              }
                            },
                            onTap: () {
                              goToSubPage(ShowAvatarPage(_listImage[index].name));
                            },
                            child: Container(
                              width: 0.32.sw,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10.sp))
                              ),
                              margin: EdgeInsets.fromLTRB(10.sp, 10.sp, 10.sp, 10.sp),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10.sp),
                                    child: Container(
                                        height: 0.32.sw,
                                        width:  0.32.sw,
                                        alignment: Alignment.topRight,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.sp),
                                            image: DecorationImage(
                                                image: _listImage[index].name.isNotEmpty
                                                    ? FadeInImage.assetNetwork(
                                                    image: _listImage[index].name,
                                                    placeholder: 'assets/images/ic_default.png')
                                                    .image
                                                    : Image.asset('assets/images/ic_default.png').image,
                                                fit: BoxFit.cover)),
                                        child: const SizedBox()
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      )),
                )
              ],
            ),
            Loading(bloc)
          ]))
    );
  }


  Future showOptionAlbum(BuildContext context, String title,
      List<AlbumModel> values, String id, {bool hasTitle = true}) {
    return showDialog(context: context, barrierDismissible: true,
        builder: (context) => Align(alignment: Alignment.center,
            child: Container(width: 0.8.sw,
                height: 150.sp * values.length + (hasTitle?120.sp:0),
                margin: EdgeInsets.only(top: 300.sp, bottom: 80.sp),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(30.sp)),
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min,
                        children: createItems(context, title, values, id, hasTitle: hasTitle))))));
  }

  List<Widget> createItems(BuildContext context, String title,
      List<AlbumModel> values, String id, {bool hasTitle = true}) {
    final line = Container(color: Colors.grey.shade300, height: 2.sp);
    List<Widget> list = [];
    if (hasTitle) {list.add(SizedBox(height: 120.sp, child: Center(
        child: LabelCustom(title, color: Colors.black87))));}
    for (var i = 0; i < values.length; i++) {
      list.add(line);
      list.add(OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.zero),
          onPressed: () => Navigator.of(context).pop(values[i].id),
          child: Container(color: id != values[i].id.toString() ? Colors.transparent : StyleCustom.buttonColor,
              width: 1.sw, height: 148.sp, alignment: Alignment.center,
              child: LabelCustom(values[i].name,
                  color: id != values[i].id.toString() ? StyleCustom.primaryColor : Colors.white))));
    }
    return list;
  }

  @override
  void loadFiles(List<File> files) {
    if (files.isEmpty) return;
    bool hasFile = false;
    for(int i = 0; i < files.length; i++) {
      if (Util.isImage(files[i].path)) {
        hasFile = true;
        _images.add(FileByte(files[i].readAsBytesSync(), files[i].path));
      }
    }
    if(hasFile) bloc!.add(AddImageAlbumEvent(_images,(widget as AlbumPage).album_id.toString()));
  }

}