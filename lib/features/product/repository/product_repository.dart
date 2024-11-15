import 'dart:convert';
import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/catalogue_model.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/features/function/support/business_association/ba_model.dart';
import 'package:hainong/features/product/product_model.dart';
import 'package:hainong/features/referrer/model/advance_point_model.dart';
import 'package:hainong/features/referrer/model/advance_update_point_model.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hainong/common/util/util.dart';

class ProductRepository extends BaseRepository {
  Future<BaseResponse> loadProducts(String keyword, String catalogueId, String provinceId, String page, String productId,
      {limit, bool isHighlight = false, bool hasExceptCatalogue = false, bool isMine = false, String type = '', int businessId = -1}) {

    limit ??= Constants().limitPage;

    page = '?page=$page&limit=$limit';
    if (keyword.isNotEmpty) keyword += '&keyword=$keyword';
    keyword = page + keyword;

    catalogueId = catalogueId.isNotEmpty && catalogueId != '-1' ? '&catalogue_ids=$catalogueId':'';

    provinceId = provinceId.isNotEmpty && provinceId != '-1' ? '&province_id=$provinceId':'';

    String product = productId.isNotEmpty && productId != '-1' ? '&product_id=$productId':'';

    type = type.isNotEmpty ? '&product_type=$type':'';

    String path = 'markets/highlight_products$keyword';
    if (!isHighlight) path = 'products$keyword$catalogueId$provinceId$product$type';
    if (isMine) path = 'products/current_products$keyword$catalogueId$provinceId$product$type';
    if (hasExceptCatalogue && productId.isNotEmpty && productId != '-1') path = 'products/$productId/other_products$keyword';
    if (businessId > 0) path = 'business/products/business_association/all$keyword&business_association_id=$businessId';

    return apiClient.getAPI(Constants().apiVersion + path, ProductsModel());
  }

  Future<BaseResponse> loadFavouriteProducts(String page, {limit}) {
    final Constants constants = Constants();
    limit ??= constants.limitPage;
    return apiClient.getAPI(
        '${Constants().apiVersion}account/list_favourites?page=$page&limit=$limit',
        ProductsModel());
  }

  Future<BaseResponse> loadSubCatalogues(int id) =>
      apiClient.getAPI('${Constants().apiVersion}catalogues/child_product_catalogues/$id', CataloguesModel(removeSub: false),
          hasHeader: false);

  Future<BaseResponse> loadCatalogues(String type) {
    if (type.isNotEmpty) type = '?catalogue_type=' + type;
    return apiClient.getAPI(Constants().apiVersion + 'catalogues/product_catalogues' + type, CataloguesModel(), hasHeader: false);
  }

  Future<BaseResponse> loadCatalogue() =>
      apiClient.getAPI('${Constants().apiVersion}catalogues/product_catalogues', ItemListModel(),
          hasHeader: false);

  Future<BaseResponse> loadUnit() => apiClient
      .getAPI('${Constants().apiVersion}products/list_units', ItemListModel(), hasHeader: false);

  Future<BaseResponse> postProduct(List<FileByte> files, ProductModel product, int idBusiness) =>
      apiClient.postAPI(Constants().apiVersion + (idBusiness > 0 ? 'business/' : '') + 'products',
          'POST', ProductModel(),
          body: {
            "title": product.title,
            "product_code": product.product_code,
            "description": product.description,
            "product_type": product.product_type,
            "product_catalogue_id": product.product_catalogue_id.toString(),
            "product_unit_id": product.product_unit_id.toString(),
            "quantity": product.quantity.toString(),
            "retail_price": product.retail_price.toString(),
            "wholesale_price": product.wholesale_price.toString(),
            "optional_name": product.optional_name,
            "hot_pick": product.hot_pick.toString(),
            "business_association_id": idBusiness.toString(),
            "referraler_ids": jsonEncode(product.referraler_ids),
            "intruction_point": product.intruction_point.toString(),
            "discount_level": product.discount_level.toString(),
            "coupon_per_item": product.coupon_per_item.toString(),
          },
          realFiles: files);

  Future<BaseResponse> editProduct(List<FileByte> files, ProductModel product, int idBusiness, {String? permission}) {
    String path = (permission != null && permission == 'admin' ? Constants().apiPerVer : Constants().apiVersion) + 'products/${product.id}';
    if (idBusiness > 0) path = Constants().apiVersion + 'business/products/${product.id}';
    return apiClient.postAPI(path, 'PUT', ProductModel(),
        body: {
          "title": product.title,
          "product_code": product.product_code,
          "description": product.description,
          "product_type": product.product_type,
          "product_catalogue_id": product.product_catalogue_id.toString(),
          "product_unit_id": product.product_unit_id.toString(),
          "quantity": product.quantity.toString(),
          "retail_price": product.retail_price.toString(),
          "wholesale_price": product.wholesale_price.toString(),
          "optional_name": product.optional_name,
          "hot_pick": product.hot_pick.toString(),
          "business_association_id": idBusiness.toString(),
          "referraler_ids": jsonEncode(product.referraler_ids),
          "intruction_point": product.intruction_point.toString(),
          "discount_level": product.discount_level.toString(),
          "coupon_per_item": product.coupon_per_item.toString(),
        },
        realFiles: files);
  }

  Future<BaseResponse> addFavorite(int classableId, String classableType) =>
      apiClient.postAPI('${Constants().apiVersion}account/create_favourite', 'POST', ItemModel(),
          body: {
            "classable_type": classableType,
            "classable_id": classableId.toString()
          });

  Future<BaseResponse> removeFavorite(int favoriteId) => apiClient.postAPI(
      '${Constants().apiVersion}account/favourite/$favoriteId', 'DELETE', BaseResponse());

  Future<File?> downloadImage(String url, String path) async {
    File? file;
    try {
      final http.Response response = await apiClient.httpClient.get(Uri.parse(Util.getRealPath(url))).timeout(Duration(seconds: Constants().timeout));
      if (response.statusCode == 200) {
        final List<String> str = url.split('/');
        if (str.length > 1) {
          final Directory folder = Directory(path);
          if (!folder.existsSync()) folder.createSync();
          file = File(path + str[str.length - 1]);
          if (!file.existsSync()) {
            file.createSync();
            file.writeAsBytesSync(response.bodyBytes, flush: true);
          }
        }
      }
    } catch (_) {}
    return file;
  }

  Future<BaseResponse> loadBAs(bool isBMarket, {String param = '?page=1&limit=100'}) {
    if (isBMarket) param = '/enterprise/all?page=1&limit=4';
    return apiClient.getAPI(Constants().apiVersion + 'business/business_associations$param', BAsModel());
  }

  Future<BaseResponse> getAdvancePoints(int id) => apiClient.getAPI(Constants().apiVersion + 'advance_points/$id', AdvancePointModel());

  Future<BaseResponse> postAdvancePoint(int pointableId, String pointableType, String actionChange, String point) =>
    apiClient.postAPI('${Constants().apiVersion}advance_points', 'POST', AdvanceUpdatePointModel(),
          body: {
            "pointable_id": pointableId.toString(),
            "pointable_type": pointableType,
            "action_change": actionChange,
            "point": point,
          });
}
