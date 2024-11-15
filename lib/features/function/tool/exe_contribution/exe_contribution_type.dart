import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/box_dec_custom.dart';

class ExeContributionType extends StatelessWidget {
  final dynamic item;
  const ExeContributionType(this.item, {Key? key}):super(key: key);

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    String type = ' ';
    switch(item['reward_type']) {
      case 'cash': type += Util.doubleToString((item['reward_amount']??.0).toDouble()) + ' VNĐ'; break;
      case 'reward_point': type += Util.doubleToString((item['reward_amount']??.0).toDouble()) + ' Điểm'; break;
      case 'data_plan': type += 'Gói cước'; break;
    }
    return LabelCustom(type, size: 48.sp, color: Colors.orangeAccent, weight: FontWeight.w400);
  }
}

class ExeContributionItem extends StatelessWidget {
  final dynamic item, funCheckGoto;
  final bool isDaily;
  const ExeContributionItem(this.item, this.isDaily, this.funCheckGoto, {Key? key}):super(key: key);

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    String title = item['title']??'';
    final type = item['mission_type']??'';
    if (type == 'contribute_interact' || type == 'referral_user') title = item['action_name']??'';
    final full = item['daily_progress'] >= item['daily_target'];
    return GestureDetector(onTap: () => isDaily ? funCheckGoto(item) : {},
      child: Container(padding: EdgeInsets.all(40.sp), margin: EdgeInsets.symmetric(vertical: 20.sp),
        decoration: BoxDecCustom(radius: 5),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(5),
              child: ImageNetworkAsset(path: item['icon']??'', width: 128.sp, height: 128.sp)),
          SizedBox(width: 40.sp),
          Expanded(child: Column(children: [
            LabelCustom(title, size: 48.sp, color: Colors.green),
            SizedBox(height: 20.sp),
            if (!isDaily) Row(children: [
              Expanded(child: LabelCustom(item['description']??'', size: 48.sp, color: Colors.black87, weight: FontWeight.w400)),
              LabelCustom(Util.doubleToString((item['progress']??0).toDouble()) + '/' +
                  Util.doubleToString((item['total_target']??0).toDouble()), size: 40.sp, color: Colors.black87, weight: FontWeight.w400),
            ], crossAxisAlignment: CrossAxisAlignment.end),
            if (isDaily) LabelCustom(item['description']??'', size: 48.sp, color: Colors.black87, weight: FontWeight.w400),
            if (isDaily) Container(margin: EdgeInsets.only(top: 20.sp), height: 48.sp, width: 1.sw - 412.sp,
                decoration: BoxDecCustom(radius: 10, bgColor: Colors.black26),
                child: Stack(children: [
                  Container(width: _getPercent(), decoration: BoxDecoration(color: StyleCustom.primaryColor,
                      borderRadius: BorderRadius.horizontal(left: const Radius.circular(10),
                          right: full ? const Radius.circular(10) : Radius.zero))),
                  Align(child: LabelCustom(Util.doubleToString((item[full?'daily_target':'daily_progress']??0 ).toDouble()) + '/' +
                      Util.doubleToString((item['daily_target']??0).toDouble()), size: 32.sp), alignment: Alignment.center)
                ]))
          ], crossAxisAlignment: CrossAxisAlignment.start)),
          if (isDaily) item['daily_progress'] >= item['daily_target'] ? Padding(padding: EdgeInsets.only(left: 20.sp),
              child: Icon(Icons.check, color: StyleCustom.primaryColor, size: 64.sp)) : SizedBox(width: 84.sp)
        ])
    ));
  }

  double _getPercent() {
    double process = 1.sw - 412.sp, now = (item['daily_progress']??0).toDouble(), target = (item['daily_target']??0).toDouble();
    if (now > target) now = target;
    process = now * process / target;
    return process;
  }
}