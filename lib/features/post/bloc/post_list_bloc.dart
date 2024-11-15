import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/features/main/main_repository.dart';
import 'package:hainong/features/main/total_model.dart';
import '../post_list_repository.dart';

class PostListState extends BaseState {
  PostListState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}
class LoadFollowersPostListState extends PostListState {
  final BaseResponse response;
  LoadFollowersPostListState(this.response);
}

class ChangeTabState extends PostListState {
  final int index;
  ChangeTabState(this.index);
}

class ReloadTotalState extends PostListState {
  final TotalModel total;
  ReloadTotalState(this.total);
}

class PostListEvent extends BaseEvent {}
class LoadFollowersPostListEvent extends PostListEvent {
  final int page, type;
  LoadFollowersPostListEvent(this.page, this.type);
}

class ChangeTabEvent extends PostListEvent {
  final int index;
  ChangeTabEvent(this.index);
}

class UnfollowPostEvent extends PostListEvent{
  final String clasSableType;
  final String clasSableId;

  UnfollowPostEvent(this.clasSableType, this.clasSableId);
}

class UnfollowPostState extends PostListState{
  BaseResponse baseResponse;
  UnfollowPostState(this.baseResponse);
}

class PostListBloc extends BaseBloc {
  PostListBloc(PostListState init):super(init:init) {
    on<LoadFollowersPostListEvent>((event, emit) async {
      final BaseResponse response;
      if(event.type == 2){
        response = await PostListRepository().loadPostFollowers(event.page, event.type);
      }
      else{
        response = await PostListRepository().loadFollowers(event.page, event.type);
      }
      emit(LoadFollowersPostListState(response));

      final responseTotal = await MainRepository().getTotal();
      if (responseTotal.checkOK()) emit(ReloadTotalState(responseTotal.data));
    });
    on<ChangeTabEvent>((event, emit) => emit(ChangeTabState(event.index)));
    on<UnfollowPostEvent>((event, emit) async{
      final response = await PostListRepository().unFollowPost(event.clasSableType, event.clasSableId);
      emit(UnfollowPostState(response));
    });
  }
}
