import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/login/login_model.dart';
import '../function/tool/suggestion_map/suggest_model.dart';

class SettingRepository extends BaseRepository {
  Future<BaseResponse> updateSetting(int hiddenPhone, int hiddenEmail, int hiddenToolbar, int autoPlayVideo) =>
      apiClient.postAPI('${Constants().apiVersion}account/update_user', 'POST', LoginModel(),
          body: {
            'hidden_phone': hiddenPhone.toString(),
            'hidden_email': hiddenEmail.toString(),
            'hide_toolbar': hiddenToolbar.toString(),
            'auto_play_video': autoPlayVideo.toString(),
          });

  Future<BaseResponse> delete() => apiClient.postAPI('${Constants().apiVersion}account/destroy_account', 'POST', BaseResponse());

  Future<BaseResponse> loadSetting() => apiClient.getAPI('${Constants().apiVersion}base/option?key=remove_account', Options(), hasHeader: false);
}