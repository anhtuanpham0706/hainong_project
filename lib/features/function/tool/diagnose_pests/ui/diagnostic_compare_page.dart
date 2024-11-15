import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util_ui.dart';

class DiagnosticComparePage extends StatefulWidget {
 final String name, desLong;
 final List<String> imageUser, imageDiagnostic;

 const DiagnosticComparePage(this.name, this.desLong, this.imageDiagnostic, this.imageUser, {Key? key}) : super(key: key);

  @override
  State<DiagnosticComparePage> createState() =>_DiagnosticCompareImageState();
}

class _DiagnosticCompareImageState extends State<DiagnosticComparePage> {
  int _index = 0;
  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    List<Widget> list = [];
    for(int i = 0; i<widget.imageDiagnostic.length; i++){
      list.add(Container(height: 8, width: i == _index ? 30 : 8,
          decoration: BoxDecoration(color: const Color(0xFF1B5E20).withOpacity(i == _index ? 0.8 : 0.5),
              borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.symmetric(horizontal: 4)));
    }
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, centerTitle: true, title: UtilUI.createLabel(widget.name)),
      body: ListView(
        padding: EdgeInsets.all(40.sp),
        children: [
          if (widget.imageDiagnostic.length > 1) Padding(padding: EdgeInsets.only(bottom: 20.sp),
              child: Row(children: list, mainAxisAlignment: MainAxisAlignment.center)),
          ClipRRect(borderRadius: BorderRadius.circular(32.sp),
              child: CarouselSlider.builder(itemCount: widget.imageDiagnostic.length,
                  options: CarouselOptions(viewportFraction: 1, autoPlay: widget.imageDiagnostic.length > 1,
                      onPageChanged: (index, reason) => setState(() => _index = index)
                  ),
                  itemBuilder: (context, index, realIndex) =>
                      ImageNetworkAsset(path: widget.imageDiagnostic[index], height: 0.24.sh, width: 1.sw - 80.sp)
              )),
          SizedBox(height: 40.sp),
          Stack(alignment: Alignment.bottomCenter, children: [
                ClipRRect(borderRadius: BorderRadius.circular(32.sp),
                  child: CarouselSlider.builder(itemCount: widget.imageUser.length,
                      options: CarouselOptions(viewportFraction: 1, autoPlay: false),
                      itemBuilder: (context, index, realIndex) =>
                          ImageNetworkAsset(path: widget.imageUser[index], height: 0.24.sh, width: 1.sw - 80.sp)
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20.sp),
                  padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 20.sp),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20.sp)
                  ),
                  child: const Text('Ảnh của bạn', style: TextStyle(color: Colors.black),),

                )
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: Row(children: [
            LabelCustom('Nhận dạng cây: ', color: const Color(0xFF1AAD80), size: 48.sp),
            LabelCustom(widget.name,size: 48.sp, color: const Color(0xFF292929))
          ])),
          Html(data: widget.name.isNotEmpty ? ('<b>' + widget.name + ':</b> ' + widget.desLong) : widget.desLong,
            style: {'html, body, p, div': Style(margin: EdgeInsets.zero, padding:
                EdgeInsets.zero, fontSize: FontSize(42.sp), color: const Color(0xFF292929))})
        ]
      ));
  }
}



