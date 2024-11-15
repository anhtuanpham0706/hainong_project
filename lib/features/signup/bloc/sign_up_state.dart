import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';

class SignUpState extends BaseState {
  final bool isShowPassword;
  final bool isShowRepeatPassword;
  final bool isShowCurrentPassword;
  const SignUpState({isShowLoading = false, this.isShowPassword = false, this.isShowRepeatPassword = false,this.isShowCurrentPassword = false}) : super(isShowLoading: isShowLoading);
}

class FocusTextState extends SignUpState {
  final bool value;
  FocusTextState(this.value);
}

class ChangeTermState extends SignUpState {
  final int value;
  ChangeTermState(this.value, isShowPassword, isShowRepeatPassword):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword);
}

class ChangeCurrentPasswordState extends SignUpState {
  final BaseResponse response;
  ChangeCurrentPasswordState(this.response);
}

class RequireOTPSignUpState extends SignUpState {
  final BaseResponse response;
  RequireOTPSignUpState(this.response, isShowPassword, isShowRepeatPassword):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword);
}

class VerifyCodeSignUpState extends SignUpState {
  final BaseResponse response;
  VerifyCodeSignUpState(this.response, isShowPassword, isShowRepeatPassword):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword);
}

class ShowPasswordSignUpState extends SignUpState {
  ShowPasswordSignUpState({isShowPassword = false, isShowRepeatPassword = false,isShowCurrentPassword = false}) : super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword,isShowCurrentPassword: isShowCurrentPassword);
}

class ShowRepeatPasswordSignUpState extends SignUpState {
  ShowRepeatPasswordSignUpState({isShowPassword = false, isShowRepeatPassword = false, isShowCurrentPassword = false}) : super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword,isShowCurrentPassword: isShowCurrentPassword);
}
class ShowCurrentPasswordState extends SignUpState {
  ShowCurrentPasswordState({isShowPassword = false, isShowRepeatPassword = false, isShowCurrentPassword = false}) : super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword,isShowCurrentPassword: isShowCurrentPassword);
}

class LoadImageSignUpState extends SignUpState {
  LoadImageSignUpState({isShowPassword, isShowRepeatPassword, response}):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword);
}

class AddDeleteUserTypeSignUpState extends SignUpState {}

class AddDeleteHashTagSignUpState extends SignUpState {}

class LoadCatalogueSignUpState extends ResponseSignUpState {
  final int? nextPage;
  LoadCatalogueSignUpState({this.nextPage, isShowPassword, isShowRepeatPassword, response}):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword, response: response);
}

class LoadProvinceSignUpState extends ResponseSignUpState {
  LoadProvinceSignUpState({isShowLoading = false, isShowPassword, isShowRepeatPassword, response}):super(isShowLoading: isShowLoading,isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword, response: response);
}

class LoadDistrictSignUpState extends ResponseSignUpState {
  LoadDistrictSignUpState({isShowPassword, isShowRepeatPassword, response}):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword, response: response);
}

class ResponseSignUpNextState extends ResponseSignUpState {
  ResponseSignUpNextState({isShowPassword, isShowRepeatPassword, response}):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword, response: response);
}

class SaveDeviceSignUpState extends ResponseSignUpState {
  SaveDeviceSignUpState({isShowPassword, isShowRepeatPassword, response}):super(isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword, response: response);
}

class ResponseSignUpState extends SignUpState {
  final BaseResponse? response;
  ResponseSignUpState({isShowLoading = false, isShowPassword, isShowRepeatPassword, this.response}):super(isShowLoading: isShowLoading, isShowPassword: isShowPassword, isShowRepeatPassword:isShowRepeatPassword);
}

class LoadProfileSignUpState extends SignUpState {
  final BaseResponse response;
  LoadProfileSignUpState(this.response);
}

