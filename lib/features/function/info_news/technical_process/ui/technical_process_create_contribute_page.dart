import 'dart:io';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/function/info_news/market_price/market_price_bloc.dart';
import '../technical_process_bloc.dart';
import '../technical_process_model.dart';

class TPCreateContributePage extends BasePage{
  final TechnicalProcessModel? detail;
  final bool isReview;
  final Function? funReload;
  TPCreateContributePage({this.detail, this.isReview = false, this.funReload, Key? key}) : super(key: key,pageState: _TPCreateContributePage());
}

class _TPCreateContributePage extends PermissionImagePageState{
  // MultiChoice? _choice;
  final _ctrContent = TextEditingController();
  final _ctrTitle = TextEditingController();
  // final _ctrTag = TextEditingController();
  final _ctrStatus = TextEditingController();
  final _ctrTypeProcess = TextEditingController();
  final FocusNode _fcTitle = FocusNode();
  final FocusNode _fcContent= FocusNode();
  // final FocusNode _fcTag= FocusNode();
  final FocusNode _fcStatus = FocusNode();
  final FocusNode _fcTypeProcess = FocusNode();
  //ItemModel _status =  ItemModel();
  TechProCatModel _typeProcess =  TechProCatModel();
  File? _image;
  final List<TechProCatModel> _typesProcess = [];
  final List<ItemModel> _statuses = [
    ItemModel(id: 'disable', name: 'Tạm ẩn'),
    ItemModel(id: 'pending', name: 'Chờ duyệt')
  ];

  @override
  void initState() {
       // _choice = MultiChoice(this, MultiChoice.hashTag);
       bloc = TechnicalProcessBloc();
       bloc!.stream.listen((state) {
         if(state is CreateContributeTPState && isResponseNotError(state.response,passString: true) ){
           UtilUI.showCustomDialog(context, 'Cảm ơn bạn! Đóng góp về các quy trình kỹ thuật sẽ được gởi đến admin',title: 'Thông báo').then(
                   (value) => UtilUI.goBack(context, false));
         }
         else if (state is LoadCatalogueState ) {
           _typesProcess.addAll(state.response.map((e) => TechProCatModel().fromJson(e)).toList());
         }
         else if (state is UpdateStatusState && isResponseNotError(state.resp, passString: true)) {
           (widget as TPCreateContributePage).funReload!();
           String temp = 'Đã chấp nhận đóng góp thành công';
           if (state.status == '0') temp = 'Đã từ chối đóng góp thành công';
           UtilUI.showCustomDialog(context, temp, title: MultiLanguage.get('ttl_alert'))
               .whenComplete(() => UtilUI.goBack(context, false));
         }
       });
    super.initState();
    setOnlyImage();
    final detail = (widget as TPCreateContributePage).detail;
    if (detail != null) {
      _ctrTitle.text = detail.title;
      _ctrContent.text = detail.content;
      _ctrTypeProcess.text = detail.catalogue_name;
    } else bloc!.add(LoadCatalogueEvent(isParent: true, keyName: 'fullname'));
  }
  @override
  void dispose() {
    // _ctrTag.dispose();
    _ctrTitle.dispose();
    _ctrContent.dispose();
    _ctrStatus.dispose();
    _ctrTypeProcess.dispose();
    _fcTitle.dispose();
    _fcContent.dispose();
    // _fcTag.dispose();
    _fcStatus.dispose();
    _fcTypeProcess.dispose();
    // _choice?.clear();
    _statuses.clear();
    _typesProcess.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final page = widget as TPCreateContributePage;
    final list = ListView(padding: EdgeInsets.zero,
        children: [
          _title('Tiêu đề'),
          UtilUI.createTextField(context,
              _ctrTitle,
              _fcTitle,
              null, 'Nhập tiêu đề',
              readOnly: page.isReview,
              padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 20.sp), maxLength: 200,
              inputAction: TextInputAction.newline, inputType: TextInputType.multiline, maxLines: null),
          _title('Nội dung'),
          TextFieldCustom(
              _ctrContent,
              _fcContent,
              null, 'Nhập nội dung',
              readOnly: page.isReview,
              inputAction: TextInputAction.newline, type: TextInputType.multiline, maxLength: 500,
              maxLine: 0, padding: EdgeInsets.all(30.sp)),
          //SizedBox(height: 40.sp),
          // TextFieldCustom(_ctrTag, _fcTag, null, 'Nhập từ khoá nổi bật',
          //     suffix: const Icon(Icons.add, color: StyleCustom.primaryColor),
          //     inputAction: TextInputAction.done, onSubmit: _addTag, onPressIcon: _addTag,
          //     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z_-]'))]),
          // BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeTagManageState,
          //     builder: (context, state) => _choice != null && _choice!.list.isNotEmpty ?
          //     Padding(padding: EdgeInsets.only(top: 40.sp),
          //         child: RenderMultiChoice(_choice!)) : const SizedBox()),
          _title('Loại quy trình'),
          TextFieldCustom(_ctrTypeProcess, _fcTypeProcess, null, 'Chọn loại quy trình',
              suffix: const Icon(Icons.arrow_drop_down), readOnly: true,
              onPressIcon: () {
                if (_typesProcess.isNotEmpty && !page.isReview) {
                  UtilUI.showOptionDialog(context, 'Danh mục',
                      _typesProcess, _typeProcess.name).then((value) => _setTypeProcess(value));
                }
              }),

          if (!page.isReview) Padding(child: Row(children: [
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
          ]), padding: EdgeInsets.only(top: 40.sp)),

          Padding(child: page.isReview ? FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png', width: 1.sw, height: 0.58.sw,
              image: Util.getRealPath(page.detail!.image), fit: BoxFit.scaleDown,
              imageScale: 0.5, imageErrorBuilder: (_, __, ___) => Image.asset('assets/images/ic_default.png', width: 1.sw, height: 0.58.sw, fit: BoxFit.fill)) :
          BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is AddImageState,
              builder: (context, state) => _image == null ? const SizedBox() :
              Stack(alignment: Alignment.topRight, children: [
                Image.memory(_image!.readAsBytesSync(), width: 1.sw,
                    height: 0.58.sw, fit: BoxFit.scaleDown),
                Container(padding: EdgeInsets.all(10.sp), decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50), color: Colors.black26
                ), margin: EdgeInsets.only(top: 20.sp, right: 20.sp),
                    child: ButtonImageCircleWidget(50, (){
                      _image = null;
                      bloc!.add(AddImageEvent());
                    }, child: Icon(Icons.clear, color: Colors.white, size: 64.sp)))
              ])), padding: EdgeInsets.only(top: 40.sp))
        ]);
    return Stack(children: [
         GestureDetector(
             onTapDown: (value) {
               clearFocus();
             },
           child: Scaffold(appBar: AppBar(elevation: 5, titleSpacing: 0, title: Padding(padding: const EdgeInsets.only(right: 48),
                 child: TitleHelper(page.isReview ? 'Duyệt quy trình kỹ thuật' : 'Đóng góp quy trình kỹ thuật',
                 url: 'https://help.hainong.vn/muc/1/huong-dan/16'))),
             backgroundColor: color, floatingActionButton:
             page.isReview ? const SizedBox() : FloatingActionButton.small(backgroundColor: StyleCustom.primaryColor,
                 onPressed: ()=> _createContribute(), child: Icon(Icons.send, color: Colors.white, size: 48.sp)),
             body: Padding(padding: EdgeInsets.all(40.sp), child: page.isReview ? Column(children: [
               Expanded(child: list),
               SizedBox(height: 40.sp),
               Row(children: [
                 ButtonImageWidget(16.sp, () => _setStatus('0'),
                     Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Từ chối',
                         size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.red),
                 ButtonImageWidget(16.sp, () => _setStatus('1'),
                     Container(padding: EdgeInsets.all(40.sp), width: 0.5.sw - 60.sp, child: LabelCustom('Chấp nhận',
                         size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
               ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
             ]) : list))),
         Loading(bloc)
       ]);
  }

  Widget _title(String title) => Padding(padding: EdgeInsets.only(top: 40.sp, bottom: 16.sp),
      child: Row(children: [
        LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal),
        LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal)
      ]));

  void _createContribute(){
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

    if (_typeProcess.name.isEmpty) {
      _fcTypeProcess.requestFocus();
      UtilUI.showCustomDialog(context, 'Chọn loại quy trình');
      return;
    }
    if (_image == null) {
      UtilUI.showCustomDialog(context, 'Chọn một ảnh');
      return;
    }

     // bloc!.add(CreateContributeTPEvent(_ctrTitle.text, _ctrContent.text, _choice?.list?? [], _typeProcess.id, _image!));
    bloc!.add(CreateContributeTPEvent(_ctrTitle.text, _ctrContent.text, _typeProcess.id, _image!));


  }

  void _loadImage(String type) => checkPermissions(ItemModel(id: type, name: MultiLanguage.get(type)));

  // void _addTag() {
  //   if (_ctrTag.text.trim().isEmpty) return;
  //   _choice?.addItem(ItemModel(id: _ctrTag.text, name: _ctrTag.text));
  //   bloc!.add(ChangeTagManageEvent());
  //   Util.trackActivities(path: 'Manage technical Process Screen -> add new contribute technical process = "${_ctrTag.text}"');
  //   _ctrTag.text = '';
  // }

     /*void _setStatuses(ItemModel? value){
          if(value !=null && value.name != _status.name){
            _status = value;
            _ctrStatus.text =value.name;
            Util.trackActivities(path: 'Manage technical Process Screen -> add new contribute technical process -> Change Status = "${_ctrStatus.text}"');
          }

    }*/
    void _setTypeProcess(value){
       if(value !=null && value.id != _typeProcess.id){
         _typeProcess = value;
         _ctrTypeProcess.text = value.name;
         Util.trackActivities('technical_process', path: 'Manage technical Process Screen -> add new contribute technical process -> Change Status = "${_ctrTypeProcess.text}"');
       }
    }

  @override
  void loadFiles(List<File> files) {
    if (files.isNotEmpty) {
      _image = files[0];
      bloc!.add(AddImageEvent());
      Util.trackActivities('technical_process', path: 'Manage News Detail Screen -> Change Image');
    }
  }

  void _setStatus(String status) => bloc!.add(UpdateStatusEvent((widget as TPCreateContributePage).detail!.id, status));
}