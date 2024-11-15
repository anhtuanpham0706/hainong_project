import 'dart:convert';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/import_lib_system.dart';

class GameBloc extends BaseBloc {
  GameBloc() {
    on<FetchGameListStatusEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI2(Constants().apiVersion + 'mini_events/list_event?page=1&limit=100');
      if (resp.isNotEmpty) {
        final json = jsonDecode(resp);
        if (Util.checkKeyFromJson(json, 'success') && Util.checkKeyFromJson(json, 'data') && json['success']) {
          final temp = json['data'].toList();
          if (temp.isNotEmpty) {
            final pref = await SharedPreferences.getInstance();
            final String phone = pref.getString("phone")??'', fullName = Uri.encodeFull(pref.getString("name")??''),
                token = pref.getString("token_user")??'';
            String _env = pref.getString("env") ?? '';
            if (_env.isNotEmpty) _env += '.';

            final List list = [];
            bool hasMil = false;
            int hasWheel = 0, index = -1;
            for (var item in temp) {
              if (hasMil && hasWheel > 1) break;
              switch(item['group_name']) {
                case 'millionaire':
                  hasMil = true;
                  item.update('image', (value) => 'assets/images/v5/ic_game_trieuphu.png', ifAbsent: () => 'assets/images/v5/ic_game_trieuphu.png');
                  item.update('help', (value) => 'https://help.hainong.vn/muc/14', ifAbsent: () => 'https://help.hainong.vn/muc/14');
                  item.update('des', (value) => 'Thử tài kiến thức nông nghiệp', ifAbsent: () => 'Thử tài kiến thức nông nghiệp');
                  item.update('url', (value) => 'https://trieuphu2nong.2nong.vn?phone=$phone&fullname=$fullName&secret=ca6NAuSXAURHLqrSKgpiYZNoSoyIXpI9cPYEER/YvmU=&app_id=cho2nong',
                      ifAbsent: () => 'https://trieuphu2nong.2nong.vn?phone=$phone&fullname=$fullName&secret=ca6NAuSXAURHLqrSKgpiYZNoSoyIXpI9cPYEER/YvmU=&app_id=cho2nong');
                  list.add(item);
                  break;
                case 'lucky_wheel':
                  if (item['id'] != 1) {
                    if (hasWheel == 0) {
                      item.update('image', (value) => 'assets/images/v5/ic_game_vongquay.png',
                          ifAbsent: () => 'assets/images/v5/ic_game_vongquay.png');
                      item.update('help', (value) => 'https://help.hainong.vn/muc/13',
                          ifAbsent: () => 'https://help.hainong.vn/muc/13');
                      item.update('des', (value) => 'Thử tài vòng quay may mắn', ifAbsent: () => 'Thử tài vòng quay may mắn');
                      item.update('url', (value) => 'https://${_env}luckywheel.event.hainong.vn/auth/'+token,
                          ifAbsent: () => 'https://${_env}luckywheel.event.hainong.vn/auth/'+token);
                      list.add(item);
                      index = list.length - 1;
                    }
                    hasWheel ++;
                  }
                  break;
              }
            }
            if (hasWheel > 1 && index != -1) list[index].update('event_name', (value) => 'Vòng quay 2Nông', ifAbsent: () => 'Vòng quay 2Nông');
            emit(GameListStatusState(BaseResponse(success: true, data: list)));
            return;
          }
        }
      }
      emit(GameListStatusState(BaseResponse()));
    });
    on<CheckMemPackageEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().getAPI(Constants().apiVersion + 'notifications/count', BaseResponse());
      emit(CheckMemPackageState(resp));
    });
  }
}

class FetchGameListStatusEvent extends BaseEvent {}
class GameListStatusState extends BaseState {
  final dynamic resp;
  GameListStatusState(this.resp);
}
