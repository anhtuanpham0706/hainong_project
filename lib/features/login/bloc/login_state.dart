import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';

class LoginState extends BaseState {
  final bool isShowPassword;
  final bool isRememberPassword;
  const LoginState({isShowLoading = false, this.isShowPassword = false, this.isRememberPassword = false}) : super(isShowLoading: isShowLoading);
}

class ShowPasswordLoginState extends LoginState {
  const ShowPasswordLoginState({isShowLoading = false, isShowPassword, isRememberPassword}) : super(isShowLoading: isShowLoading, isShowPassword: isShowPassword, isRememberPassword: isRememberPassword);
}

class RememberPasswordLoginState extends LoginState {
  const RememberPasswordLoginState({isShowLoading = false, isShowPassword, isRememberPassword}) : super(isShowLoading: isShowLoading, isShowPassword: isShowPassword, isRememberPassword: isRememberPassword);
}

class ForgetPasswordLoginState extends ResponseLoginState {
  const ForgetPasswordLoginState({isShowLoading = false, isShowPassword, isRememberPassword, response}) : super(isShowLoading: isShowLoading, isShowPassword: isShowPassword, isRememberPassword: isRememberPassword, response: response);
}

class VerifyCodeLoginState extends ResponseLoginState {
  final String otp;
  const VerifyCodeLoginState(this.otp, {isShowLoading = false, isShowPassword, isRememberPassword, response}) : super(isShowLoading: isShowLoading, isShowPassword: isShowPassword, isRememberPassword: isRememberPassword, response: response);
}

class SaveDeviceLoginState extends ResponseLoginState {
  final bool? isFinger;
  const SaveDeviceLoginState({isShowLoading = false, isShowPassword, isRememberPassword, response, this.isFinger}) : super(isShowLoading: isShowLoading, isShowPassword: isShowPassword, isRememberPassword: isRememberPassword, response: response);
}

class ResponseLoginState extends LoginState {
  final BaseResponse? response;
  const ResponseLoginState({isShowLoading = false, isShowPassword, isRememberPassword, this.response}) : super(isShowLoading: isShowLoading, isShowPassword: isShowPassword, isRememberPassword: isRememberPassword);
}

class ShowFingerLoginState extends LoginState {}

class FingerprintLoginState extends LoginState {
  final String result;
  const FingerprintLoginState(this.result);
}

class FocusTextLoginState extends LoginState {
  final bool value;
  const FocusTextLoginState(this.value, bool isShowPassword, bool isRememberPassword) : super(isShowPassword: isShowPassword, isRememberPassword: isRememberPassword);
}