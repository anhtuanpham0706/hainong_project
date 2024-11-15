import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/import_lib_system.dart';
import '../extend_user_model.dart';

// class LoadListJsonEvent extends BaseEvent {
//   int idApp;
//
//   LoadListJsonEvent(this.idApp);
// }

// class LoadListJsonState extends BaseState {
//   BaseResponseTranslate response;
//
//   LoadListJsonState(this.response);
// }

class LoadListJsonEvent extends BaseEvent {
  int id;
  TypeFlowData type;
  String? key;
  String? slug;
  String? keySearch;
  int? page;
  LoadListJsonEvent(this.id, this.type, {this.key, this.slug, this.keySearch, this.page});
}

class LoadListJsonState extends BaseState {
  String keyName;
  BaseResponseTranslate response;

  LoadListJsonState(
    this.response,
    this.keyName,
  );
}

class DetailExtendUserBloc extends BaseBloc {
  //final domain = Constants().baseUrl == 'https://admin.hainong.vn' ? 'https://agrid.vn/api/v2/' : 'https://dev.id.hainong.vn/api/v2/';

  DetailExtendUserBloc() {
    // on<LoadListJsonEvent>((event, emit) async {
    //   final response = await ApiClient().postAPIResponseTranslate(
    //       domain + 'user_extends/${event.idApp}', 'GET', BaseResponseTranslate(),
    //       fullPath: true, hasHeader: true);
    //   if (response.checkOK()) {
    //     emit(LoadListJsonState(response));
    //   }
    // });
    on<LoadListJsonEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      String keyName ='';
      BaseResponseTranslate response = BaseResponseTranslate();
      switch(event.type){
        case TypeFlowData.Floor1:
          response = await ApiClient().postAPIResponseTranslate(
              Constants().baseUrlIPortal + Constants().apiVersion + 'user_extends/${event.id}', 'GET', BaseResponseTranslate(),
              fullPath: true, hasHeader: true);
          keyName = event.key??'';
          break;
        case TypeFlowData.Floor2:
          response = await ApiClient().postAPIResponseTranslate(
              Constants().baseUrlIPortal + Constants().apiVersion + 'user_extends/${event.id}/info?key=${event.key}', 'GET', BaseResponseTranslate(),
              fullPath: true, hasHeader: true);
          keyName = event.key??'';
          break;
        case TypeFlowData.Floor3:
          String keySearch ='';
          String page = '&page=1';
          if(event.keySearch!=null && event.keySearch!.isNotEmpty){
            keySearch = '&keyword=${event.keySearch}';
          }
          if(event.page!=null){
            page = '&page=${event.page}';
          }
          response = await ApiClient().postAPIResponseTranslate(
              Constants().baseUrlIPortal + Constants().apiVersion + 'user_extends/${event.id}/second_manager?key=${event.key}&slug=${event.slug}&limit=1$keySearch$page', 'GET', BaseResponseTranslate(),
              fullPath: true, hasHeader: true);
          keyName = event.slug?? '';
          break;
      }
        emit(LoadListJsonState(response, keyName));


      // if(event.key != null && event.key!.isNotEmpty){
      //   if(event.slug != null && event.slug!.isNotEmpty){
      //     // data flow 3
      //     response = await ApiClient().postAPIResponseTranslate(
      //         domain + 'user_extends/${event.id}/second_manager?key=${event.key}&slug=${event.slug}&page=1&limit=2', 'GET', BaseResponseTranslate(),
      //         fullPath: true, hasHeader: true);
      //   }
      //   else{
      //     // data flow 2
      //     response = await ApiClient().postAPIResponseTranslate(
      //         domain + 'user_extends/${event.id}/info?key=${event.key}&page=1&limit=2', 'GET', BaseResponseTranslate(),
      //         fullPath: true, hasHeader: true);
      //   }
      //
      // }
      // else{
      //   // data floor 1
      //   response = await ApiClient().postAPIResponseTranslate(
      //       domain + 'user_extends/${event.id}', 'GET', BaseResponseTranslate(),
      //       fullPath: true, hasHeader: true);
      });
  }
}

