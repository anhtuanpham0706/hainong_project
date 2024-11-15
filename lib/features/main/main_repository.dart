import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/features/function/info_news/news/news_model.dart';
import 'package:hainong/features/main/total_model.dart';
import 'package:hainong/features/main/ui/import_lib_ui_main_page.dart';
import '../function/info_news/technical_process/technical_process_model.dart';
import '../function/support/handbook/handbook_page.dart';
import '../main2/ui/search/models/home_search_model.dart';
import '../main2/ui/search/models/home_search_params.dart';

class MainRepository extends BaseRepository {
  Future<BaseResponse> lastActivity() => apiClient
      .postAPI('${Constants().apiVersion}account/last_activity', 'PUT', BaseResponse());

  Future<BaseResponse> getTotal() => apiClient
      .getAPI('${Constants().apiVersion}account/get_total_item', TotalModel());

  Future<BaseResponse> countNotification() => apiClient
      .getAPI('${Constants().apiVersion}notifications/count', BaseResponse());

  Future<BaseResponse> getPests() => apiClient
      .getAPI('${Constants().apiVersion}diagnostic_infos/diagnostics', ItemListModel(keyName: 'name_vi'), hasHeader: false);
  
  Future<BaseResponse> getSearchHome(HomeSearchParams params) => apiClient
      .getAPI('${Constants().apiVersion}home/search?keyword=${params.keyword}', HomeSearchModels());

  Future<BaseResponse> getArticleDetail(id) => apiClient.getAPI('${Constants().apiVersion}articles/$id', NewsModel());

  Future<BaseResponse> getProductDetail(id) => apiClient.getAPI('${Constants().apiVersion}products/$id', ProductModel());

  Future<BaseResponse> getPostDetail(id) => apiClient.getAPI(Constants().apiVersion + 'posts/' + id, Post());

  Future<String> getMarketPriceDetail(id) => apiClient.getAPI2(Constants().apiVersion + 'market_prices/' + id, hasHeader: Constants().isLogin);

  Future<BaseResponse> getPestHandbookDetail(id) => apiClient.getAPI(Constants().apiVersion + 'diagnostic_infos/' + id, NewsModel(), hasHeader: false);

  Future<BaseResponse> getHandbookDetail(id) => apiClient.getAPI(Constants().apiVersion + 'knowledge_handbooks/' + id, HandbookModel(), hasHeader: false);

  Future<BaseResponse> getTechProcessDetail(id) => apiClient.getAPI(Constants().apiVersion + 'technical_processes/' + id, TechnicalProcessModel());

  Future<String> getExpertDetail(id) => apiClient.getAPI2(Constants().apiVersion + 'experts/' + id, hasHeader: Constants().isLogin);
  
  Future<String> checkProductReferralPoint(id, referralCode) => apiClient.getAPI2(Constants().apiVersion + 'products/$id/check_referral_status?referral_code=$referralCode');
}