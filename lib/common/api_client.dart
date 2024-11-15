import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hainong/common/util/util.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'base_response.dart';
import 'constants.dart';
import 'database_helper.dart';
import 'models/file_byte.dart';
import 'multi_language.dart';
import 'dart:developer' as logDev;

class ApiClient {
  final httpClient = http.Client();

  static ApiClient? _instance;

  ApiClient._();

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Future<void> _log(String url, String method, String response, {dynamic header, dynamic request}) async {
    return;
    if (!(await DBHelperUtil().hasLogFile())) return;
    String temp = '\n\nadvn-time: ' + DateTime.now().toString() + '\nadvn-url $method: ' + url;
    if (header != null) temp += '\nadvn-header: ' + header.toString();
    if (request != null) temp += '\nadvn-request: ' + request.toString();
    temp += '\nadvn-response: $response\n\n';
    logDev.log(temp);
    Util().logFile(temp);
  }

  Future<BaseResponse> getAPI(String url, data, {bool hasHeader = true, int timeout = 20, bool fullPath = false}) async {
    final baseResponse = BaseResponse();
    try {
      http.Response response;
      final Uri uri = Uri.parse(fullPath ? url : (Constants().baseUrl + url));
      if (hasHeader && Constants().isLogin)
        response = await http.Client().get(uri, headers: await _getHeader()).timeout(Duration(seconds: timeout));
      else
        response = await http.Client().get(uri).timeout(Duration(seconds: timeout));
      _log(uri.toString(), 'GET', response.body);
      baseResponse.fromJson(jsonDecode(response.body), data);
    } catch (e) {
      return _responseError(baseResponse, e);
    }
    return baseResponse;
  }

  Future<BaseResponse> postAPI(
    String url,
    String method,
    data, {
    bool hasHeader = true,
    bool fullPath = false,
    int timeout = 50,
    Map<String, String>? body,
    List<String>? files,
    List<FileByte>? realFiles,
    String paramFile = 'attachment[file][]',
  }) async {
    final baseResponse = BaseResponse();
    try {
      final uri = Uri.parse(fullPath ? url : (Constants().baseUrl + url));
      final request = http.MultipartRequest(method, uri);

      if (hasHeader) request.headers.addAll(await _getHeader());

      if (body != null) request.fields.addAll(body);

      if (files != null && files.isNotEmpty) {
        for (String path in files) request.files.add(_createPartFile(File(path), paramFile));
      } else if (realFiles != null) {
        for (FileByte file in realFiles) request.files.add(_createPartFileByte(file, paramFile));
      }

      final streamResponse =
          await request.send().timeout(Duration(seconds: request.files.isEmpty ? timeout : Constants().timeout));
      final response = await http.Response.fromStream(streamResponse);
      _log(uri.toString(), method, response.body, request: body);
      baseResponse.fromJson(jsonDecode(response.body), data);
    } catch (e) {
      return _responseError(baseResponse, e);
    }
    return baseResponse;
  }

  Future<void> trackApp(String path, String function, {String method = 'onTap'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final device = prefs.getString('device_id') ?? '';
      final user = prefs.getInt('id') ?? -1;

      final headers = {'Content-Type': 'application/json; charset=utf-8'};
      http.post(Uri.parse(Constants().baseUrlIPortal + '/ssos/v1/track_activities'),
              headers: headers,
              body: jsonEncode({
                'device_id': device,
                'user_id': user,
                'main_function': function,
                'client_key': '7459fbbd78f4f9971d0507ccec6963e08e0bf8be',
                'payload': {
                  'method': method,
                  'path': path,
                  'params': {'env': 'App - ${Platform.isAndroid ? 'Android' : 'iOS'}'}
                }
              })).timeout(const Duration(seconds: 10));
      /*.then((response) {
        logDev.log('track url: ' + Constants().baseUrlIPortal + '/ssos/v1/track_activities');
        logDev.log('track params: ' + {'device_id': device, 'user_id': user,
          'payload': {'method': method, 'path': path, 'params': params
          }}.toString());
        logDev.log('track response: ' + response.body);
      });*/
    } catch (_) {}
  }

  Future<BaseResponse> _responseError(BaseResponse baseResponse, error) async {
    String? temp;
    switch(error.runtimeType.toString()) {
      case 'FormatException': temp = 'Tính năng đang bảo trì'; break;
      case 'TimeoutException': temp = 'Hệ thống bị quá tải vui lòng thực hiện lại sau'; break;
      case 'SocketException':
      case '_ClientSocketException':
        String html = await ApiClient().getString('https://google.com', timeout: 5);
        temp = html.isEmpty ? 'Lỗi không kết nối, kiểm tra internet của bạn' : 'Hệ thống đang bảo trì';
    }
    baseResponse.setDataError(error: temp);
    return baseResponse;
  }

  Future<Map<String, String>> _getHeader() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token_user') ?? '';
    if (token.isEmpty) return {};
    //logDev.log(token);
    return {'Authorization': token};
  }

  Future<String> getString(String url, {int timeout = 20}) async {
    try {
      final uri = Uri.parse(url);
      final response = await httpClient.get(uri).timeout(Duration(seconds: timeout));
      _log(uri.toString(), 'GET', response.body);
      if (response.statusCode == 200) return response.body;
    } catch (_) {}
    return '';
  }

  Future<String> getAPI2(String url, {int timeout = 20, bool hasHeader = true}) async {
    try {
      http.Response response;
      final uri = Uri.parse(Constants().baseUrl + url);
      if (hasHeader && Constants().isLogin)
        response = await http.Client().get(uri, headers: await _getHeader()).timeout(Duration(seconds: timeout));
      else
        response = await http.Client().get(uri).timeout(Duration(seconds: timeout));

      _log(uri.toString(), 'GET', response.body);
      if (response.statusCode == 200) return response.body;
    } catch (_) {}
    return '';
  }

  Future<String> postAPI2(String url,
      {int timeout = 20,
      String method = 'POST',
      Map<String, String>? body,
      Map<String, String>? header,
      bool hasHeader = true}) async {
    try {
      final uri = Uri.parse(Constants().baseUrl + url);
      final request = http.MultipartRequest(method, uri);
      if (hasHeader) request.headers.addAll(await _getHeader());
      if (header != null) request.headers.addAll(header);
      if (body != null) request.fields.addAll(body);
      final streamResponse = await request.send().timeout(Duration(seconds: timeout));
      final response = await http.Response.fromStream(streamResponse);
      _log(uri.toString(), 'POST', response.body, request: body, header: header);
      if (response.statusCode == 200) return response.body;
    } catch (_) {}
    return '';
  }

  Future<BaseResponse> postJsonAPI(String path, data, body,
      {bool hasHeader = true, bool hasDomain = true, int timeout = 20, String method = 'POST'}) async {
    final baseResponse = BaseResponse();
    try {
      final headers = {'Content-Type': 'application/json', 'accept': '*/*'};
      if (hasHeader && Constants().isLogin) headers.addAll(await _getHeader());
      final url = Uri.parse(Constants().baseUrl + path);

      late http.Response response;
      if (method == 'POST') {
        response = await http.post(url, headers: headers, body: jsonEncode(body)).timeout(Duration(seconds: timeout));
      } else if (method == 'DELETE') {
        response = await http.delete(url, headers: headers, body: jsonEncode(body)).timeout(Duration(seconds: timeout));
      } else if(method == 'PUT') {
        response = await http.put(url, headers: headers, body: jsonEncode(body)).timeout(Duration(seconds: timeout));
      } else {
        response = await http.patch(url, headers: headers, body: jsonEncode(body)).timeout(Duration(seconds: timeout));
      }
      _log(url.toString(), method, response.body, request: body, header: headers);
      baseResponse.fromJson(jsonDecode(response.body), data);
    } catch (e) {
      return _responseError(baseResponse, e);
    }
    return baseResponse;
  }


  Future<BaseResponseTranslate> postAPIResponseTranslate(
      String url,
      String method,
      data, {
        bool hasHeader = true,
        bool fullPath = false,
        int timeout = 20,
        Map<String, String>? body,
        List<String>? files,
        List<FileByte>? realFiles,
        String paramFile = 'attachment[file][]',
      }) async {
    final baseResponse = BaseResponseTranslate();
    try {
      final uri = Uri.parse(fullPath ? url : (Constants().baseUrl + url));
      final request = http.MultipartRequest(method, uri);

      if (hasHeader) request.headers.addAll(await _getHeader());

      if (body != null) request.fields.addAll(body);

      if (files != null && files.isNotEmpty) {
        for (String path in files) request.files.add(_createPartFile(File(path), paramFile));
      } else if (realFiles != null) {
        for (FileByte file in realFiles) request.files.add(_createPartFileByte(file, paramFile));
      }

      final streamResponse =
      await request.send().timeout(Duration(seconds: request.files.isEmpty ? timeout : Constants().timeout));
      final response = await http.Response.fromStream(streamResponse);
      _log(uri.toString(), method, response.body, request: body);
      baseResponse.fromJson(jsonDecode(response.body), data);
    } catch (e) {
      return _responseErrorResponseTranslate(baseResponse, e);
    }
    return baseResponse;
  }

  BaseResponseTranslate _responseErrorResponseTranslate(BaseResponseTranslate baseResponse, error) {
    error.runtimeType.toString() == 'SocketException'
        ? baseResponse.setDataError(error: MultiLanguage.get('msg_network_error'))
        : baseResponse.setDataError();
    return baseResponse;
  }

  http.MultipartFile _createPartFile(File file, String paramFile) =>
      _getMultipartFile(paramFile, file.path.split('/').last, file.readAsBytesSync());

  http.MultipartFile _createPartFileByte(FileByte file, String paramFile) =>
      _getMultipartFile(paramFile, file.name.split('/').last, file.bytes);

  http.MultipartFile _getMultipartFile(String paramFile, String fileName, List<int> bytes) =>
      http.MultipartFile.fromBytes(paramFile, bytes,
          filename: fileName, contentType: Util.isImage(fileName) ? MediaType("image", "*") : MediaType("video", "*"));

  /// path = 'path1/path2?' => no domain and api version (https://panel.hainong.vn/api/v2/)
  /// path = 'path1/path2?param1=xxx&param2=xxx&' => no domain and api version (https://panel.hainong.vn/api/v2/)
  /// isOnePage = false => will get all from current page to last page
  Future<List> getList(String path, {int page = 1, int limit = 50, bool isOnePage = false}) async {
    dynamic resp;
    List temp;
    final List list = [];
    Map<String, dynamic> json;
    while (page > 0) {
      resp = await getAPI2(Constants().apiVersion + path + 'page=$page&limit=$limit');
      if (resp.isNotEmpty) {
        try {
          json = jsonDecode(resp);
          if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success'] && json['data'] is List) {
            temp = json['data'].toList();
            temp.isNotEmpty ? list.addAll(temp) : page = 0;
            temp.length == limit ? page++ : page = 0;
          } else page = 0;
        } catch (_) {page = 0;}
      } else page = 0;
      if (isOnePage) return list;
    }
    return list;
  }

  Future<dynamic> getData(String path, {bool hasHeader = true, bool getError = false}) async {
    final resp = await getAPI2(Constants().apiVersion + path, hasHeader: hasHeader);
    return getDataFromString(resp, getError: getError);
  }

  Future<dynamic> getDataFromString(String value, {bool getError = false}) async {
    if (value.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(value);
      if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) return json['data'];
      if (getError) return {'error': json['data'].toString()};
    }
    return null;
  }

  Future<String> checkVersion() async {
    final response = await getString(Constants().baseUrl+'/api/v2/base/option?key=update_version');
    if (response.isNotEmpty) {
      int versionApp = int.parse((await PackageInfo.fromPlatform()).version.replaceAll('.', ''));
      int version = 0;
      try {
        final json = jsonDecode(response);
        if (Util.checkKeyFromJson(json, 'success')) {
          final data = json['data'][0];
          version = int.parse((data['value']??'0').replaceAll('.', ''));
        }
      } catch (_) {}
      if (version > versionApp) {
        return (Platform.isIOS ? 'http://apps.apple.com/app/id1540198381' : 'https://play.google.com/store/apps/details?id=com.advn.hainong');
      }
    }
    return '';
  }
}
