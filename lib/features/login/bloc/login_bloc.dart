import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zalo_flutter/zalo_flutter.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/language_key.dart';
import 'package:hainong/common/local_auth_api.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/shop/shop_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_model.dart';
import '../login_repository.dart';
import 'login_event.dart';
import 'login_state.dart';
export 'login_event.dart';
export 'login_state.dart';

class LoginBloc extends BaseBloc {
  final LoginRepository repository = LoginRepository();

  LoginBloc({LoginState init = const LoginState()}) : super(init: init) {
    on<ShowPasswordLoginEvent>((event, emit) {
      emit(ShowPasswordLoginState(isShowPassword: event.isShowPassword, isRememberPassword: (state as LoginState).isRememberPassword));
    });
    on<RememberPasswordLoginEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(Constants().isRemember, event.isRememberPassword);
      emit(RememberPasswordLoginState(
          isShowPassword: (state as LoginState).isShowPassword,
          isRememberPassword: event.isRememberPassword));
    });
    on<VerifyCodeLoginEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleVerifyCode(event));
    });
    on<ForgetPasswordLoginEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleForgetPassword(event));
    });
    on<SaveDeviceLoginEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleSaveDevice(event));
    });
    on<OnClickLoginEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleOnClickLogin(event));
    });
    on<LoadShopLoginEvent>((event, emit) { _handleLoadShop(); });
    on<ShowFingerLoginEvent>((event, emit) => emit(ShowFingerLoginState()));
    on<FingerprintLoginEvent>((event, emit) async {
      final constant = Constants();
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(constant.loginKeyFinger) &&
          prefs.containsKey(constant.passwordFinger) &&
          prefs.getString(constant.loginKeyFinger)!.isNotEmpty &&
          prefs.getString(constant.passwordFinger)!.isNotEmpty) {
        final isAuth = await LocalAuthApi.authenticate();
        if (isAuth) emit(const FingerprintLoginState(''));
      } else {
        emit(const FingerprintLoginState('msg_not_setting_finger'));
      }
    });
    on<FocusTextLoginEvent>((event, emit) => emit(FocusTextLoginState(event.value, (state as LoginState).isShowPassword,
        (state as LoginState).isRememberPassword)));
    on<ShowLoadingLoginEvent>((event, emit) => emit(_showLoading(show: event.value)));
    on<SignInOthersEvent>((event, emit) async {
      try{
      emit(LoginState(isShowLoading: true,isShowPassword: (state as LoginState).isShowPassword,
          isRememberPassword: (state as LoginState).isRememberPassword));
      final Map<String, String> info = await UtilUI.getDeviceInfo();
      if (info['imei']!.isEmpty) {
        await FirebaseMessaging.instance.deleteToken();
        emit(ResponseLoginState(isShowPassword: (state as LoginState).isShowPassword, isRememberPassword: (state as LoginState).isRememberPassword,
            response: BaseResponse(data: MultiLanguage.get(LanguageKey().msgErrorGetDeviceId))));
        return;
      }

      final response = await _saveDevice(info);
      if (response.checkOK(passString: true)) {
        String? token;
        switch(event.type) {
          case 'facebook': token = await signInWithFaceBook(); break;
          case 'google': token = await signInWithGoogle(); break;
          case 'zalo': token = await signInWithZalo(); break;
          case 'apple': token = await signInWithAppleID(); break;
        }
        if (token != null && token.isNotEmpty) {
          //DBHelperUtil().hasLogFile().then((value) => value ? Util().logFile('\n\nToken other: ' + token!) : '');
          emit(LoginState(isShowLoading: true,isShowPassword: (state as LoginState).isShowPassword,
              isRememberPassword: (state as LoginState).isRememberPassword));
          final resp = await ApiClient().postAPI(Constants().baseUrlIPortal + '/ssos/v1/auths/login_social', 'POST',
              LoginModel(), body: {
                'partner_type': event.type,
                'partner_token': token,
                'device_id': info['imei']!
              }, fullPath: true, hasHeader: false);
          emit(ResponseLoginState(isShowPassword: (state as LoginState).isShowPassword,
              isRememberPassword: (state as LoginState).isRememberPassword, response: resp));
        } else {
          //DBHelperUtil().hasLogFile().then((value) => value ? Util().logFile('\n\nLogin other error: token is empty') : '');
          emit(LoginState(isShowPassword: (state as LoginState).isShowPassword,
            isRememberPassword: (state as LoginState).isRememberPassword));
        }
      } else { emit(ResponseLoginState(isShowPassword: (state as LoginState).isShowPassword,
        isRememberPassword: (state as LoginState).isRememberPassword, response: response)); }
      } catch(e) {
        //DBHelperUtil().hasLogFile().then((value) => value ? Util().logFile('\n\nLogin other error: ' + e.toString()) : '');
        emit(LoginState(isShowPassword: (state as LoginState).isShowPassword,
            isRememberPassword: (state as LoginState).isRememberPassword));
      }
    });
  }

  Future<String> signInWithAppleID() => SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ]
  ).then((appleIdCredential) async {
    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode
    );

    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.user != null) {
      return appleIdCredential.identityToken??'';
    }
    return '';
  }).onError((error, stackTrace) => '').catchError((error) => '');

  Future<String> signInWithFaceBook() =>
      FacebookAuth.i.login(loginBehavior: LoginBehavior.webOnly).then((LoginResult account) async {
        if (account.status == LoginStatus.success) {
          final token = await FacebookAuth.i.accessToken;
          if (token != null) return token.token;
          return '';
        }
        return '';
      }).onError((error, stackTrace) => '').catchError((error) => '');

  Future<String> signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
      'email',
    ]);
    final account = await _googleSignIn.signIn();
    if (account != null) return (await account.authentication).idToken??'';
    return '';
  }

  Future<String> signInWithZalo({int isFirst = 0}) async {
    try {
      ZaloFlutter.setTimeout(Duration(seconds: isFirst == 0 ? 30 : 90));
      final Map<dynamic, dynamic>? data = await ZaloFlutter.login();
      if (data != null && data['isSuccess'] == true) {
        if(Platform.isAndroid) {
          return data['data']['access_token']??'';
        } else {
          return data['data']['accessToken']??'';
        }
      } else if (data != null) {
        //DBHelperUtil().hasLogFile().then((value) => value ? Util().logFile('\n\nZalo error: ' + data.toString()) : '');
      }
    } catch (e) {
      //DBHelperUtil().hasLogFile().then((value) => value ? Util().logFile('\n\nZalo error: ' + e.toString()) : '');
    }
    if (isFirst == 0) return signInWithZalo(isFirst: isFirst + 1);
    return '';
  }

  Future<BaseResponse> _saveDevice(Map<String, String> info) =>
    repository.saveDevice(info['imei']!, info['name']!, info['type']!, info['os']!, info['version']!, info['token']!, info['apns_topic']!, info['apple_notice_token']!);

  LoginState _showLoading({bool show = true}) =>
    LoginState(isShowLoading: show, isShowPassword: (state as LoginState).isShowPassword, isRememberPassword: (state as LoginState).isRememberPassword);

  Future<ForgetPasswordLoginState> _handleForgetPassword(ForgetPasswordLoginEvent event) async {
    final resp = await repository.forgetPassword(event.loginKey);
    return ForgetPasswordLoginState(isShowPassword: (state as LoginState).isShowPassword,
        isRememberPassword: (state as LoginState).isRememberPassword, response: resp);
  }

  Future<VerifyCodeLoginState> _handleVerifyCode(VerifyCodeLoginEvent event) async {
    final resp = await repository.verifyCode(event.otpCode);
    return VerifyCodeLoginState(event.otpCode, isShowPassword: (state as LoginState).isShowPassword,
        isRememberPassword: (state as LoginState).isRememberPassword, response: resp);
  }

  Future<ResponseLoginState> _handleOnClickLogin(OnClickLoginEvent event) async {
    final resp = await repository.login(event.loginKey, event.password, event.deviceId);
    return ResponseLoginState(isShowPassword: (state as LoginState).isShowPassword,
        isRememberPassword: (state as LoginState).isRememberPassword, response: resp);
  }

  Future<ResponseLoginState> _handleSaveDevice(SaveDeviceLoginEvent event) async {
    final resp = await repository.saveDevice(event.deviceId, event.deviceName, event.deviceType, event.osVersion, event.appVersion, event.deviceToken, event.apnsTopic, event.appleNoticeToken);
    return SaveDeviceLoginState(isShowPassword: (state as LoginState).isShowPassword,
        isRememberPassword: (state as LoginState).isRememberPassword, response: resp, isFinger: event.isFinger);
  }

  void _handleLoadShop() => repository.loadShop().then((resp) {
    resp.success && resp.data is ShopModel ? _setShop(resp.data) : _setShop(ShopModel());
  });

  void _setShop(ShopModel shop) => SharedPreferences.getInstance().then((prefs) {
      final Constants constants = Constants();
      prefs.setInt(constants.shopId, shop.id);
      prefs.setString(constants.shopName, shop.name);
      prefs.setString(constants.shopEmail, shop.email);
      prefs.setString('shop_address', shop.address);
      prefs.setString(constants.shopPhone, shop.phone);
      prefs.setString(constants.shopProvinceId, shop.province_id);
      prefs.setString(constants.shopProvinceName, shop.province_name);
      prefs.setString(constants.shopDistrictId, shop.district_id);
      prefs.setString(constants.shopDistrictName, shop.district_name);
      prefs.setString(constants.shopWebsite, shop.website);
      prefs.setString(constants.shopFacebook, shop.facebook);
      prefs.setString(constants.shopDescription, shop.description);
      prefs.setInt(constants.shopStar, shop.shop_star);
      prefs.setString(constants.shopImage, shop.image);
      prefs.setString('shop_background_image', shop.background_image);
  });
}
