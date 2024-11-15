import '../util/util.dart';
import 'import_lib_base_ui.dart';
import 'label_custom.dart';

class MemPackageContent extends StatelessWidget {
  final dynamic item;
  const MemPackageContent(this.item, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final point = (item['exchange_point']??.0).toDouble();
    final money = (item['exchange_money']??.0).toDouble();
    final temp1 = LabelCustom('Sử dụng ', color: Colors.black, size: 46.sp, weight: FontWeight.w400);
    final temp2 = point > 0 ? Row(children: [
      Icon(Icons.star_border_purple500, color: const Color(0xFFF9BB48), size: 48.sp),
      LabelCustom(Util.doubleToString(point) + " điểm" + (money > 0 ? '' : ' '), color: Colors.black, size: 46.sp)
    ], mainAxisSize: MainAxisSize.min) : const SizedBox();
    final temp3 = point * money > 0 ? LabelCustom(' hoặc ', color: Colors.black, size: 46.sp, weight: FontWeight.w400) : const SizedBox();
    final temp4 = money > 0 ? Row(children: [
      Icon(Icons.payments_outlined, color: const Color(0xFFF9BB48), size: 48.sp),
      LabelCustom(' ' + Util.doubleToString(money) + ' VNĐ ', color: Colors.black, size: 46.sp)
    ], mainAxisSize: MainAxisSize.min) : const SizedBox();
    final temp5 = LabelCustom('để đăng ký gói cước', color: Colors.black, size: 46.sp, weight: FontWeight.w400);
    final content = Column(children: [
      Row(children: [
        Expanded(flex: 8, child: LabelCustom(item['name']??'', color: Colors.green, size: 48.sp, line: 5, overflow: TextOverflow.ellipsis)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 2.5), child: Image.asset('assets/images/v7/ic_v7_star.png', width: 80.sp)),
        Expanded(flex: 2, child: Align(alignment: Alignment.center, child: LabelCustom(item['user_level']??'',
            color: Colors.black, size: 38.sp, align: TextAlign.center)))
      ]),
      Padding(child: LabelCustom('Thời hạn sử dụng: ' + Util.doubleToString((item['expiry_date']??.0).toDouble()) + ' ngày',
          color: Colors.black45, size: 40.sp, weight: FontWeight.w400), padding: EdgeInsets.symmetric(vertical: 20.sp)),
      Wrap(children: [temp1, temp2, temp3, temp4, temp5])
    ], crossAxisAlignment: CrossAxisAlignment.start);
    return content;
  }
}