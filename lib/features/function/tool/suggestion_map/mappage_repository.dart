import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import '../diagnose_pests/model/plant_model.dart';
import 'suggest_model.dart';

class MapPageRepository extends BaseRepository {
  Future<BaseResponse> loadSuggestions() => apiClient.getAPI('${Constants().apiVersion}diagnostics/pets_map', SuggestionList(), hasHeader: false);

  Future<BaseResponse> loadMapKey() => apiClient.getAPI('${Constants().apiVersion}base/option?key=maptitles_key', Options(), hasHeader: false);

  Future<BaseResponse> loadDiagnostics() => apiClient.getAPI('${Constants().apiVersion}diagnostics', ItemListModel(keyName: 'name_vi'), hasHeader: false);

  Future<BaseResponse> loadDiagnostics2() => apiClient.getAPI('${Constants().apiVersion}diagnostics/categories', PlantsModel(passUnknown: true), hasHeader: false);

  Future<BaseResponse> loadProvinces() => apiClient.getAPI('${Constants().apiVersion}locations/list_provinces', ItemListModel(), hasHeader: false);
}
