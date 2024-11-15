import 'package:hainong/common/constants.dart';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/core_button_custom.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../market_price_bloc.dart';
import 'market_price_detail_page.dart';
import '../model/market_price_model.dart';

class MarketPriceItem extends StatelessWidget {
  final MarketPriceModel item;
  final Function funReloadChart, funReport, funInterest;
  final Function? funReloadList;
  final int index;
  final MarketPriceBloc bloc;
  const MarketPriceItem(this.index,this.item, this.funReloadChart, this.funReport,  this.funInterest, this.bloc, {this.funReloadList, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    String price = '', unit = item.unit.isEmpty ? '' : ' đ/' + item.unit;
    if (item.lastDetail.price > 0) price = Util.doubleToString(item.lastDetail.price) + unit;
    //if (item.lastDetail.max_price > 0) price += (price.isNotEmpty ? ' - ' : '') + Util.doubleToString(item.lastDetail.max_price);
    Color color = const Color(0xFF0084FD);
    IconData icon = Icons.swap_vert;
    if (item.lastDetail.price_difference > 0) {
      color = const Color(0xFF4C9E00);
      icon = Icons.north;
    }
    if (item.lastDetail.price_difference < 0) {
      color = const Color(0xFFDDA618);
      icon = Icons.south;
    }
    return CoreButtonCustom(() {
      UtilUI.goToNextPage(context, MarketPriceDtlPage(item, funReloadChart, funReloadList: funReloadList));
      Util.trackActivities('market_price', path: 'Market Price Screen -> Show detail ${item.title} price');
    }, Column(children: [
      Row(children: [
        Expanded(child: LabelCustom(item.title, weight: FontWeight.normal, size: 42.sp, color: const Color(0xFF282727))),
        Expanded(child: LabelCustom(price, weight: FontWeight.normal, size: 42.sp, color: const Color(0xFFFF5555), align: TextAlign.right)),
      ], crossAxisAlignment: CrossAxisAlignment.start),
      Padding(child: Row(children: [
        Icon(Icons.location_on, color: StyleCustom.textColor6C, size: 42.sp),
        Expanded(child: LabelCustom(item.province_name, weight: FontWeight.normal, size: 36.sp, color: const Color(0xFF838383))),
        Padding(child: Icon(icon, color: color, size: item.lastDetail.price_difference != 0 ? 38.sp : 48.sp), padding: EdgeInsets.symmetric(horizontal: 8.sp)),
        LabelCustom(Util.doubleToString(item.lastDetail.price_difference) + unit, weight: FontWeight.normal, size: 36.sp, color: color)
      ], crossAxisAlignment: CrossAxisAlignment.start), padding: EdgeInsets.symmetric(vertical: 8.sp)),
      Row(children: [
        LabelCustom(Util.strDateToString(item.last_price_updated_at), weight: FontWeight.normal, size: 36.sp, color: const Color(0xFF838383)),
        if (Constants().isLogin) CoreButtonCustom(() => funInterest(index), BlocBuilder(bloc: bloc,
            buildWhen: (oldS, newS) => newS is ChangeInterestState && index == newS.index,
            builder: (context, state) {
              return Image.asset('assets/images/v5/ic_bookmark.png', color: item.user_liked ? const Color(0xFF1AAD80) : null, height: 42.sp);
            }), sizeRadius: 50, padding: EdgeInsets.all(10.sp))
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
    ], crossAxisAlignment: CrossAxisAlignment.start), sizeRadius: 16.sp, color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32.sp, vertical: 20.sp));
  }
}