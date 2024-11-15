import 'package:hainong/common/util/util.dart';
import 'market_price_history_model.dart';

class MarketPricesModel {
  final List<MarketPriceModel> list = [];
  MarketPricesModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(MarketPriceModel().fromJson(ele)));
    return this;
  }
}

class MarketPriceModel {
  bool user_liked = false;
  int id = -1, province_id = -1, district_id = -1, classable_id = -1;
  String title = '', created_at = '', last_price_updated_at = '', province_name = '',
      district_name = '', unit = '', classable_type = '', agricultural_type = '', image = '';


  final MkPHistoryModel lastDetail = MkPHistoryModel();
  MkPHistoriesModel? details;
  MarketPriceModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    province_id = Util.getValueFromJson(json, 'province_id', -1);
    district_id = Util.getValueFromJson(json, 'district_id', -1);
    classable_id = Util.getValueFromJson(json, 'classable_id', -1);
    user_liked = Util.getValueFromJson(json, 'user_liked', false);
    title = Util.getValueFromJson(json, 'title', '');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    last_price_updated_at = Util.getValueFromJson(json, 'last_price_updated_at', '');
    province_name = Util.getValueFromJson(json, 'province_name', '');
    district_name = Util.getValueFromJson(json, 'district_name', '');
    unit = Util.getValueFromJson(json, 'unit', '');
    classable_type = Util.getValueFromJson(json, 'classable_type', '');
    agricultural_type = Util.getValueFromJson(json, 'agricultural_type', '');
    image = Util.getValueFromJson(json, 'image', '');
    if (Util.isNullFromJson(json, 'get_market_price_last')) lastDetail.fromJson(json['get_market_price_last']);
    if (Util.isNullFromJson(json, 'data'))  details = json['data'];
    if (lastDetail.id <= 0 && Util.isNullFromJson(json, 'market_prices')) {
      final temp = json['market_prices'].first;
      lastDetail.fromJson(temp);
    }
    return this;
  }
}