import 'dart:io';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/features/function/tool/map_task/map_task_bloc.dart';
import 'package:hainong/features/function/tool/map_task/models/map_address_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_data_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_model.dart';
import 'package:hainong/features/function/tool/map_task/utils/dialog_utils.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import 'package:hainong/features/product/ui/image_item_page.dart';
import 'package:trackasia_gl/mapbox_gl.dart';

class PopupPetContributeWidget extends BasePage {
  final MapDataModel data;
  final String? treeName;
  final String? petName;
  final LatLng point;

  PopupPetContributeWidget(this.data,this.treeName, this.petName, this.point, {Key? key}) : super(key: key, pageState: _PopupPetContributeWidgetState());
}

class _PopupPetContributeWidgetState extends PermissionImagePageState {
  final TextEditingController _ctrName = TextEditingController();
  final TextEditingController _ctrProblem = TextEditingController();
  final TextEditingController _ctrNote = TextEditingController();
  final FocusNode _focusName = FocusNode();
  final FocusNode _focusProblem = FocusNode();
  final FocusNode _focusNote = FocusNode();
  MapAddressModel? _addressData;
  final List<FileByte> _images = [];
  final List<ItemModel> _imageTypes = [];
  List<PetModel> catalogues = [];
  String catalogueSelect = "";
  bool _showKeyboard = false;
  ItemModel? regionSelect;
  late PopupPetContributeWidget page;

  @override
  void initState() {
    super.initState();
    bloc = MapTaskBloc();
    bloc?.stream.listen((state) async {
      if (state is GetLocationState) {
        setState(() => _addressData = state.response);
      } else if (state is PostImageMapState) {
        if(state.response.success) {
          _showDialogCreatePestContributeSuccess();
        } else {
          UtilUI.showCustomDialog(context, state.response.data.toString(),
              title: "Thông báo");
        }
      } else if (state is LoadCategorysState) {
        catalogues = state.list;
        for (PetModel item in catalogues) {
          if (item.name == page.petName) {
            catalogueSelect = item.name;
            _ctrProblem.text = catalogueSelect;
          }
        }
      } else if (state is ShowKeyboardState) {
        _showKeyboard = state.value;
        if (!_showKeyboard) clearFocus();
      } else if (state is LoadImageMapState) {
        setState(() {});
      }
    });
    page = widget as PopupPetContributeWidget;
    bloc?.add(GetLocationEvent(page.point));
    // bloc?.add(LoadCategorysEvent(name: page.treeName ?? "Lúa"));
    _ctrProblem.text = page.petName ?? "";
    _initImageTypes();
    _ctrName.text = page.treeName ?? "";
  }

  _initImageTypes() {
    _imageTypes.add(ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery)));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    super.build(context, color: color);
    final padding = Padding(padding: EdgeInsets.all(20.sp));
    return SizedBox(
        height: 1.sh / 1.6,
        width: 1.sw,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 80.h,bottom: 60.sp),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 20.sp),
                      child: Column(
                        children: [
                          padding,
                          if (_images.isNotEmpty) _createImageUI(),
                          padding,
                          imageSelectWidget(),
                          padding,
                          UtilUI.createTextField(context, _ctrName, _focusName, _focusProblem, 'Tên cây trồng (bắt buộc)*', enable: false),
                          padding,
                          // GestureDetector(
                          //   onTap: () => _selectOption("Danh sách loại bệnh", catalogues, catalogueSelect),
                          //   child: UtilUI.createTextField(context, _ctrProblem, _focusProblem, _focusNote, 'Vấn đề gặp phải (bắt buộc)*', enable: false, suffixIcon: const Icon(Icons.arrow_drop_down)),
                          // ),
                          UtilUI.createTextField(context, _ctrProblem, _focusProblem, _focusNote, 'Vấn đề gặp phải (bắt buộc)*', enable: false, suffixIcon: const Icon(Icons.arrow_drop_down)),
                          padding,
                          UtilUI.createTextField(context, _ctrNote, _focusNote, null, 'Nội dung đóng góp',
                              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp), inputType: TextInputType.multiline, maxLines: 6),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
                width: 1.sw,
                height: 120.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(32.sp), topRight: Radius.circular(32.sp)), color: const Color(0xFF0D986F)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: Icon(Icons.clear, size: 32, color: Colors.white),
                    ),
                  ),
                  const Text("Đóng góp sâu bệnh", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox()
                ])),
            Positioned(
              bottom: 10,
              left: 60,
              right: 60,
              child: GestureDetector(
                onTap: () => createPetContribution(),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(64.sp), color: Colors.green),
                  padding: EdgeInsets.symmetric(horizontal: 64.sp, vertical: 32.sp),
                  child: const Text("Nhấn để đóng góp", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Loading(bloc)
          ],
        ));
  }

  Widget imageSelectWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () {
              if (_images.length >= 5) {
                UtilUI.showCustomDialog(context, 'Chỉ được phép tải lên tối đa 5 ảnh.', title: "Thông báo");
                return;
              }
              if (MapUtils.calculateTotalBytes(_images) >= 100 * 1024 * 1024) // 100MB = 10 * 1024 * 1024 bytes
              {
                UtilUI.showCustomDialog(context, 'Dung lượng ảnh tải lên vượt quá 10MB.', title: "Thông báo");
                return;
              }
              selectImage(_imageTypes);
            },
            child: Image.asset("assets/images/v9/map/ic_map_add_image.png", width: 180.w, height: 180.w)),
        SizedBox(width: 20.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(MapUtils.getCurrentTimeFormatted(), style: TextStyle(color: Colors.red, fontSize: 12)),
              Text(_addressData?.address_full ?? "Không có thông tin địa chỉ", style: TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }

  void createPetContribution() {
    if (_images.isEmpty) {
      UtilUI.showCustomDialog(context, 'Cung cấp hình ảnh cho sản phẩm').whenComplete(() => selectImage(_imageTypes));
      return;
    }
    if (_addressData == null) {
      UtilUI.showCustomDialog(context, 'Không có địa chỉ').whenComplete(() => selectImage(_imageTypes));
      return;
    }
    bloc?.add(PostImageMapEvent(page.data.classable_id, _ctrNote.text, page.data.classable_type,_images));
  //   bloc?.add(CreateDiagnostisPestEvent(
  //       page.point, _addressData!.provinceId.toString(), _addressData!.districtId.toString(), _addressData?.address_full ?? "", _ctrName.text, _ctrProblem.text, _ctrNote.text, _images));
  }

  void selectImage(List<ItemModel> list, {String? title}) {
    UtilUI.showOptionDialog(context, MultiLanguage.get(title ?? 'msg_select_image_from'), list, title ?? '').then((value) {
      checkPermissions(value);
    });
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
                itemBuilder: (context, index) => SizedBox(width: 242.w, height: 242.w, child: ImageItemProduct(File(_images[index].name), () => _deleteImage(index))),
              )
            : const SizedBox();
      });

  _deleteImage(int index) {
    _images.removeAt(index);
    bloc!.add(LoadImageMapEvent());
  }

  @override
  loadFiles(List<File> files) {
    if (files.isEmpty) return;
    try {
      showLoadingPermission();
      bool hasFile = false;
      for (int i = 0; i < files.length; i++) {
        if (Util.isImage(files[i].path) && _images.length <= 5) {
          hasFile = true;
          _images.add(FileByte(files[i].readAsBytesSync(), files[i].path));
        }
      }
      if (hasFile) {
        bloc!.add(LoadImageMapEvent());
      } else {
        showLoadingPermission(value: false);
      }
    } catch (e) {
      print(e);
    }
  }

  void clearFocus() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      bloc!.add(ShowKeyboardEvent(false));
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void _showDialogCreatePestContributeSuccess() {
    clearFocus();
    UtilUI.showCustomDialog(
      context,
      MultiLanguage.get('msg_thank_feedback_pets'),
      title: MultiLanguage.get('lbl_success'),
    ).then((value) {
      Navigator.of(context).pop();
    });
  }

  _selectOption(String title, List<PetModel> list, String selectId) {
    if (list.isNotEmpty) {
      DialogUtils.showBottomSheetPopup(context, petListWidget(title));
    }
  }

  Widget petListWidget(String title) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 100.h,
          width: 1.sw,
          color: const Color(0xFF0E986F),
          padding: EdgeInsets.symmetric(vertical: 20.sp),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white)),
        ),
        SizedBox(height: 20.sp),
        Expanded(
          child: ListView.builder(
            itemCount: catalogues.length,
            itemBuilder: (BuildContext context, int index) {
              final isSelect = catalogueSelect == catalogues[index].name;
              return GestureDetector(
                onTap: () {
                  catalogueSelect = catalogues[index].name;
                  _ctrProblem.text = catalogueSelect;
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    Container(
                      width: 1.sw,
                      color: isSelect ? const Color(0xFFFFAC26) : Colors.transparent,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 36.sp),
                          child: Text(catalogues[index].name, style: TextStyle(fontSize: 18, color: isSelect ? Colors.white : Colors.black87)),
                        ),
                      ]),
                    ),
                    const Divider(color: Colors.grey, height: 2, thickness: 0)
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
