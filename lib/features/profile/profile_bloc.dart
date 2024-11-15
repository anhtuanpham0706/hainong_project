import 'dart:convert';

import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/login/login_model.dart';
import 'package:hainong/features/signup/sign_up_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileListener {
  void loadProfile(LoadProfileState state);
}

abstract class ProfileListenerAll extends ProfileListener {
  void handleLoadCatalogue(LoadCatalogueProfileState state);
  void handleLoadDistrict(LoadDistrictProfileState state);
  void handleUpdateProfile(UpdateProfileState state);
  void handleLoadProvince(LoadProvinceProfileState state);
}

class ProfileState extends BaseState {
  final LoginModel? user;

  const ProfileState({this.user, isShowLoading = false}) : super(isShowLoading: isShowLoading);
}

class ChangePhoneEvent extends ProfileEvent{
  String phone;

  ChangePhoneEvent(this.phone);
}

class ChangePhoneState extends ProfileState{
  BaseResponse baseResponse;
  ChangePhoneState(this.baseResponse);
}

class LoadProfileState extends ProfileState {
  final LoginModel user;
  const LoadProfileState(this.user);
}

class VerifyCodePhoneEvent extends ProfileEvent{
  final String otpCode;
  VerifyCodePhoneEvent(this.otpCode);
}

class VerifyCodePhoneState extends ProfileState{
  BaseResponse baseResponse;

  VerifyCodePhoneState(this.baseResponse);
}

class UpdatePhoneEvent extends ProfileEvent{
  String phone;
  UpdatePhoneEvent(this.phone);
}

class UpdatePhoneState extends ProfileState{
  BaseResponse response;

  UpdatePhoneState(this.response);
}

class LoadReferralLinkeState extends ProfileState{
  String link;
  LoadReferralLinkeState(this.link);
}

class LoadImageProfileState extends ProfileState {}

class AddDeleteUserTypeProfileState extends ProfileState {}

class AddDeleteHashTagProfileState extends ProfileState {}

class AddDeleteTreeProfileState extends ProfileState {}

class LoadCatalogueProfileState extends ProfileState {
  final int nextPage;
  final response;
  const LoadCatalogueProfileState(this.response, {required this.nextPage});
}

class LoadProvinceProfileState extends ProfileState {
  final response;
  const LoadProvinceProfileState(this.response);
}

class LoadDistrictProfileState extends ProfileState {
  final response;
  const LoadDistrictProfileState(this.response);
}

class UpdateProfileState extends ProfileState {
  final response;
  const UpdateProfileState(this.response);
}
class SendContactState extends ProfileState {
  final response;
  SendContactState(this.response);
}

class ProfileEvent extends BaseEvent {}

class LoadProfileEvent extends ProfileEvent {}

class LoadImageProfileEvent extends ProfileEvent {}

class AddDeleteUserTypeProfileEvent extends ProfileEvent {}

class AddDeleteHashTagProfileEvent extends ProfileEvent {}

class AddDeleteTreeProfileEvent extends ProfileEvent {}

class LoadProvinceProfileEvent extends ProfileEvent {}

class LoadDistrictProfileEvent extends ProfileEvent {
  final String provinceId;
  LoadDistrictProfileEvent(this.provinceId);
}

class LoadCatalogueProfileEvent extends ProfileEvent {
  final int page;
  LoadCatalogueProfileEvent(this.page);
}
class SendContactEvent extends ProfileEvent {
  final String name, phone, email, content;
  SendContactEvent(this.name, this.phone, this.email, this.content);
}

class UpdateProfileEvent extends ProfileEvent {
  final String image, fullName, phone, birthday, gender, email, website, address, province, district, acreage;
  final List<ItemModel> userTypes, hashTags, trees;

  UpdateProfileEvent(this.image, this.fullName, this.phone, this.birthday, this.gender, this.email, this.website,
      this.address, this.province, this.district, this.userTypes, this.hashTags, this.trees, this.acreage);
}

class LoadReferralLinkEvent extends ProfileEvent {}

class ProfileBloc extends BaseBloc {
  final ProfileListener listener;
  ProfileBloc(this.listener, {ProfileState init = const ProfileState()}) : super(init: init) {
    on<LoadProfileEvent>((event, emit) async {
      final user = await _getProfile();
      final newState = LoadProfileState(user);
      listener.loadProfile(newState);
      emit(newState);
    });
    on<SendContactEvent> ((event, emit) async {
      final response = await SignUpRepository().sendContact(event.name, event.phone, event.email, event.content);
      emit(SendContactState(response));
    });

    on<AddDeleteUserTypeProfileEvent>((event, emit) {
      emit(AddDeleteUserTypeProfileState());
    });
    on<AddDeleteHashTagProfileEvent>((event, emit) {
      emit(AddDeleteHashTagProfileState());
    });
    on<AddDeleteTreeProfileEvent>((event, emit) {
      emit(AddDeleteTreeProfileState());
    });
    on<LoadImageProfileEvent>((event, emit) {
      emit(LoadImageProfileState());
    });
    on<LoadProvinceProfileEvent>((event, emit) async {
      emit(await _handleLoadProvince(event));
    });
    on<LoadDistrictProfileEvent>((event, emit) async {
      emit(await _handleLoadDistrict(event));
    });
    on<LoadCatalogueProfileEvent>((event, emit) async {
      emit(await _handleLoadCatalogue(event));
    });
    on<UpdateProfileEvent>((event, emit) async {
      emit(const ProfileState(isShowLoading: true));
      emit(await _handleUpdateProfile(event));
    });
    on<ChangePhoneEvent>((event, emit) async{
      emit(const ProfileState(isShowLoading: true));
      emit(await _handleChangePhone(event));
    });
    on<VerifyCodePhoneEvent>((event, emit) async{
      emit(const ProfileState(isShowLoading: true));
      emit(await _handleVerifyCodePhone(event));
    });
    on<UpdatePhoneEvent>((event, emit) async{
      emit(const ProfileState(isShowLoading: true));
      emit(await _handleUpdatePhone(event));
    });
    on<LoadReferralLinkEvent>((event, emit) async{
      emit(await _loadRefeffalLink(event));
    });
  }

  Future<LoginModel> _getProfile() async {
    final Constants constants = Constants();
    final user = LoginModel();
    final prefs = await SharedPreferences.getInstance();
    user.id = prefs.getInt('id')!;
    user.acreage = prefs.getDouble('acreage')!;
    user.name = prefs.getString(constants.name)!;
    user.email = prefs.getString('email')!;
    user.website = prefs.getString('website')!;
    user.phone = prefs.getString('phone')!;
    user.address = prefs.getString('address')!;
    user.image = prefs.getString(constants.image)!;
    user.birthdate = prefs.getString('birthdate')!;
    user.gender = prefs.getString('gender')!;
    user.user_type = prefs.getString('user_type')!;
    user.province_id = prefs.getString('province_id')!;
    user.province_name = prefs.getString(constants.provinceName)!;
    user.district_id = prefs.getString('district_id')!;
    user.district_name = prefs.getString('district_name')!;
    //user.member_rate = prefs.getString(constants.memberRate)!;
    user.has_tash_list?.listsToObjects(prefs.getStringList('hash_tags')!,
        prefs.getStringList('hash_tags_name')!);
    user.tree_list?.stringsToObjects(prefs.getStringList('trees')??[]);
    user.current_referral_code = prefs.getString('current_referral_code') ?? "";
    user.referral_link = prefs.getString('referral_link') ?? "";
    return user;
  }

  Future<LoadProvinceProfileState> _handleLoadProvince(LoadProvinceProfileEvent event) async {
    final response = await SignUpRepository().loadProvince();
    final newState = LoadProvinceProfileState(response);
    (listener as ProfileListenerAll).handleLoadProvince(newState);
    return newState;
  }

  Future<LoadDistrictProfileState> _handleLoadDistrict(LoadDistrictProfileEvent event) async {
    final response = await SignUpRepository().loadDistrict(event.provinceId);
    final newState = LoadDistrictProfileState(response);
    (listener as ProfileListenerAll).handleLoadDistrict(newState);
    return newState;
  }

  Future<LoadCatalogueProfileState> _handleLoadCatalogue(LoadCatalogueProfileEvent event) async {
    final response = await SignUpRepository().loadCatalogue(event.page);
    final newState = LoadCatalogueProfileState(response, nextPage: event.page + 1);
    (listener as ProfileListenerAll).handleLoadCatalogue(newState);
    return newState;
  }

  Future<UpdateProfileState> _handleUpdateProfile(UpdateProfileEvent event) async {
    final response = await SignUpRepository().updateProfile(event.image, event.fullName, event.phone, event.birthday,
        event.gender, event.email, event.website, event.address, event.province, event.district, event.userTypes,
        event.hashTags, event.trees, event.acreage);
    final newState = UpdateProfileState(response);
    (listener as ProfileListenerAll).handleUpdateProfile(newState);
    return newState;
  }

  Future<ChangePhoneState> _handleChangePhone(ChangePhoneEvent event) async{
    final resp = await ApiClient().postAPI(
      '${Constants().apiVersion}account/update_phone',
      'PUT',
      BaseResponse(),
      hasHeader: true,
      body: {
        'phone': event.phone
      },
    );
    return ChangePhoneState(resp);
  }
  Future<VerifyCodePhoneState> _handleVerifyCodePhone(VerifyCodePhoneEvent event) async{
    final response =await ApiClient().postAPI(
      '${Constants().apiVersion}account/check_verify_code',
      'POST',
      LoginModel(),
      hasHeader: false,
      body: {
        'verify_code': event.otpCode
      },
    );
    return VerifyCodePhoneState(response);
  }

  Future<UpdatePhoneState> _handleUpdatePhone(UpdatePhoneEvent event) async{
    final response = await ApiClient().postAPI('${Constants().apiVersion}account/update_user', 'POST', LoginModel(),
        body:{ 'phone': event.phone,});
    return UpdatePhoneState(response);
  }

  Future<LoadReferralLinkeState> _loadRefeffalLink(LoadReferralLinkEvent event) async {
    final response = await ApiClient().getAPI2('${Constants().apiVersion}account/referral_link');
    if (response.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(response);
      return LoadReferralLinkeState(json["data"]);
    } else {
      return (LoadReferralLinkeState(""));
    }
  }
}
