import 'dart:convert';

import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/comment/model/comment_model.dart';
import 'package:hainong/features/product/bloc/product_detail_bloc.dart';
import 'package:hainong/features/product/product_model.dart';

class ProductDetailRepository extends BaseRepository {
  Future<BaseResponse> loadRatings(String type, String id, String page, bool sortLike, {limit}) {
    limit ??= Constants().limitPage;
    String sort = sortLike ? '&sort=total_likes' : '';
    return apiClient.getAPI('${Constants().apiVersion}comments?classable_type=$type&classable_id=$id&page=$page'
        '&limit=$limit$sort', CommentsModel());
  }

  Future<BaseResponse> getProductDetail(int id) => apiClient.getAPI('${Constants().apiVersion}products/$id', ProductModel());

  Future<BaseResponse> delete(int id, String? permission) =>
    apiClient.postAPI('${permission != null && permission == 'admin' ? Constants().apiPerVer : Constants().apiVersion}products/$id', 'DELETE', BaseResponse());

  Future<String> getRefeffalLinkProduct(int id) => apiClient.getAPI2('${Constants().apiVersion}products/$id/referral_link');
}
