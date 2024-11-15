import 'package:hainong/common/util/util.dart';
import 'market_price_history_model.dart';

class MarketPriceChartsModel {
  final List<MarketPriceChartModel> result = [];
  MarketPriceChartsModel fromJson(Map<String, dynamic> json) {
    if (Util.isNullFromJson(json, 'result')) {
      json['result'].forEach((ele) => result.add(MarketPriceChartModel().fromJson(ele)));
    }
    return this;
  }
}

class MarketPriceChartModel {
  int id = -1;
  String title = '', created_at = '', updated_at = '';
  final MkPHistoriesModel details = MkPHistoriesModel();
  MarketPriceChartModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    title = Util.getValueFromJson(json, 'title', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    updated_at = Util.getValueFromJson(json, 'updated_at', '');
    if (Util.isNullFromJson(json, 'details')) details.fromJson(json['details'], title: title);
    return this;
  }
}