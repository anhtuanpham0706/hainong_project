import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/features/function/support/mission/mission_bloc.dart';
export 'package:hainong/features/function/support/mission/mission_bloc.dart';

class ExeContributionDetailBloc extends BaseBloc {

  ExeContributionDetailBloc(int id, {bool isDetail = true}) {
    if (isDetail) {
      on<ShowClearSearchEvent>((event, emit) => emit(ShowClearSearchState(event.value)));
      on<LoadMembersEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final data = await ApiClient().getData('contribution_missions/' + event.id.toString());
        emit(data != null ? LoadMembersState(data) : const BaseState());
      });
      on<JoinMissionEvent>((event, emit) async {
        emit(const BaseState(isShowLoading: true));
        final resp = await ApiClient().postAPI(Constants().apiVersion + 'contribution_missions/join_mission',
            'POST', BaseResponse(), body: {'contribution_mission_id': event.idParent.toString()});
        emit(JoinMissionState(resp));
      });

      add(LoadMembersEvent(id));
      return;
    }

    on<ShowClearSearchEvent>((event, emit) => emit(ShowClearSearchState(event.value)));
    on<ReviewMissionEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final resp = await ApiClient().postAPI(
          Constants().apiVersion + 'contribution_mission_detail_user_trackings',
          'POST',
          BaseResponse(),
          realFiles: event.list as List<FileByte>,
          paramFile: 'attachment[file][]',
          body: {
            'contribution_mission_detail_target_id': event.idParent.toString()
          });
      emit(ReviewMissionState(resp, ''));
    });
  }
}