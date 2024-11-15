import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/features/function/info_news/news/news_model.dart';
import 'package:hainong/features/product/repository/product_detail_repository.dart';
import 'package:hainong/features/rating/rating_repository.dart';
import 'package:hainong/common/api_client.dart';
import '../home/bloc/home_bloc.dart';
import '../home/home_repository.dart';
import '../login/bloc/login_event.dart';
import '../login/bloc/login_state.dart';
import '../notification/notification_bloc.dart';
import '../post/model/post.dart';
import 'model/comment_model.dart';

class CommentState extends BaseState {
  CommentState({isShowLoading = false}) :super(isShowLoading: isShowLoading);
}

class LoadListCommentState extends CommentState {
  final BaseResponse response;
  LoadListCommentState(this.response);
}

class LoadListAnswerState extends CommentState {
  final BaseResponse response;
  LoadListAnswerState(this.response);
}

class SendCommentState extends CommentState {
  final BaseResponse response;
  SendCommentState(this.response);
}

class AnswerCommentState extends CommentState {
  final BaseResponse response;
  AnswerCommentState(this.response);
}

class CommentEvent extends BaseEvent {}

class LoadListCommentEvent extends CommentEvent {
  final int page, id;
  final String type;
  final bool sortLike;
  LoadListCommentEvent(this.page, this.type, this.id, this.sortLike);
}

class LoadListAnswerEvent extends CommentEvent {
  final int page;
  final String id;
  LoadListAnswerEvent(this.page, this.id);
}

class SendCommentEvent extends CommentEvent {
  final String content;
  final String type;
  final int id;
  SendCommentEvent(this.content, this.type, this.id);
}

class AnswerCommentEvent extends CommentEvent {
  final String content, id;
  final int? replierId, parentId;
  AnswerCommentEvent(this.content, this.id, {this.replierId, this.parentId});
}

class LikeCommentEvent extends BaseEvent {
  final String id, type;
  LikeCommentEvent(this.id, this.type);
}
class LikeCommentState extends BaseState {
  final BaseResponse resp;
  LikeCommentState(this.resp);
}

class UnlikeCommentEvent extends BaseEvent {
  final String id, type;
  UnlikeCommentEvent(this.id, this.type);
}
class UnlikeCommentState extends BaseState {
  final BaseResponse resp;
  UnlikeCommentState(this.resp);
}

class ReportCommentEvent extends BaseEvent {
  final String id, type, content;
  final int index;
  ReportCommentEvent(this.id, this.type, this.content, this.index);
}
class ReportCommentState extends BaseState {
  final BaseResponse resp;
  ReportCommentState(this.resp);
}

class GetAvatarEvent extends BaseEvent {}
class GetAvatarState extends BaseState {
  final String avatar;
  GetAvatarState(this.avatar);
}

class OpenInputEvent extends BaseEvent {
  final bool value;
  OpenInputEvent(this.value);
}
class OpenInputState extends BaseState {
  final bool value;
  OpenInputState(this.value);
}

class ReloadAnswerEvent extends BaseEvent {}
class ReloadAnswerState extends BaseState {}

class ReloadParentEvent extends BaseEvent {}
class ReloadParentState extends BaseState {}

class DeleteCommentEvent extends BaseEvent {
  final int id, commentId;
  final bool owner, isComment;
  DeleteCommentEvent(this.id, this.owner, this.isComment, this.commentId);
}
class DeleteCommentState extends BaseState {
  final BaseResponse resp;
  DeleteCommentState(this.resp);
}
class ReloadCommentState extends BaseState {
  final CommentModel comment;
  ReloadCommentState(this.comment);
}

class EditCommentEvent extends CommentEvent {
  final String content;
  final int id;
  final bool owner, isComment;
  EditCommentEvent(this.content, this.id, this.owner, this.isComment);
}
class EditCommentState extends CommentState {
  final BaseResponse resp;
  EditCommentState(this.resp);
}

class GetCommentEvent extends CommentEvent {
  final int id;
  GetCommentEvent(this.id);
}
class GetCommentState extends CommentState {
  final CommentModel value;
  GetCommentState(this.value);
}

class ShowDetailEvent extends CommentEvent {}
class ShowDetailState extends CommentState {}

class ChangeFilterEvent extends CommentEvent {}
class ChangeFilterState extends CommentState {}

class LoadNewsEvent extends NotificationEvent {
  final int id;
  final String type;
  LoadNewsEvent(this.id, this.type);
}
class LoadNewsState extends NotificationState {
  final BaseResponse response;
  final String type;
  LoadNewsState(this.response, this.type);
}

class CommentBloc extends BaseBloc {
  CommentBloc(CommentState init) : super(init:init) {
    on<LoadNewsEvent>((event, emit) async {
      emit(NotificationState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiVersion}articles/${event.id}', NewsModel());
      response.checkOK()?emit(LoadNewsState(response, event.type)):emit(NotificationState());
    });
    on<LoadPostEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiVersion}posts/${event.id}', Post());
      response.checkOK()?emit(LoadPostState(response)):emit(const BaseState());
    });
    on<LoadShopHomeEvent>((event, emit) async {
      emit(CommentState(isShowLoading: true));
      final response = await HomeRepository().loadShop(event.id);
      emit(LoadShopHomeState(event.context, response));
    });
    on<FocusTextLoginEvent>((event, emit) => emit(FocusTextLoginState(event.value, false, false)));
    on<ChangeFilterEvent>((event, emit) => emit(ChangeFilterState()));
    on<ShowDetailEvent>((event, emit) => emit(ShowDetailState()));
    on<ReloadParentEvent>((event, emit) => emit(ReloadParentState()));
    on<ReloadAnswerEvent>((event, emit) => emit(ReloadAnswerState()));
    on<OpenInputEvent>((event, emit) => emit(OpenInputState(event.value)));
    on<GetAvatarEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      emit(GetAvatarState(prefs.getString('image')??''));
    });
    on<LoadListCommentEvent>((event, emit) async {
      emit(CommentState(isShowLoading: true));
      final response = await ProductDetailRepository().loadRatings(
          event.type, event.id.toString(), event.page.toString(), event.sortLike);
      emit(LoadListCommentState(response));
    });
    on<LoadListAnswerEvent>((event, emit) async {
      emit(CommentState(isShowLoading: true));
      final response = await RatingRepository().loadAnswers(event.id, event.page);
      emit(LoadListAnswerState(response));
    });
    on<SendCommentEvent>((event, emit) async {
      final response = await RatingRepository().postRating(
          0, event.content, event.type, event.id.toString(), -1);
      emit(SendCommentState(response));
    });
    on<LikeCommentEvent>((event, emit) async {
      final response = await RatingRepository().likeComment(event.id, event.type);
      emit(LikeCommentState(response));
    });
    on<UnlikeCommentEvent>((event, emit) async {
      final response = await RatingRepository().unlikeComment(event.id, event.type);
      emit(UnlikeCommentState(response));
    });
    on<AnswerCommentEvent>((event, emit) async {
      final response = await RatingRepository().answerComment(event.id, event.content, event.replierId, event.parentId);
      emit(AnswerCommentState(response));
    });
    on<ReportCommentEvent>((event, emit) async {
      final response = await RatingRepository().reportComment(event.id, event.type, event.content);
      emit(ReportCommentState(response));
    });
    on<DeleteCommentEvent>((event, emit) async {
      final response = await RatingRepository().deleteComment(event.id, event.owner, event.isComment);
      emit(DeleteCommentState(response));
    });
    on<EditCommentEvent>((event, emit) async {
      final resp = await RatingRepository().editComment(event.id, event.content, event.owner, event.isComment);
      emit(EditCommentState(resp));
    });
    on<GetCommentEvent>((event, emit) async {
      final response = await RatingRepository().getComment(event.id);
      if (response.checkOK() && response.data.id > 0) emit(GetCommentState(response.data));
    });
    on<LoadImageDtlEvent>((event, emit) async {
      emit(NotificationState(isShowLoading: true));
      final response = await ApiClient().getAPI(Constants().apiVersion + 'images/${event.id}', Post());
      if (response.checkOK()) {
        int i = 0, n = response.data.images.list.length;
        for(; i < n; i++) {
          if (event.id == response.data.images.list[i].id) break;
        }
        emit(LoadImageDtlState(response, i));
      } else emit(NotificationState());
    });
  }
}