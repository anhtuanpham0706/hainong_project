import 'package:hainong/common/constants.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import '../model/market_price_history_model.dart';

class MarketPriceHistoryItem extends StatelessWidget {
  final MkPHistoryModel item;
  final Function warning;
  final String unit;
  const MarketPriceHistoryItem(this.item, this.unit, this.warning, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    String price = '';
    if (item.price > 0) price = Util.doubleToString(item.price) + unit;
    //if (item.max_price > 0) price += (price.isNotEmpty ? ' - ' : '') + Util.doubleToString(item.max_price) + unit;
    if (price.isEmpty) price = Util.doubleToString(item.price) + unit;

    return Row(
        children: [
      Expanded(flex: 2, child: UtilUI.createLabel(Util.strDateToString(item.created_at,
          pattern: 'dd/MM/yyyy\nHH:mm'), fontSize: 30.sp, color: const Color(0xFF585858),
          textAlign: TextAlign.center, fontWeight: FontWeight.normal)),
      Expanded(flex: 6, child: UtilUI.createLabel(price, fontSize: 42.sp,
          color: const Color(0xFFFF5555), textAlign: TextAlign.center, fontWeight: FontWeight.normal)),
      Expanded(flex: 1, child: Constants().isLogin? IconButton(icon:  Icon(Icons.warning, color: Colors.orangeAccent, size: 50.sp), onPressed: ()=> warning(item.id),) :
      IconButton(icon: Icon(Icons.warning, color: Colors.transparent, size: 50.sp), onPressed: ()=> {},),),
      Expanded(flex: 1, child: (item.user_name.isEmpty || item.user_name == 'Admin')? const SizedBox(): MyTooltip(message:'Đóng góp bởi: ${item.user_name}',
        child: Icon(Icons.info, color: Colors.blue, size: 60.sp))),
    ]);
  }
}

class MyTooltip extends StatelessWidget{
  final Widget child;
  final String message;
  const MyTooltip({Key? key, required this.child, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: ()=>_ontap(key),
        child: child));
  }

  void _ontap(GlobalKey key){
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}