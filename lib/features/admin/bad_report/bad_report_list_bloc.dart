import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/comment/model/comment_model.dart';
import 'package:hainong/features/post/model/post.dart';
import '../../notification/notification_bloc.dart';
import '../../post/bloc/post_list_bloc.dart';
import 'bad_report_model.dart';

class DeleteBadReportEvent extends BaseEvent {
  final int id, index;
  final String type;
  DeleteBadReportEvent(this.id, this.index, this.type);
}
class DeleteBadReportState extends BaseState {
  final BaseResponse resp;
  final int index;
  DeleteBadReportState(this.resp, this.index);
}

class BadReportBloc extends BaseBloc {
  BadReportBloc(PostListState init):super(init:init) {
    on<LoadFollowersPostListEvent>((event, emit) async {
      String type = 'Post', reportType = 'comment';
      switch(event.type) {
        case 0: reportType = 'post'; break;
        case 2: type = 'Product'; break;
        case 3: type = 'Article'; break;
        case 4: type = 'Video';
      }
      final response = await ApiClient().getAPI(Constants().apiPerVer + 'warnings?report_type=$reportType&'
          'commentable_type=$type&page=${event.page}&limit=20', BadReportModels());
      emit(LoadFollowersPostListState(response));
    });
    on<DeleteBadReportEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(Constants().apiPerVer + 'warnings/${event.id}', 'DELETE',
        BaseResponse(), body: {'classable_type': event.type});
      emit(DeleteBadReportState(response, event.index));
    });
    on<ChangeTabEvent>((event, emit) => emit(ChangeTabState(event.index)));
    on<LoadCommentEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI(Constants().apiVersion + 'comments/' + event.id.toString(), CommentModel());
      emit(response.checkOK() ? LoadCommentState(response) : const BaseState());
    });
    on<LoadPostEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI(Constants().apiVersion + 'posts/' + event.id.toString(), Post());
      emit(response.checkOK() ? LoadPostState(response) : const BaseState());
    });
  }
}
