import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import '../ba_model.dart';
import 'ba_dtl_page.dart';

class BAItem extends StatelessWidget {
  final BAModel item;
  final bool fullInfo;
  const BAItem(this.item, {this.fullInfo = false, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return ButtonImageWidget(0.0, () => _goToDetail(context),
      Container(padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: fullInfo ? 40.sp : 0), child:
        Row(children: [
          Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10),
                child: ImageNetworkAsset(path: item.image, width: fullInfo ? 0.25.sw : 200.sp,
                    height: fullInfo ? 0.2.sw : 140.sp, fit: BoxFit.cover)),
            if (item.prestige == 1) Image.asset('assets/images/v8/ic_prestige_business.png', width: 80.sp, height: 80.sp)
          ], alignment: Alignment.topRight),
          SizedBox(width: 40.sp),
          Expanded(child: fullInfo ? Column(children: [
            _Line('', item.name),
            Padding(padding: EdgeInsets.symmetric(vertical: 20.sp), child: _Line('Địa chỉ: ', item.address)),
            _Line('Email: ', item.email),
            Padding(padding: EdgeInsets.only(top: 20.sp), child: _Line('Số điện thoại: ', item.phone))
          ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 40.sp),
            Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 40.sp, color: Colors.black)),
            Padding(padding: EdgeInsets.only(top: 10.sp, bottom: 40.sp), child: Row(children: [
              Icon(Icons.language, color: Colors.blue, size: 40.sp),
              SizedBox(width: 10.sp),
              Expanded(child: Text(item.website, style: TextStyle(color: Colors.blue, fontSize: 40.sp)))
            ])),
            const Divider(height: 0.5)
          ]))
        ])));
  }

  void _goToDetail(BuildContext context) {
    UtilUI.goToNextPage(context, BADetailPage(item));
    Util.trackActivities('business_association', path: 'Business Association List Screen -> Show detail ${item.content}');
  }
}

class _Line extends StatelessWidget {
  final String title, value;
  const _Line(this.title, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(children: [
    LabelCustom(title, color: Colors.black, size: 48.sp, weight: FontWeight.w500),
    Expanded(child: LabelCustom(value, color: Colors.black, size: 48.sp, weight: title.isEmpty ? FontWeight.w500 : FontWeight.w400))
  ], crossAxisAlignment: CrossAxisAlignment.start);
}