import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'model/diagnostic_history_model.dart';
import 'model/diagnostic_model.dart';
import 'model/plant_model.dart';

class DiagnosePestsRepository extends BaseRepository {

  Future<BaseResponse> uploadFileDiagnostic(List<FileByte> files, String catalogue, String lat, String lng) async {
    final body = {
      if (catalogue.isNotEmpty) 'category_id': catalogue,
      'lat':lat,
      'lng':lng
    };
    return apiClient.postAPI('${Constants().apiVersion}diagnostics/ai${catalogue.isEmpty ? '_auto' : ''}', 'POST', DiagnosticModel(), realFiles: files,
        paramFile: 'images[]', body: body);
  }

  Future<BaseResponse> loadCatalogue({bool passUnknown = false}) => apiClient.getAPI('${Constants().apiVersion}diagnostics/categories', PlantsModel(passUnknown: passUnknown), hasHeader: false);

  Future<BaseResponse> loadDiagnostic() => apiClient.getAPI('${Constants().apiVersion}diagnostics', ItemListModel(keyName: 'name_vi'), hasHeader: false);

  Future<BaseResponse> loadListPlant() => apiClient.getAPI('${Constants().apiVersion}/category_trees?cat_ai=all_cat',  ItemListModel(), hasHeader: false);

  Future<BaseResponse> loadDiagnosticHistory(int page,String planId, String? diagnosticId) {
    final _diagnosticId = (diagnosticId?? '').isNotEmpty ? 'diagnostic_ids[]=$diagnosticId&':'';
    final _planId = (planId?? '').isNotEmpty ? 'category_ids[]=$planId&':'';
    final path = '${Constants().apiVersion}diagnostics/histories?$_diagnosticId${_planId}page=$page&''limit=${Constants().limitPage}';
    return apiClient.getAPI(path, DiagnosticHistoriesModel());
  }

  Future<BaseResponse> rating(int rate, String content, List? ids, String diagnosticId) async {
    String temp = '';
    if (ids != null) {
      for (var ele in ids) {
        temp += '&training_data_ids[]=' + ele.toString();
      }
    }
    if (diagnosticId.isNotEmpty) temp+='&diagnostic_id=$diagnosticId';
    final path = Constants().apiVersion + 'diagnostics/ratings?rate=$rate&content='+content+temp;
    return apiClient.postAPI(path, 'POST', BaseResponse());
  }

  Future<BaseResponse> createDiagnosticContribute(List<FileByte> files, String province_id, String district_id,
      String address, String tree_name, String pest_name, String description, String lat, String lng) {
    final body =
    {'province_id': province_id,
      'district_id': district_id,
      'address': address,
      'tree_name': tree_name,
      'pest_name': pest_name,
      'description': description,
      'lat': lat,
      'lng': lng
    };
    return apiClient.postAPI(
        '${Constants().apiVersion}training_contribution_data',
        'POST',
        BaseResponse(),
        realFiles: files,
        paramFile: 'attachment[file][]',
        body: body);
  }
}