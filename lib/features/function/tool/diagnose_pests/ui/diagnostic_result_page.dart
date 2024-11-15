import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/item_option.dart';
import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/shadow_decoration.dart';
import 'package:hainong/features/function/support/pests_handbook/ui/pests_handbook_list_page.dart';
import 'package:hainong/features/shop/ui/import_ui_shop.dart';
import '../diagnose_pests_bloc.dart';
import '../model/diagnostic_model.dart';
import '../model/plant_model.dart';
import 'diagnostic_compare_page.dart';
import 'diagnostic_similar_photos_page.dart';
import 'diagnostis_pests_contribute_page.dart';
import 'diagnostis_pests_detail_page.dart';

class DiaResultPage extends BasePage {
  DiaResultPage(DiagnosticModel result, String shareContent, List<FileByte> images,
      List<PlantModel> catalogues, {Key? key})
        : super(pageState: _DiaResultPageState(result, shareContent, images, catalogues), key: key);
}
class _DiaResultPageState extends BasePageState {
  final List<PlantModel> catalogues;
  final DiagnosticModel result;
  final String shareContent;
  final List<FileByte> images;
  _DiaResultPageState(this.result, this.shareContent, this.images, this.catalogues);

  @override
  void initState() {
    bloc = DiagnosePestsBloc(const DiagnosePestsState());
    super.initState();
    bloc!.stream.listen((state) {
      if (state is CreatePostDiagnosePestsState && isResponseNotError(state.response)) {
        UtilUI.showCustomDialog(context, 'Kết quả chẩn đoán đã được đăng lên tường thành công', title: 'Thông báo');
      } else if (state is SendFeedbackState && isResponseNotError(state.resp, passString: true)) {
        UtilUI.showCustomDialog(context, 'Đã gửi phản hồi thành công', title: 'Thông báo');
      }
    });
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => WillPopScope(
      onWillPop: () async {
        UtilUI.goBack(context, true);
        return false;
      },
      child: Scaffold(appBar: AppBar(titleSpacing: 0, centerTitle: true,
          title: UtilUI.createLabel('Kết quả chẩn đoán'),
          actions: [
            IconButton(onPressed: _showMenu, icon: Icon(Icons.add, color: Colors.white, size: 56.sp)),
            IconButton(onPressed: _feedback, icon: Icon(Icons.feedback, color: Colors.white, size: 56.sp))
          ]),
          body: Stack(children: [createUI(), Loading(bloc)])));

  @override
  Widget createUI() {
    String name = '', desLong = '';
    List<String> images = [];
    if (result.tree.isNotEmpty) {
      if (Util.checkKeyFromJson(result.tree, 'images')) {
        result.tree['images'].forEach((ele) => images.add(ele['name']));
      }
      if (images.isEmpty) {
        String temp = result.tree['image'] ?? '';
        if (temp.contains('no_image.png')) temp = '';
        images.add(temp);
      }
      name = result.tree['name']??'';
      desLong = result.tree['description']??'';
    }
    return ListView(children: [
        Padding(padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 20.sp), child: Row(children: [
          LabelCustom('Nhận dạng cây: ', color: const Color(0xFF1AAD80), size: 48.sp),
          LabelCustom(name, size: 48.sp, color: const Color(0xFF292929))
        ])),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if(images.isNotEmpty) Stack(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(32.sp),
                  child: CarouselSlider.builder(itemCount: images.length,
                      options: CarouselOptions(viewportFraction: 1.0, autoPlay: images.length > 1),
                      itemBuilder: (context, index, realIndex) =>
                          ImageNetworkAsset(path: images[index], height: 0.24.sh, width: 1.sw - 80.sp)
                  ),
                ),
                Positioned(child: InkWell(
                  onTap: (){
                    List<String> imageUser = result.diagnostics.map((e) => e.image).toList();
                    UtilUI.goToNextPage(context, DiagnosticComparePage( name, desLong, images, imageUser));
                  },
                  child: Container(
                    padding: EdgeInsets.all(20.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.sp),
                      color: const Color(0xFF56A554),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/compare.png', width: 60.sp, color: Colors.white),
                        SizedBox(width: 12.sp),
                        LabelCustom('So sánh', align: TextAlign.center, size: 40.sp)
                      ],
                    ),
                  ),
                ), right: 16.sp, top: 16.sp,)
              ],
            ),
            SizedBox(height: 20.sp),
            BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowPercentState,
                builder: (context, state) {
                  bool _isSeeMore = state is ShowPercentState && state.value || desLong.length < 501;
                  return SizedBox(child: Html(data: name.isNotEmpty ? ('<b>' + name + ':</b> ' + desLong) : desLong,
                      style: {'html, body, p, div': Style(margin: EdgeInsets.zero, padding:
                      EdgeInsets.zero, fontSize: FontSize(42.sp), color: const Color(0xFF292929))},
                      onLinkTap: (link, render, map, ele) {
                        if (link != null) launchUrl(Uri.parse(link));
                      }
                  ), height: _isSeeMore ? null : 0.12.sh);
                }),
            desLong.length > 500 ? BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowPercentState,
                builder: (context, state) {
                  bool _isSeeMore = state is ShowPercentState && state.value;
                  return TextButton(onPressed: () => bloc!.add(ShowPercentEvent(!_isSeeMore)),
                    child: LabelCustom(_isSeeMore ? 'Thu gọn' : 'Nhấn để xem chi tiết', weight: FontWeight.w500,
                      decoration: TextDecoration.underline, color: StyleCustom.primaryColor, size: 38.sp));
            }) : SizedBox(height: 40.sp)
          ],
        )),

        Divider(height: 16.sp, color: const Color(0xFFF5F5F5), thickness: 16.sp),

        Padding(padding: EdgeInsets.all(40.sp), child: Column(children: [
          Row(children: [
            Expanded(child: LabelCustom('Kết quả phân tích', color: const Color(0xFF1AAD80), size: 48.sp)),
            ButtonImageWidget(5, () => UtilUI.goToNextPage(context, DiagnosisPestDetailPage(result.diagnostics)), Row(children: [
              LabelCustom('Chi tiết', color: const Color(0xFF1AAD80), size: 42.sp, align: TextAlign.right),
              Icon(Icons.arrow_forward_ios, color: const Color(0xFF1AAD80), size: 42.sp)
            ]))
          ]),

          if (result.summaries.isNotEmpty) Container(margin: EdgeInsets.only(top: 40.sp),
            padding: EdgeInsets.all(40.sp), decoration: ShadowDecoration(size: 10), child: Column(children: [
              ListView.separated(separatorBuilder: (context, index) => SizedBox(height: 40.sp),
                  padding: EdgeInsets.zero, shrinkWrap: true, itemBuilder: (context, index) {
                    String image = _getImage(result.diagnostics, result.summaries[index].suggest.toLowerCase());
                    return Row(children: [
                      AvatarCircleWidget(link: image, size: 140.sp, assetsImageReplace: 'assets/images/ic_default.png'),
                      SizedBox(width: 20.sp),
                      Expanded(child: Column(children: [
                        LabelCustom(result.summaries[index].suggest + ' ('+result.summaries[index].percent.toString()+'%)', color: Colors.black, size: 48.sp, weight: FontWeight.normal),
                        SizedBox(height: 20.sp),
                        Row(children: [
                          Flexible(child: ButtonImageWidget(0, () => UtilUI.goToNextPage(context, PestsHandbookListPage(result.summaries[index].suggest)),
                                  LabelCustom('Cách phòng tránh', color: const Color(0xFF1AAD80), size: 38.sp, weight: FontWeight.normal, decoration: TextDecoration.underline))),
                          Flexible(child: Container(margin: EdgeInsets.only(left: 10.sp),
                              child:ButtonImageWidget(0, () => UtilUI.goToNextPage(context, DiaSimilarPhotosPage(result.summaries[index].images, result.summaries[index].suggest)),
                                  LabelCustom('Xem thêm ảnh', color: const Color(0xFF1AAD80), size: 38.sp, weight: FontWeight.normal, align: TextAlign.right, decoration: TextDecoration.underline))))
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start)
                      ], crossAxisAlignment: CrossAxisAlignment.start))
                    ]);
                  }, itemCount: result.summaries.length, physics: const NeverScrollableScrollPhysics()),

              ListView.builder(padding: EdgeInsets.zero, shrinkWrap: true, itemBuilder: (context, index) {
                return result.diagnostics[index].message.isNotEmpty ? Text('* ' + result.diagnostics[index].message,
                    style: TextStyle(color: Colors.black, fontSize: 48.sp)) : const SizedBox();
              }, itemCount: result.diagnostics.length, physics: const NeverScrollableScrollPhysics())
          ]))
        ], crossAxisAlignment: CrossAxisAlignment.start)),
      ], padding: EdgeInsets.symmetric(vertical: 40.sp));
  }

  String _getImage(List<Diagnostic> diagnostics, String tree) {
    double max = 0;
    String image = '';
    for (var item in diagnostics) {
      for (var summary in item.predicts) {
        if (summary.suggest.toLowerCase() == tree && max < summary.percent) {
          max = summary.percent;
          image = item.image;
        }
      }
    }
    return max > 0 ? image : '';
  }

  void _showMenu() {
    if (shareContent.isNotEmpty && result.diagnostics.isNotEmpty &&
        result.summaries.isNotEmpty && result.tree.isNotEmpty) {
      UtilUI.showOptionDialog2(context, MultiLanguage.get('ttl_option'), [
        ItemOption('', 'Chia sẻ kết quả lên tường', _shareResult, false, icon: Icons.share),
        ItemOption('', 'Đóng góp hình ảnh/dữ liệu', _contribute, false, icon: Icons.feedback),
      ]);
    } else _contribute(hasBack: false);
  }

  void _shareResult() {
    UtilUI.goBack(context, false);
    bloc!.add(CreatePostDiagnosePestsEvent(images, shareContent));
  }

  void _feedback() => UtilUI.showConfirmDialog(context, '', 'Nhập nội dung phản hồi',
    'Nội dung không được để trống', padding: EdgeInsets.all(30.sp),
    title: 'Phản hồi kết quả', showMsg: false, line: 0, inputType: TextInputType.multiline, action: TextInputAction.newline).then((value) {
      if (value != null && value is String && value.isNotEmpty) bloc!.add(SendFeedbackEvent(value, result.ids));
    });

  void _contribute({bool hasBack = true}) {
    if (hasBack) UtilUI.goBack(context, false);
    UtilUI.goToNextPage(context, DiagnosePetsContributePage(catalogues, tree: Util.getValueFromJson(result.tree, 'name', ''),
      diagnosis: result.summaries.isNotEmpty ? result.summaries.first.suggest : '', images: images));
  }
}