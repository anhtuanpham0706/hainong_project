import 'dart:io';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/features/function/tool/map_task/map_nutrition_area_page.dart';
import 'package:hainong/features/function/tool/map_task/map_task_bloc.dart';
import 'package:hainong/features/function/tool/map_task/models/map_address_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_menu_model.dart';
import 'package:hainong/features/function/tool/map_task/utils/dialog_utils.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';
import 'package:hainong/features/product/ui/image_item_page.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../suggestion_map/UI/utils/trackasia_map_source.dart';

class MapNutritionInfoUpdatePage extends BasePage {
  MapNutritionInfoUpdatePage({this.point, this.addressMap, Key? key}) : super(pageState: _MapTaskPageState(), key: key);

  final LatLng? point;
  final MapAddressModel? addressMap;
}

class _MapTaskPageState extends PermissionImagePageState with TickerProviderStateMixin {
  TrackasiaMapController? mapController;
  TrackasiaMapSource clusterSource = TrackasiaMapSource();
  StringTagController _stringTagController = StringTagController();
  final tagTreeValueController = StringTagController();
  final TextEditingController _ctrName = TextEditingController();
  final TextEditingController _ctrTreeType = TextEditingController();
  final TextEditingController _ctrAddress = TextEditingController();
  final TextEditingController _ctrRegion = TextEditingController();
  final TextEditingController _ctrFarming = TextEditingController();
  final TextEditingController _ctrLevelPH = TextEditingController();
  final TextEditingController _ctrLevelEC = TextEditingController();
  final FocusNode _focusName = FocusNode();
  final FocusNode _focusCatalogue = FocusNode();
  final FocusNode _focusRegion = FocusNode();
  final FocusNode _focusAddress = FocusNode();
  final FocusNode _focusFarming = FocusNode();
  final FocusNode _focusLevelPH = FocusNode();
  final FocusNode _focusLevelEC = FocusNode();
  final List<MenuItemMap> treeTyleList = [];
  final List<MenuItemMap> farmingTyleList = [];
  final List<MenuItemMap> regionTyleList = [];
  List<MenuItemMap> treeTypeSelects = [];
  MenuItemMap? regionTypeSelect;
  MenuItemMap? farmingTypeSelect;
  late Widget trackAsiaMap;
  bool isShowMapDemoBottomSheet = false;
  bool isAddLayer = false;
  LatLng currentPostion = const LatLng(10.949, 106.798);
  final List<FileByte> _images = [];
  final List<ItemModel> _imageTypes = [];
  List<LatLng> points = [];
  MapAddressModel? _addressMap;
  LatLng? currentPoint;
  late MapNutritionInfoUpdatePage page;

  @override
  void dispose() {
    mapController?.dispose();
    _stringTagController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    page = widget as MapNutritionInfoUpdatePage;
    _initImageTypes();
    trackAsiaMap = trackAsiaMapWidget();
    _stringTagController = StringTagController();
    bloc = MapTaskBloc();
    bloc!.stream.listen((state) async {
      if (state is GetLocationState) {
        _addressMap = state.response;
        _ctrAddress.text = _addressMap?.address_full ?? "";
      } else if (state is CreateQuestionState) {
        if (points.isNotEmpty) {
          bloc?.add(SendDiseasesPositionEvent(state.data.id, points));
        }
        UtilUI.showCustomDialog(context, 'Cảm ơn bạn đã đóng góp dữ liệu.', title: 'Thông báo').whenComplete(() => UtilUI.goBack(context, true));
      } else if (state is LoadImageMapState) {
        setState(() {});
      } else if (state is ShowErrorState) {
        UtilUI.showCustomDialog(context, state.resp);
      }
    });
    treeTyleList.add(MapUtils.menuTreeRiceItem());
    treeTyleList.addAll(MapUtils.menuFruitItem());
    regionTyleList.addAll(MapUtils.regionTreeType());
    farmingTyleList.addAll(MapUtils.farmingTreeType());
    currentPoint = page.point;
    currentPostion = currentPoint!;
    if (page.addressMap != null) {
      _addressMap = page.addressMap;
      _ctrAddress.text = _addressMap?.address_full ?? "";
    } else {
      if (page.point != null) {
        bloc?.add(GetLocationEvent(page.point!));
      }
    }

    super.initState();
  }

  _initImageTypes() {
    _imageTypes.add(ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)));
    _imageTypes.add(ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery)));
  }

  Widget trackAsiaMapWidget() {
    return TrackasiaMap(
        minMaxZoomPreference: const MinMaxZoomPreference(1, 30),
        styleString: constants.styleMap,
        initialCameraPosition: CameraPosition(target: currentPostion, zoom: 4.8),
        trackCameraPosition: true,
        myLocationEnabled: Platform.isIOS ? true : false,
        onMapCreated: _onMapCreated,
        onMapClick: (point, coordinates) {});
  }

  Future<void> _onMapCreated(TrackasiaMapController initialMap) async {
    mapController = initialMap;
    final postion = await MapUtils.getCurrentPositionMap();
    // currentPostion = LatLng(postion.latitude, postion.longitude);
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPostion, 12));
    mapController!.addSymbol(SymbolOptions(geometry: currentPostion, iconImage: "assets/images/ic_location.png", iconSize: 3.0, iconColor: "#C62828", iconHaloColor: "#C62828"));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    super.build(context, color: color);
    final padding = Padding(padding: EdgeInsets.all(20.sp));
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.only(left: 20.sp),
                  child: const Icon(Icons.clear, color: Colors.black87, size: 32),
                )),
            const Text("Thêm thông tin vị trí", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox()
          ]),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.sp),
                          child: const Text("Chi tiết vị trí", style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 82.sp, vertical: 32.sp),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.sp), color: const Color(0xFFF1F8FE)),
                            padding: EdgeInsets.symmetric(horizontal: 64.sp, vertical: 32.sp),
                            child: const Text("Cung cấp chi tiết thông tin tại vị trí của bạn. Nếu thông tin được thêm vào bản đồ hợp lệ, thông tin đó sẽ được công khai",
                                style: TextStyle(color: Colors.black87, fontSize: 13))),
                        padding,
                        UtilUI.createTextField(context, _ctrName, _focusName, _focusCatalogue, 'Tên địa điểm (bắt buộc)*'),
                        padding,
                        TextFieldTags<String>(
                          textfieldTagsController: _stringTagController,
                          initialTags: treeTypeListName(),
                          textSeparators: const [' ', ','],
                          letterCase: LetterCase.normal,
                          inputFieldBuilder: (context, inputFieldValues) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: TextField(
                                onTap: () {
                                  showTreeTypeBottomSheet(inputFieldValues);
                                  // _stringTagController.getFocusNode?.requestFocus();
                                },
                                controller: inputFieldValues.textEditingController,
                                focusNode: inputFieldValues.focusNode,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: StyleCustom.borderTextColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: StyleCustom.borderTextColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: StyleCustom.borderTextColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  hintText: inputFieldValues.tags.isNotEmpty
                                      ? ''
                                      : "Danh sách cây trồng (bắt buộc)*",
                                  hintStyle: TextStyle(color: StyleCustom.textColor6C,fontSize: 40.sp),
                                  errorText: inputFieldValues.error,
                                  // prefixIconConstraints:
                                  // BoxConstraints(maxWidth: _distanceToField * 0.8),
                                  prefixIcon: inputFieldValues.tags.isNotEmpty
                                      ? SingleChildScrollView(
                                    controller: inputFieldValues.tagScrollController,
                                    scrollDirection: Axis.vertical,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                        left: 8,
                                      ),
                                      child: Wrap(
                                          runSpacing: 4.0,
                                          spacing: 4.0,
                                          children:
                                          inputFieldValues.tags.map((String tag) {
                                            return Container(
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0),
                                                ),
                                                color:
                                                Color.fromARGB(255, 74, 137, 92),
                                              ),
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10.0, vertical: 7.0),
                                              child: InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    treeTypeSelects.remove(treeTyleList[treeTyleList.indexWhere((element) => element.name == tag)]);
                                                    inputFieldValues.tags = treeTypeListName();
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '#$tag',
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    InkWell(
                                                      child: const Icon(
                                                        Icons.cancel,
                                                        size: 14.0,
                                                        color: Color.fromARGB(
                                                            255, 233, 233, 233),
                                                      ),
                                                      onTap: () {
                                                        // inputFieldValues
                                                        //     .onTagRemoved(tag);
                                                        // treeTypeSelects.remove(treeTyleList[inputFieldValues.tags.indexWhere((element) => element == tag)]);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList()),
                                    ),
                                  )
                                      : null,
                                ),
                                onChanged: inputFieldValues.onTagChanged,
                                onSubmitted: inputFieldValues.onTagSubmitted,
                              ),
                            );
                          },
                        ),
                        padding,
                        GestureDetector(
                          onTap: () => showTreeRegionBottomSheet(),
                          child: UtilUI.createTextField(context, _ctrRegion, _focusRegion, _focusAddress, 'Vùng trồng (bắt buộc)*',
                              suffixIcon: const Icon(Icons.arrow_drop_down), readOnly: true, enable: false),
                        ),
                        padding,
                        UtilUI.createTextField(context, _ctrAddress, _focusAddress, _focusLevelPH, 'Địa điểm (bắt buộc)*',
                            enable: true,
                            readOnly: true,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                MapUtils.getCurrentPositionMap().then((value) {
                                  final _point = LatLng(value.latitude, value.longitude);
                                  bloc?.add(GetLocationEvent(_point));
                                  mapController?.animateCamera(CameraUpdate.newLatLngZoom(_point, 12));
                                });
                              },
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.black87,
                              ),
                            )),
                        padding,
                        Stack(
                          children: [
                            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(32.sp)), width: 1.sw, height: 360.h, child: trackAsiaMap),
                            Positioned(
                                bottom: 10.sp,
                                left: 10.sp,
                                child: GestureDetector(
                                    onTap: () {
                                      UtilUI.goToNextPage(context, MapNutritionAreaPage(_ctrAddress, points), funCallback: (value) {
                                        points = value;
                                        if (points.isNotEmpty) {
                                          _ctrAddress.text = '${points.first.latitude} - ${points.last.longitude}';
                                          mapController?.animateCamera(CameraUpdate.newLatLngBounds(getLatLngBounds(points), left: 10.0, top: 10.0, right: 10.0, bottom: 10.0));
                                          mapController?.addLine(LineOptions(geometry: points, lineWidth: 3, lineColor: '#0000FF'));
                                          mapController!.addLine(LineOptions(geometry: [points.last, points.first], lineWidth: 3, lineColor: '#0000FF'));
                                        }
                                      });
                                    },
                                    child: SizedBox(width: 400.w, height: 120.h, child: Image.asset('assets/images/v9/map/ic_map_edit_address.png'))))
                          ],
                        ),
                        padding,
                        const Text("Thông tin bổ sung", style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                        padding,
                        Row(children: [
                          Expanded(child: UtilUI.createTextField(context, _ctrLevelPH, _focusLevelPH, _focusLevelEC, 'Độ PH')),
                          SizedBox(width: 40.w),
                          Expanded(child: UtilUI.createTextField(context, _ctrLevelEC, _focusLevelEC, _focusFarming, 'Độ EC'))
                        ]),
                        padding,
                        GestureDetector(
                          onTap: () => showTreeFarmingBottomSheet(),
                          child:
                              UtilUI.createTextField(context, _ctrFarming, _focusFarming, null, 'Phương thức canh tác', suffixIcon: const Icon(Icons.arrow_drop_down), readOnly: true, enable: false),
                        ),
                        padding,
                        const Text("Hình ảnh bổ sung", style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                        const Text("Bổ sung hình ảnh tại khu canh tác, cây trồng tại vị trí của bạn", style: TextStyle(color: Colors.grey, fontSize: 11)),
                        _createImageUI(),
                        padding,
                        GestureDetector(
                            onTap: () {
                              _myClearFocus();
                              if (_images.length < 10) {
                                selectImage(_imageTypes);
                              } else {
                                UtilUI.showCustomDialog(context, 'Chỉ được phép tải lên tối đa 10 ảnh.', title: "Thông báo");
                              }
                            },
                            child: Image.asset("assets/images/v9/map/ic_map_model_add_camera.png", width: 360.w, height: 140.h)),
                        SizedBox(height: 60.h),
                        Container(
                          color: Colors.white.withOpacity(0.8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 72.sp, vertical: 26.sp),
                                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.blue,), borderRadius: BorderRadius.circular(62.sp)),
                                    child: const Text("Hủy bỏ", style: TextStyle(color: Colors.blue, fontSize: 14,fontWeight: FontWeight.w700))),
                              ),
                              GestureDetector(
                                onTap: () => _onUpdate(),
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 72.sp, vertical: 26.sp),
                                    decoration: BoxDecoration(color: Colors.blue, border: Border.all(width: 1, color: Colors.blue), borderRadius: BorderRadius.circular(62.sp)),
                                    child: const Text("Cập nhật", style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.w700))),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //     bottom: 10,
                //     left: 0,
                //     right: 0,
                //     child: Container(
                //       color: Colors.white.withOpacity(0.8),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //         children: [
                //           GestureDetector(
                //             onTap: () => Navigator.of(context).pop(),
                //             child: Container(
                //                 padding: EdgeInsets.symmetric(horizontal: 72.sp, vertical: 26.sp),
                //                 decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.blue), borderRadius: BorderRadius.circular(62.sp)),
                //                 child: const Text("Hủy bỏ", style: TextStyle(color: Colors.blue, fontSize: 14))),
                //           ),
                //           GestureDetector(
                //             onTap: () => _onUpdate(),
                //             child: Container(
                //                 padding: EdgeInsets.symmetric(horizontal: 72.sp, vertical: 26.sp),
                //                 decoration: BoxDecoration(color: Colors.blue, border: Border.all(width: 1, color: Colors.blue), borderRadius: BorderRadius.circular(62.sp)),
                //                 child: const Text("Cập nhật", style: TextStyle(color: Colors.white, fontSize: 14))),
                //           ),
                //         ],
                //       ),
                //     )),
                Loading(bloc)
              ],
            ),
          ),
        ],
      ),
    ));
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double west = points.first.longitude;
    double north = points.first.latitude;
    double east = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  Widget? prefixIconReferrer(InputFieldValues<String> inputFieldValues) {
    return inputFieldValues.tags.isNotEmpty
        ? SingleChildScrollView(
            controller: inputFieldValues.tagScrollController,
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
              child: Wrap(
                  runSpacing: 4.0,
                  spacing: 0,
                  children: inputFieldValues.tags.map((String tag) {
                    return Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        color: Color.fromARGB(255, 74, 137, 92),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [InkWell(child: Text('#$tag', style: const TextStyle(color: Colors.white)))]),
                    );
                  }).toList()),
            ),
          )
        : null;
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

  void _setLatLng(position) {
    currentPoint = position;
    // bloc!.add(GetLocationEvent(_ctrLat.text, _ctrLng.text));
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPoint!, 12));
    bloc?.add(GetLocationEvent(currentPoint!));
  }

  _deleteImage(int index) {
    _images.removeAt(index);
    bloc!.add(LoadImageMapEvent());
  }

  void _myClearFocus() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      bloc!.add(ShowKeyboardEvent(false));
      FocusManager.instance.primaryFocus!.unfocus();
    }
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

  _onUpdate() {
    _myClearFocus();
    if (_ctrName.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên địa điểm').then((value) => _focusName.requestFocus());
      return;
    } else {
      final first = _ctrName.text.substring(0, 1).toUpperCase();
      _ctrName.text = first + _ctrName.text.substring(1, _ctrName.text.length);
    }
    if (treeTypeSelects.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn danh sách cây trồng').then((value) => _focusCatalogue.requestFocus());
      return;
    }
    if (regionTypeSelect == null) {
      UtilUI.showCustomDialog(context, 'Chọn vùng trồng').then((value) => _focusRegion.requestFocus());
      return;
    }
    if (farmingTypeSelect == null) {
      UtilUI.showCustomDialog(context, 'Chọn phương thức canh tác').then((value) => _focusRegion.requestFocus());
      return;
    }
    if (_images.isEmpty) {
      UtilUI.showCustomDialog(context, 'Cung cấp hình ảnh cho sản phẩm').whenComplete(() {
        if (_images.length >= 5) {
          UtilUI.showCustomDialog(context, 'Chỉ được phép tải lên tối đa 5 ảnh.', title: "Thông báo");
          return;
        }
        if (MapUtils.calculateTotalBytes(_images) >= 100 * 1024 * 1024) // 100MB = 10 * 1024 * 1024 bytes
        {
          UtilUI.showCustomDialog(context, 'Dung lượng ảnh tải lên vượt quá 100MB.', title: "Thông báo");
          return;
        }
        selectImage(_imageTypes);
      });
      return;
    }
    bloc!.add(SendContributeEvent(_addressMap!, currentPoint!, _ctrName.text, treeTypeListName(), regionTypeSelect?.name, _ctrLevelPH.text, _ctrLevelEC.text, farmingTypeSelect?.value, _images));
  }

  void showTreeTypeBottomSheet(InputFieldValues<String> inputFieldValues) {
    _myClearFocus();
    DialogUtils.showBottomSheetPopup(context, treeTypeListWidget("Danh sách cây trồng", inputFieldValues));
  }

  void showTreeRegionBottomSheet() {
    _myClearFocus();
    DialogUtils.showBottomSheetPopup(context, treeRegionListWidget("Danh sách vùng trồng"));
  }

  void showTreeFarmingBottomSheet() {
    _myClearFocus();
    DialogUtils.showBottomSheetPopup(context, treeFarmingListWidget("Phương thức canh tác"), height: 0.26.sh);
  }

  void callBackPress() {}

  Widget treeTypeListWidget(String title, InputFieldValues<String> inputFieldValues) {
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
            itemCount: treeTyleList.length,
            itemBuilder: (BuildContext context, int index) {
              final isSelect = treeTypeSelects.contains(treeTyleList[index]);
              return GestureDetector(
                onTap: () {
                  if (inputFieldValues.tags.length <= 3) {
                    setState(() {
                      if (isSelect) {
                        treeTypeSelects.remove(treeTyleList[index]);
                      } else {
                        if (inputFieldValues.tags.length < 3) {
                          treeTypeSelects.add(treeTyleList[index]);
                        }
                      }
                      inputFieldValues.tags = treeTypeListName();
                    });
                  }
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
                          child: Text(treeTyleList[index].name, style: TextStyle(fontSize: 18, color: isSelect ? Colors.white : Colors.black87)),
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

  Widget treeRegionListWidget(String title) {
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
            itemCount: regionTyleList.length,
            itemBuilder: (BuildContext context, int index) {
              final isSelect = regionTypeSelect?.id == regionTyleList[index].id;
              return GestureDetector(
                onTap: () {
                  regionTypeSelect = regionTyleList[index];
                  _ctrRegion.text = regionTypeSelect!.name;
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
                          child: Text(regionTyleList[index].name, style: TextStyle(fontSize: 18, color: isSelect ? Colors.white : Colors.black87)),
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

  Widget treeFarmingListWidget(String title) {
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
            itemCount: farmingTyleList.length,
            itemBuilder: (BuildContext context, int index) {
              final isSelect = farmingTypeSelect?.id == farmingTyleList[index].id;
              return GestureDetector(
                onTap: () {
                  farmingTypeSelect = farmingTyleList[index];
                  _ctrFarming.text = farmingTypeSelect!.name;
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
                          child: Text(farmingTyleList[index].name, style: TextStyle(fontSize: 18, color: isSelect ? Colors.white : Colors.black87)),
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

  List<String> treeTypeListName() {
    List<String> list = [];
    final trees = treeTypeSelects.map((e) => e.name).toList();
    list.addAll(trees);
    return list;
  }

  bool isHasTrees() => treeTypeListName().isNotEmpty;
}
