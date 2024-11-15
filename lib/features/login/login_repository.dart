import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/device_model.dart';
import 'package:hainong/common/models/shop_model.dart';
import 'login_model.dart';

class LoginRepository extends BaseRepository {

  Future<BaseResponse> saveDevice(String deviceId, String deviceName, String deviceType,
      String osVersion, String appVersion, String deviceToken, String apnsTopic, String appleNoticeToken) {
    return apiClient.postAPI(
      '${Constants().apiVersion}devices',
      'POST',
      DeviceModel(),
      hasHeader: false,
      body: {
        'device_id': deviceId,
        'device_name': deviceName,
        'device_type': deviceType,
        'os_version': osVersion,
        'app_version': appVersion,
        'device_token': deviceToken,
        'apns_topic': apnsTopic,
        'apple_notice_token': appleNoticeToken
      },
    );
  }

  Future<BaseResponse> login(String loginKey, String pass, String deviceId) {
    return apiClient.postAPI(
      '${Constants().apiVersion}account/login',
      'POST',
      LoginModel(),
      hasHeader: false,
      body: {
        'loginkey': loginKey,
        'password': pass,
        'device_id': deviceId
      },
    );
  }

  Future<BaseResponse> forgetPassword(String loginKey) {
    return apiClient.postAPI(
      '${Constants().apiVersion}account/forget_password',
      'POST',
      BaseResponse(),
      hasHeader: false,
      body: {
        'loginkey': loginKey
      },
    );
  }

  Future<BaseResponse> verifyCode(String otpCode) {
    return apiClient.postAPI(
      '${Constants().apiVersion}account/check_verify_code',
      'POST',
      LoginModel(),
      hasHeader: false,
      body: {
        'verify_code': otpCode
      },
    );
  }

  Future<BaseResponse> loadShop() => apiClient.getAPI('${Constants().apiVersion}shops/current_shop', ShopModel());
}