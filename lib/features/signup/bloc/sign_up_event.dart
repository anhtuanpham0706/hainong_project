import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/models/item_list_model.dart';

abstract class SignUpEvent extends BaseEvent {}

class FocusTextEvent extends SignUpEvent {
  final bool value;
  FocusTextEvent(this.value);
}

class ChangeTermEvent extends SignUpEvent {
  final int value;
  ChangeTermEvent(this.value);
}

class ChangeCurrentPasswordEvent extends SignUpEvent {
  final String password, password_confirmation, current_password;
  ChangeCurrentPasswordEvent(this.current_password,this.password,this.password_confirmation);
}

class RequireOTPSignUpEvent extends SignUpEvent {
  final String phone;
  RequireOTPSignUpEvent(this.phone);
}

class VerifyCodeSignUpEvent extends SignUpEvent {
  final String otpCode, phone;
  VerifyCodeSignUpEvent(this.otpCode, this.phone);
}

class ShowPasswordSignUpEvent extends SignUpEvent {
  final bool isShowPassword;
  ShowPasswordSignUpEvent(this.isShowPassword);
}

class ShowCurrentPasswordEvent extends SignUpEvent {
  final bool isShowCurrentPassword;
  ShowCurrentPasswordEvent(this.isShowCurrentPassword);
}

class ShowRepeatPasswordSignUpEvent extends SignUpEvent {
  final bool isShowRepeatPassword;
  ShowRepeatPasswordSignUpEvent(this.isShowRepeatPassword);
}

class LoadImageSignUpEvent extends SignUpEvent {}

class AddDeleteUserTypeSignUpEvent extends SignUpEvent {}

class AddDeleteHashTagSignUpEvent extends SignUpEvent {}

class LoadCatalogueSignUpEvent extends SignUpEvent {
  final int page;
  LoadCatalogueSignUpEvent(this.page);
}

class LoadProvinceSignUpEvent extends SignUpEvent {}

class LoadDistrictSignUpEvent extends SignUpEvent {
  final String provinceId;
  LoadDistrictSignUpEvent(this.provinceId);
}

class LoadProfileSignUpEvent extends SignUpEvent {}

class OnClickSignUpEvent extends SignUpEvent {
  final String fullName,
      birthday,
      email,
      referrarType,
      referrarCode,
      gender,
      phoneNumber,
      password,
      repeatPassword,
      imagePath,
      deviceId,
      term;
  OnClickSignUpEvent(
      this.fullName,
      this.birthday,
      this.email,
      this.referrarType,
      this.referrarCode,
      this.gender,
      this.phoneNumber,
      this.password,
      this.repeatPassword,
      this.imagePath,
      this.deviceId,
      this.term);
}

class OnClickSignUpNextEvent extends SignUpEvent {
  final String website, address, province, district, image;
  final List<ItemModel> userTypes, hashTags;
  OnClickSignUpNextEvent(this.website, this.address, this.province, this.district, this.userTypes, this.hashTags, this.image);
}

class OnClickChangePasswordSignUpEvent extends SignUpEvent {
  final String loginKey, password, otp;
  OnClickChangePasswordSignUpEvent(this.loginKey, this.password, this.otp);
}

class SaveDeviceSignUpEvent extends SignUpEvent {
  final String deviceId, deviceName, deviceType, osVersion, appVersion, deviceToken, apnsTopic, appleNoticeToken;
  SaveDeviceSignUpEvent(this.deviceId, this.deviceName, this.deviceType, this.osVersion, this.appVersion, this.deviceToken, this.apnsTopic, this.appleNoticeToken);
}