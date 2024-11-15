import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/login/login_model.dart';
import 'package:hainong/features/login/login_repository.dart';
import '../sign_up_repository.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';
export 'sign_up_event.dart';
export 'sign_up_state.dart';

class SignUpBloc extends BaseBloc {
  final repository = SignUpRepository();

  SignUpBloc({SignUpState init = const SignUpState()}) : super(init: init) {
    on<FocusTextEvent>((event, emit) => emit(FocusTextState(event.value)));
    on<ChangeTermEvent>((event, emit) {
      emit(ChangeTermState(event.value,
          (state as SignUpState).isShowPassword,
          (state as SignUpState).isShowRepeatPassword
      ));
    });
    on<AddDeleteUserTypeSignUpEvent>((event, emit) {
      emit(AddDeleteUserTypeSignUpState());
    });
    on<ChangeCurrentPasswordEvent>((event, emit) async {
      final resp = await ApiClient().postAPI('${Constants().apiVersion}account/change_current_password', 'POST', LoginModel(), body: {
        if (event.current_password.isNotEmpty) 'current_password': event.current_password,
        'password': event.password,
        'password_confirmation': event.password_confirmation
      }, hasHeader: Constants().isLogin);
      emit(_showLoading());
      emit(ChangeCurrentPasswordState(resp));
    });
    on<AddDeleteHashTagSignUpEvent>((event, emit) {
      emit(AddDeleteHashTagSignUpState());
    });
    on<LoadImageSignUpEvent>((event, emit) {
      emit(LoadImageSignUpState(
          isShowPassword: (state as SignUpState).isShowPassword,
          isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword));
    });
    on<ShowRepeatPasswordSignUpEvent>((event, emit) {
      emit(ShowRepeatPasswordSignUpState(
          isShowPassword: (state as SignUpState).isShowPassword,
          isShowRepeatPassword: event.isShowRepeatPassword,
        isShowCurrentPassword: (state as SignUpState).isShowCurrentPassword
      ));
    });
    on<ShowPasswordSignUpEvent>((event, emit) {
      emit(ShowPasswordSignUpState(
          isShowPassword: event.isShowPassword,
          isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
        isShowCurrentPassword: (state as SignUpState).isShowCurrentPassword
      ));
    });
    on<ShowCurrentPasswordEvent>((event, emit) {
      emit(ShowCurrentPasswordState(
          isShowPassword: (state as SignUpState).isShowPassword,
          isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
          isShowCurrentPassword: event.isShowCurrentPassword
      ));
    });
    on<OnClickChangePasswordSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleOnClickOK(event));
    });
    on<SaveDeviceSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleSaveDevice(event));
    });
    on<OnClickSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleOnClickSignUp(event));
    });
    on<OnClickSignUpNextEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleOnClickSignUpNext(event));
    });
    on<LoadProvinceSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleLoadProvinceSignUp(event));
    });
    on<LoadDistrictSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleLoadDistrictSignUp(event));
    });
    on<LoadProfileSignUpEvent>((event, emit) async {
      emit(_showLoading());
      final response = await repository.loadProfile();
      emit(LoadProfileSignUpState(response));
    });
    on<RequireOTPSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleRequireOTP(event));
    });
    on<VerifyCodeSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleVerifyCode(event));
    });
    on<LoadCatalogueSignUpEvent>((event, emit) async {
      emit(_showLoading());
      emit(await _handleLoadCatalogue(event));
    });
  }

  SignUpState _showLoading({bool value = true}) => SignUpState(
      isShowLoading: value,
      isShowPassword: (state as SignUpState).isShowPassword,
      isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword);

  Future<SignUpState> _handleRequireOTP(RequireOTPSignUpEvent event) async {
    final resp = await repository.requireOTP(event.phone);
    return RequireOTPSignUpState(resp, (state as SignUpState).isShowPassword, (state as SignUpState).isShowRepeatPassword);
  }

  Future<SignUpState> _handleVerifyCode(VerifyCodeSignUpEvent event) async {
    final resp = await repository.verifyCode(event.otpCode);
    return VerifyCodeSignUpState(resp, (state as SignUpState).isShowPassword, (state as SignUpState).isShowRepeatPassword);
  }

  Future<SignUpState> _handleLoadProvinceSignUp(LoadProvinceSignUpEvent event) async {
    final response = await repository.loadProvince();
    return LoadProvinceSignUpState(
        isShowLoading: response.success,
        isShowPassword: (state as SignUpState).isShowPassword,
        isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
        response: response);
  }

  Future<SignUpState> _handleLoadDistrictSignUp(LoadDistrictSignUpEvent event) async {
    final response = await repository.loadDistrict(event.provinceId);
    return LoadDistrictSignUpState(
        isShowPassword: (state as SignUpState).isShowPassword,
        isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
        response: response);
  }

  Future<ResponseSignUpState> _handleOnClickSignUp(OnClickSignUpEvent event) async {
    final resp = await repository.signUp(
        event.fullName,
        event.birthday,
        event.gender,
        event.referrarType,
        event.referrarCode,
        event.email,
        event.phoneNumber,
        event.password,
        event.repeatPassword,
        event.imagePath,
        event.deviceId, event.term);
    return ResponseSignUpState(
        isShowPassword: (state as SignUpState).isShowPassword,
        isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
        response: resp);
  }

  Future<ResponseSignUpState> _handleSaveDevice(SaveDeviceSignUpEvent event) async {
    final resp = await LoginRepository().saveDevice(
        event.deviceId,
        event.deviceName,
        event.deviceType,
        event.osVersion,
        event.appVersion,
        event.deviceToken,
        event.apnsTopic,
        event.appleNoticeToken);
    return SaveDeviceSignUpState(
        isShowPassword: (state as SignUpState).isShowPassword,
        isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
        response: resp);
  }

  Future<ResponseSignUpState> _handleOnClickSignUpNext(OnClickSignUpNextEvent event) async {
    final resp = await repository.signUpNext(
        event.website,
        event.address,
        event.province,
        event.district,
        event.userTypes,
        event.hashTags,
        event.image);
    return ResponseSignUpNextState(
        isShowPassword: (state as SignUpState).isShowPassword,
        isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
        response: resp);
  }

  Future<ResponseSignUpState> _handleOnClickOK(OnClickChangePasswordSignUpEvent event) async {
    final resp = await repository.updatePassword(event.loginKey, event.password, event.otp);
    return ResponseSignUpState(
        isShowPassword: (state as SignUpState).isShowPassword,
        isShowRepeatPassword: (state as SignUpState).isShowRepeatPassword,
        response: resp);
  }

  Future<LoadCatalogueSignUpState> _handleLoadCatalogue(LoadCatalogueSignUpEvent event) async {
    final response = await repository.loadCatalogue(event.page);
    return LoadCatalogueSignUpState(response: response, nextPage: event.page + 1, isShowPassword: false, isShowRepeatPassword: false);
  }
}
