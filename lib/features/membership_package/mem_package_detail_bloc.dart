import 'dart:async';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/database_helper.dart';
import '../function/module_model.dart';
import '../function/support/mission/mission_bloc.dart';
export '../function/support/mission/mission_bloc.dart';

class MemPackageDetailBloc extends BaseBloc {
  final Map<String, ModuleModel> modules = {};
  String method = 'point',idCurrentName = '';
  bool isRegister = false;
  int id = -1, idCurrent = -1;

  MemPackageDetailBloc(this.id, bool loadFeatures, int idHistory) {
    on<ShowClearSearchEvent>((event, emit) async {
      if (isRegister) {
        emit(const BaseState(isShowLoading: true));
        emit(await payment());
        return;
      }
      method = 'point';
      isRegister = event.value;
      emit(ShowClearSearchState(event.value));
    });
    on<GetLocationEvent>((event, emit) {
      method = event.address;
      emit(GetLocationState(event.address));
    });
    on<LoadMembersEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String param = event.id.toString();
      if (isRegister) {
        param = 'histories/' + param;
        isRegister = false;
      }
      final data = await ApiClient().getData('membership_packages/membership_packages/' + param, getError: true);
      emit(data != null ? LoadMembersState(data) : const BaseState());
    });
    on<LoadCatalogueEvent>((event, emit) async {
      final list = await DBHelper().getAllModelWithCond(ModuleModel());
      if (list.isNotEmpty) {
        for(ModuleModel item in list) {
          modules.putIfAbsent(item.app_type, () => item);
        }
        emit(LoadCatalogueState(''));
      }

      final resp = await ApiClient().getAPI(Constants().apiVersion + 'app_modules', ModuleModels());
      if (resp.checkOK() && resp.data.list2.isNotEmpty) {
        if (modules.isNotEmpty) modules.clear();
        modules.addAll(resp.data.list2);
        emit(LoadCatalogueState(''));
      }
    });
    on<JoinMissionEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI(Constants().apiVersion +
          'membership_packages/membership_packages/${event.idParent}/confirm',
          'POST', BaseResponse(), body: {'status': event.idSub == 1 ? 'accept' : 'deny'});
      emit(event.idSub == 1 ? JoinMissionState(resp) : LoadReviewsState(resp));
    });
    on<LeaveMissionEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI(Constants().apiVersion +
          'membership_packages/membership_packages/${event.idParent}/package_cancel',
          'PUT', BaseResponse());
      emit(LeaveMissionState(resp));
    });
    if (loadFeatures) {
      isRegister = idHistory > 0;
      add(LoadMembersEvent(idHistory > 0 ? idHistory : id));
    }
    add(LoadCatalogueEvent());
    loadIdCurrentPackage();
  }

  @override
  Future<void> close() async {
    modules.clear();
    super.close();
  }

  void changeMethod(String value) => method != value ? add(GetLocationEvent(value)) : '';

  void cancel() {
    isRegister = false;
    add(ShowClearSearchEvent(false));
  }

  void loadIdCurrentPackage() async {
    dynamic myPackage = await ApiClient().getData('membership_packages/membership_packages/current_package');
    if(myPackage != null){
      idCurrent = myPackage['id']??-1;
      idCurrentName = myPackage['name']??"";
    }
  }

  Future<BaseState> payment() async {
    if (method.isEmpty) return GetAddressState(BaseResponse(data: 'Chọn phương thức'));
    final resp = await ApiClient().postAPI(Constants().apiVersion + 'membership_packages/membership_packages/$id/buy', 'post', BaseResponse(), body: {
      'using_type': method == 'point' ? method : 'money'
    });
    return GetAddressState(resp);
  }
}