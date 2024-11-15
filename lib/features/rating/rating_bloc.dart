import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'rating_repository.dart';

class RatingState extends BaseState {
  RatingState({isShowLoading = false}) : super(isShowLoading: isShowLoading);
}

class ChangePointState extends RatingState {
  final int point;
  ChangePointState(this.point) : super();
}

class PostRatingState extends RatingState {
  final BaseResponse response;
  PostRatingState(this.response) : super();
}

class RatingEvent {}

class ChangePointEvent extends RatingEvent {
  final int point;

  ChangePointEvent(this.point);
}

class PostRatingEvent extends RatingEvent {
  final int point;
  final String content;
  final String type;
  final int id;
  final int commentId;

  PostRatingEvent(this.point, this.content, this.type, this.id, this.commentId);
}

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  RatingBloc(RatingState init) : super(init) {
    on<ChangePointEvent>((event, emit) => emit(ChangePointState(event.point)));
    on<PostRatingEvent>((event, emit) async {
      final response = await RatingRepository().postRating(
          event.point, event.content, event.type, event.id.toString(), event.commentId);
      emit(PostRatingState(response));
    });
  }
}
