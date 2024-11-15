import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'setting_repository.dart';

class SettingState extends BaseState {
  SettingState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}

class ChangeValueSettingState extends SettingState {
  final int index;
  ChangeValueSettingState(this.index);
}

class UpdateSettingState extends SettingState {
  final BaseResponse response;
  UpdateSettingState(this.response);
}

class ShowFingerSettingState extends SettingState {}

class HasSetupFingerSettingState extends SettingState {
  final bool value;
  HasSetupFingerSettingState(this.value);
}

abstract class SettingEvent extends BaseEvent {}

class ChangeValueSettingEvent extends SettingEvent {
  final int index;
  ChangeValueSettingEvent(this.index);
}

class UpdateSettingEvent extends SettingEvent {
  final int hiddenPhone;
  final int hiddenEmail;
  final int hiddenToolbar;
  final int autoPlayVideo;
  UpdateSettingEvent(this.hiddenPhone, this.hiddenEmail, this.hiddenToolbar, this.autoPlayVideo);
}

class ShowFingerSettingEvent extends SettingEvent {}

class HasSetupFingerSettingEvent extends SettingEvent {
  final bool value;
  HasSetupFingerSettingEvent(this.value);
}

class DeleteAccountEvent extends SettingEvent {}
class DeleteAccountState extends SettingState {
  final BaseResponse response;
  DeleteAccountState(this.response);
}

class ShowDeleteEvent extends BaseEvent {}
class ShowDeleteState extends BaseState {
  final bool value;
  ShowDeleteState(this.value);
}

class SettingBloc extends BaseBloc {
  SettingBloc(SettingState init):super(init:init) {
    on<ChangeValueSettingEvent>((event, emit) => emit(ChangeValueSettingState(event.index)));
    on<UpdateSettingEvent>((event, emit) async {
      emit(SettingState(isShowLoading: true));
      final response = await SettingRepository().updateSetting(event.hiddenPhone, event.hiddenEmail, event.hiddenToolbar, event.autoPlayVideo);
      emit(UpdateSettingState(response));
    });
    on<ShowFingerSettingEvent>((event, emit) => emit(ShowFingerSettingState()));
    on<HasSetupFingerSettingEvent>((event, emit) => emit(HasSetupFingerSettingState(event.value)));
    on<DeleteAccountEvent>((event, emit) async {
      emit(SettingState(isShowLoading: true));
      final response = await SettingRepository().delete();
      emit(DeleteAccountState(response));
    });
    on<ShowDeleteEvent>((event, emit) async {
      final response = await SettingRepository().loadSetting();
      if (response.checkOK()) {
        if (response.data.list.isNotEmpty) {
          emit(ShowDeleteState(response.data.list[0].value == 'true'));
        }
      }
    });
  }
}