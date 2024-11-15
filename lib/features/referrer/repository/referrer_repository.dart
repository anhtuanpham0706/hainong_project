import 'dart:convert';

import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/referrer/model/referrer_model.dart';
import 'package:hainong/features/shop/shop_model.dart';

class ReferrerRepository extends BaseRepository {
  Future<BaseResponse> loadFriends(String? keyword, String page, {limit}) {
    limit ??= Constants().limitPage;
    if (keyword?.isNotEmpty == true) keyword = '&name=$keyword';
    page = "page=$page&limit=20";
    String path = '${Constants().apiVersion}friends?$page$keyword';
    return apiClient.getAPI(path, ReferrersModel());
  }

  Future<BaseResponse> loadReferrer(String? phone) {
    final params = "phone=$phone";
    String path = '${Constants().apiVersion}friends/user_detail?$params';
    return apiClient.getAPI(path, ReferrerModel());
  }

  Future<ReferrerHistoryResponse?> loadReferrerNewUser(type) async {
    String path = '${Constants().apiVersion}referral_histories/$type';
    final resp = await ApiClient().getAPI2(path);
    if (resp.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(resp);
      return Util.checkKeyFromJson(json, 'success') &&
              Util.checkKeyFromJson(json, 'data') &&
              json['success']
          ? ReferrerHistoryResponse(
              response: BaseResponse(success: true, data: json['data'].toList()),
              totalPoint: json['count'],
              type: type)
          : ReferrerHistoryResponse(
              response: BaseResponse(data: json['data'].toString()),
              totalPoint: json['count'],
              type: type);
    }
    return null;
  }

  Future<BaseResponse> loadShop(String id) =>
      apiClient.getAPI('${Constants().apiVersion}shops/$id', ShopModel());
}
