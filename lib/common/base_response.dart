import 'multi_language.dart';

class BaseResponse {
  final String _dataInvalidToken = 'Invalid token';
  final String _dataUnAuthorize = 'Unauthorize';
  final String _msgForgetPassword = 'forget_password';
  final String msgCreatePost = 'create post';
  final String msgUpdatePost = 'update post';
  final String msgCreateProduct = 'create_products';
  final String msgUpdateProduct = 'update_products';
  final String msgDeletePost = 'destroy post';
  bool success;
  String msg;
  dynamic data;

  BaseResponse({this.success = false, this.msg = '', this.data});

  BaseResponse fromJson(Map<String, dynamic> json, dynamic data) {
    if (json.containsKey('success')) success = json['success'];
    if (json.containsKey('msg')) msg = json['msg'];
    if (json.containsKey('data')) {
      try {
        this.data = data is BaseResponse ? json['data'].toString()
        : (success ? data.fromJson(json['data']) : json['data'].toString());
      } catch (e) {
        setDataError(error: 'Tính năng đang bảo trì.');
      }
    }
    return this;
  }

  setDataError({String? error}) => data = error??MultiLanguage.get('msg_system_error');

  bool checkOK({bool passString = false}) => (success && (passString || data is! String || msg == _msgForgetPassword));

  bool checkTimeout() => (data is String && (data == _dataInvalidToken || data == _dataUnAuthorize));
}

class BaseResponseTranslate extends BaseResponse {
  dynamic translate;
  dynamic paginate;
  @override
  BaseResponseTranslate fromJson(Map<String, dynamic> json, data,) {
    if (json.containsKey('success')) success = json['success'];
    if (json.containsKey('msg')) msg = json['msg'];
    if (json.containsKey('data')) {
      try {
        this.data = data is BaseResponseTranslate && success ? json['data']
            : (success ? data.fromJson(json['data']) : json['data'].toString());
      } catch (e) {
        setDataError(error: 'Tính năng đang bảo trì');
      }
    }
    if (json.containsKey('translate_data')) {
      try {
        translate = data is BaseResponseTranslate ? json['translate_data']
            : (success ? data.fromJson(json['translate_data']) : json['translate_data'].toString());
      } catch (e) {
        setDataError();
      }
    }
    if (json.containsKey('paginate')) {
      try {
        paginate = data is BaseResponseTranslate ? json['paginate']
            : (success ? data.fromJson(json['paginate']) : json['paginate'].toString());
      } catch (e) {
        setDataError();
      }
    }
    return this;
  }
}
