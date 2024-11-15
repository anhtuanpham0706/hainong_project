import 'package:hainong/common/base_bloc.dart';

class LoginEvent extends BaseEvent {}

class ShowPasswordLoginEvent extends LoginEvent {
  final bool isShowPassword;
  ShowPasswordLoginEvent(this.isShowPassword);
}

class RememberPasswordLoginEvent extends LoginEvent {
  final bool isRememberPassword;
  RememberPasswordLoginEvent(this.isRememberPassword);
}

class ForgetPasswordLoginEvent extends LoginEvent {
  final String loginKey;
  ForgetPasswordLoginEvent(this.loginKey);
}

class VerifyCodeLoginEvent extends LoginEvent {
  final String otpCode;
  VerifyCodeLoginEvent(this.otpCode);
}

class OnClickLoginEvent extends LoginEvent {
  final String loginKey;
  final String password;
  final String deviceId;
  OnClickLoginEvent(this.loginKey, this.password, this.deviceId);
}

class SaveDeviceLoginEvent extends LoginEvent {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String osVersion;
  final String appVersion;
  final String deviceToken;
  final String apnsTopic;
  final String appleNoticeToken;
  final bool isFinger;
  SaveDeviceLoginEvent(this.deviceId, this.deviceName, this.deviceType, this.osVersion, this.appVersion, this.deviceToken, this.isFinger, this.apnsTopic, this.appleNoticeToken);
}

class LoadShopLoginEvent extends LoginEvent {}

class ShowFingerLoginEvent extends LoginEvent {}

class FingerprintLoginEvent extends LoginEvent {}

class FocusTextLoginEvent extends LoginEvent {
  final bool value;
  FocusTextLoginEvent(this.value);
}

class ShowLoadingLoginEvent extends LoginEvent {
  final bool value;
  ShowLoadingLoginEvent({this.value = true});
}

class SignInOthersEvent extends BaseEvent {
  final String type, zaloCode, codeVerifier;
  SignInOthersEvent(this.type, {this.zaloCode = '', this.codeVerifier = ''});
}
