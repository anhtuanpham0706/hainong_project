import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/features/login/login_model.dart';

class SignUpRepository extends BaseRepository {
  Future<BaseResponse> requireOTP(String loginKey) {
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

  Future<BaseResponse> signUp(
    String fullName,
    String birthday,
    String gender,
    String referrarType,
    String referrarCode,
    String email,
    String phoneNumber,
    String password,
    String repeatPassword,
    String imagePath,
    String deviceId,
    String term
  ) {
    List<String> files = [];
    if (imagePath.isNotEmpty) files.add(imagePath);

    return apiClient.postAPI('${Constants().apiVersion}account/register', 'POST', LoginModel(),
        hasHeader: false,
        body: {
          'name': fullName,
          'birthdate': birthday,
          'gender': gender,
          'referral_type': referrarType,
          'referral_code': referrarCode,
          'email': email,
          'phone': phoneNumber,
          'password': password,
          'password_confirmation': repeatPassword,
          'device_id': deviceId,
          'term': term
        },
        files: files,
        paramFile: 'image');
  }

  String _listToStringJson(List<ItemModel> list, String sub) {
    String tmp = "[";
    list.forEach((element) => tmp += "$sub${element.id}$sub,");
    tmp += "]";
    return tmp.replaceAll(",]", "]");
  }

  Future<BaseResponse> signUpNext(
      String website,
      String address,
      String province,
      String district,
      List<ItemModel> userTypes,
      List<ItemModel> hashTags,
      String image) async {
    List<String> files = [];
    if (image.isNotEmpty) files.add(image);

    String _userTypes = _listToStringJson(userTypes, "\"");
    String _hashTags = _listToStringJson(hashTags, "");

    final body = {
      'website': website,
      'address': address,
      'province_id': province,
      'district_id': district,
      'user_type': _userTypes,
      'hash_tags': _hashTags,
    };

    final response = await apiClient.postAPI('${Constants().apiVersion}account/update_user', 'POST', LoginModel(),
        body: body, files: files, paramFile: 'image');
    return response;
  }

  Future<BaseResponse> updateProfile(String image, String fullName, String phone, String birthday, String gender,
      String email, String website, String address, String province, String district, List<ItemModel> userTypes,
      List<ItemModel> hashTags, List<ItemModel> trees, String acreage) async {
    List<String> files = [];
    if (image.isNotEmpty) files.add(image);

    String _userTypes = _listToStringJson(userTypes, '"');
    String _hashTags = _listToStringJson(hashTags, '');
    String _trees = _listToStringJson(trees, '"');

    final body = {
      'name': fullName,
      'phone': phone,
      'birthdate': birthday,
      'gender': gender,
      'email': email,
      'website': website,
      'address': address,
      'province_id': province,
      'district_id': district,
      'user_type': _userTypes,
      'hash_tags': _hashTags,
      'family_tree': _trees,
      'acreage': acreage
    };

    final response = await apiClient.postAPI('${Constants().apiVersion}account/update_user', 'POST', LoginModel(),
        body: body, files: files, paramFile: 'image');
    return response;
  }

  Future<BaseResponse> loadProvince() => apiClient.getAPI('${Constants().apiVersion}locations/list_provinces', ItemListModel(), hasHeader: false);

  Future<BaseResponse> loadDistrict(String id) => apiClient.getAPI('${Constants().apiVersion}locations/list_districts?province_id=$id', ItemListModel(), hasHeader: false);

  Future<BaseResponse> updatePassword(String loginKey, String pass, String otp) =>
      apiClient.postAPI(
        '${Constants().apiVersion}account/update_password',
        'POST',
        LoginModel(),
        hasHeader: false,
        body: {'loginkey': loginKey, 'password': pass, 'verify_code': otp},
      );

  Future<BaseResponse> loadProfile() => apiClient.getAPI('${Constants().apiVersion}account/profile', LoginModel());

  Future<BaseResponse> loadCatalogue(int page, {int? limit}) {
    limit ??= Constants().limitLargePage;
    return apiClient.getAPI('${Constants().apiVersion}catalogues/post_catalogues?page=$page&limit=$limit',
        ItemListModel(), hasHeader: false);
  }

  Future<BaseResponse> sendContact(String name, String phone, String email, String content) =>
      apiClient.postAPI('${Constants().apiVersion}contacts', 'POST', BaseResponse(),
        body: {'name': name, 'phone': phone, 'email': email, 'content': content});
}
