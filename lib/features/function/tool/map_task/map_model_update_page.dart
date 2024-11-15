import 'dart:async';
import 'dart:io';

import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/features/function/tool/map_task/components/image_item_widget.dart';
import 'package:hainong/features/function/tool/map_task/map_task_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/product/ui/image_item_page.dart';
import 'package:photo_manager/photo_manager.dart';

class MapModelUpdatePage extends BasePage {
  MapModelUpdatePage(this.id,this.type,{this.title,this.isRating = false, Key? key})
      : super(pageState: _MapModelUpdatePageState(), key: key);
  final bool isRating;
  final String? title;
  final String? type;
  final int id;
}

class _MapModelUpdatePageState extends PermissionImagePageState {
  final TextEditingController _ctrDes = TextEditingController();
  final FocusNode _focusDes = FocusNode();
  final List<FileByte> _images = [];
  final List<ItemModel> _imageTypes = [];
  Map<String, String> _temp = {};
  List<AssetEntity> _entities = [AssetEntity(id: '',typeInt: 0,width: 0,height: 0)];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = false;
  bool _canSubmit = false;
  AssetPathEntity? _path;
  int _totalEntitiesCount = 0;
  final int _sizePerPage = 40;
  int _page = 0;
  int _star = 0;

  @override
  void initState() {
    bloc = MapTaskBloc();
    _initImageTypes();
    _requestImageAssets();
    bloc!.stream.listen((state) {
      if(state is PostRatingState){
        if(state.response.success){
          UtilUI.showCustomDialog(context, 'Gửi đánh giá thành công',
              title: "Thông báo").then((value) {
            UtilUI.goBack(context, {
              'rate': _star.toDouble(),
              'comment': _ctrDes.text
            });
          });
        } else {
          UtilUI.showCustomDialog(context, state.response.data.toString(),
              title: "Thông báo");
        }
      } else if(state is PostImageMapState){
        if(state.response.success){
          UtilUI.showCustomDialog(context, 'Gửi đóng góp thành công',
              title: "Thông báo").then((value) {
            UtilUI.goBack(context, true);
          });
        } else {
          UtilUI.showCustomDialog(context, state.response.data.toString(),
              title: "Thông báo");
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _ctrDes.dispose();
    _imageTypes.clear();
    super.dispose();
  }

  _initImageTypes() {
    _imageTypes
        .add(ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(
        ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery)));
  }

  void _updateCanSubmit() {
    if(_images.isNotEmpty && _ctrDes.text.isNotEmpty){
      _canSubmit = true;
    } else {
      _canSubmit = false;
    }
    setState(() {
    });
  }

  void _submit() {
    if (_ctrDes.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Mô tả không được để trống.',
          title: "Thông báo");
      return;
    }
    if((widget as MapModelUpdatePage).isRating) {
      bloc?.add(PostRatingEvent((widget as MapModelUpdatePage).id, _images, _ctrDes.text, _star, (widget as MapModelUpdatePage).type!));
    } else {
      bloc?.add(PostImageMapEvent((widget as MapModelUpdatePage).id, _ctrDes.text, (widget as MapModelUpdatePage).type!,_images));
    }
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    super.build(context, color: color);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        // centerTitle: true,
        title: UtilUI.createLabel((widget as MapModelUpdatePage).title),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp,vertical: 40.sp),
            child: InkWell(
              onTap: _submit,
                child: LabelCustom("Đăng",color: _canSubmit ? Colors.white : Colors.white10,size: 50.sp,)),
          )
        ],
      ),
      body: GestureDetector(
        onVerticalDragDown: (details) {
          _focusDes.unfocus();},
        onTapDown: (value) {_focusDes.unfocus();},
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.sp, vertical: 20.sp),
              child: Column(children: [
                Visibility(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 25.sp),
                    child: UtilUI.createStars(mainAxisAlignment: MainAxisAlignment.center, onClick: (index)  {
                  setState(() {
                    _star = index;
                  });
                    }, hasFunction: true, rate: _star, size: 100.sp),
                  ),
                  visible: (widget as MapModelUpdatePage).isRating,
                ),
                _createImageUI(),
                const Text("Dung lượng tổng <=100mb \n Yêu cầu tối thiểu 1 hình ảnh", style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 20.h),
                TextFieldCustom(
                    _ctrDes, _focusDes, null, "Viết mô tả về hình ảnh mà bạn chuẩn bị cập nhật",
                    maxLine: 3,
                    padding: EdgeInsets.all(40.sp),
                    type: TextInputType.multiline,
                    inputAction: TextInputAction.newline,
                onChanged: (control, value) {
                      if(value !=  null && value.toString().isNotEmpty){
                        _updateCanSubmit();
                      }
                }),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.sp),
                  child: _imageGalleryList(),
                ))
              ]),
            ),
            Loading(bloc)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: StyleCustom.primaryColor,
        onPressed: _requestImageAssets,
        child: const Icon(Icons.refresh),
      ),
    );
  }


  Widget _createImageUI() => BlocBuilder(
      bloc: bloc,
      buildWhen: (oldState, newState) => newState is LoadImageMapState,
      builder: (context, state) {
        return _images.isNotEmpty
            ? AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
                itemCount: _images.length,
                itemBuilder: (context, index) => SizedBox(
                    width: 242.w,
                    height: 242.w,
                    child: ImageItemProduct(File(_images[index].name), () => _deleteImage(index))),
              )
            : SizedBox(
                width: 0.46.sw,
                height: 0.46.sw,
                child: Stack(
                  children: [
                    Image.asset("assets/images/v9/map/ic_image_upload.png"),
                  ],
                ));
      });

  _deleteImage(int index) {
    _temp.remove(_images[index].name);
    _images.removeAt(index);
    bloc!.add(LoadImageMapEvent());
    _updateCanSubmit();
  }

  @override
  loadFiles(List<File> files) {
    if (files.isEmpty) return;
    showLoadingPermission();
    bool hasFile = false;
    for (int i = 0; i < files.length; i++) {
      if (Util.isImage(files[i].path) && _images.length <= 5) {
        hasFile = true;
        _images.add(FileByte(files[i].readAsBytesSync(), files[i].path));
      }
    }
    if (hasFile)
      bloc!.add(LoadImageMapEvent());
    else
      showLoadingPermission(value: false);
  }


  Widget _imageGalleryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_path == null) {
      return const Center(child: Text('Request paths first.'));
    }
    if (_entities.isNotEmpty != true) {
      return const Center(child: Text('Không có tệp hình ảnh trong thiết bị.'));
    }
    return GridView.custom(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == _entities.length - 2 && !_isLoadingMore && _hasMoreToLoad) {
            _loadMoreAsset();
          }
          final AssetEntity entity = _entities[index];
          if(index == 0) {
            return GestureDetector(
              onTap: (){
                _getImagesFromCamera();
              },
              child: Container(
                margin: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40.sp,
                    ),
                    const Icon(Icons.camera_alt_outlined),
                    const Text('Camera'),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87,width: 0.2)
                ),
              ),
            );
          }
          return  Padding(
              padding: const EdgeInsets.all(4.0),
              child: ImageItemWidget(
                onTap: (item) {
                  item.file.then((value) {
                    if (value != null) {
                      if (_images.length >= 5) {
                        UtilUI.showCustomDialog(context, 'Chỉ được phép tải lên tối đa 5 ảnh.',
                            title: "Thông báo");
                        return;
                      }
                      if (MapUtils.calculateTotalBytes(_images) >=
                          100 * 1024 * 1024) // 100MB = 10 * 1024 * 1024 bytes
                      {
                        UtilUI.showCustomDialog(context, 'Dung lượng ảnh tải lên vượt quá 100MB.',
                            title: "Thông báo");
                        return;
                      }
                      if(!_temp.containsKey(value.path)){
                        _temp.addAll({value.path : ""});
                        _images.add(FileByte(value.readAsBytesSync().toList(), value.path));
                        bloc!.add(LoadImageMapEvent());
                        _updateCanSubmit();
                      } else {
                        return;
                      }
                    }
                  });
                },
                key: ValueKey<int>(index),
                entity: entity,
                option: const ThumbnailOption(size: ThumbnailSize.square(200)),
              ));
        },
        childCount: _entities.length,
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<int>) {
            return key.value;
          }
          return null;
        },
      ),
    );
  }

  void _getImagesFromCamera() {
    checkPermissions(ItemModel(
        id: languageKey.lblCamera,
        name: MultiLanguage.get(languageKey.lblCamera)));
  }

  Future<void> _requestImageAssets() async {
    setState(() {
      _isLoading = true;
    });
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    if (!ps.isAuth) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
    );
    if (!mounted) {
      return;
    }
    if (paths.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _path = paths.first;
    });
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    _entities.clear();
    setState(() {
      entities.forEach((element) {
        if(element.type == AssetType.image) {
          _entities.add(element);
        }
      });
      _isLoading = false;
      _hasMoreToLoad = entities.length == _sizePerPage;
      print(_hasMoreToLoad.toString() + "&"  + _isLoading.toString());
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      for (var element in entities) {
        if(element.type == AssetType.image) {
          _entities.add(element);
        }
      }
      _page++;
      _hasMoreToLoad = entities.length == _sizePerPage;
      _isLoadingMore = false;
    });
  }
}
