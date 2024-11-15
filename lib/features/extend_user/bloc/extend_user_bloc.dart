import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';

class LoadListAppEvent extends BaseEvent {}

class LoadListAppState extends BaseState {
  BaseResponseTranslate baseResponse;
  LoadListAppState(this.baseResponse);
}

class ExtendUserBloc extends BaseBloc {
  ExtendUserBloc() {
    //final domain = Constants().baseUrl == 'https://admin.hainong.vn' ? 'https://agrid.vn/api/v2/' : 'https://dev.id.hainong.vn/api/v2/';
    on<LoadListAppEvent>((event, emit) async {
      final response = await ApiClient()
          .postAPIResponseTranslate(Constants().baseUrlIPortal + Constants().apiVersion + 'user_extends', 'GET', BaseResponseTranslate(), hasHeader: true, fullPath: true);
      emit(LoadListAppState(response));
    });
  }
}
