import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'handbook_page.dart';

abstract class HandbookEvent extends BaseEvent {}
class LoadListEvent extends HandbookEvent {
  final int page;
  final String keyword;
  final int? idAssigned;
  LoadListEvent(this.page, this.keyword, {this.idAssigned});
}
class ChangeExpandEvent extends HandbookEvent {}
class CreateQuestionEvent extends HandbookEvent {
  final String question;
  CreateQuestionEvent(this.question);
}

class LoadListState extends BaseState {
  final BaseResponse response;
  const LoadListState(this.response);
}
class ChangeExpandState extends BaseState {}
class CreateQuestionState extends BaseState {
  final BaseResponse response;
  const CreateQuestionState(this.response);
}

class HandBookBloc extends BaseBloc {
  HandBookBloc({BaseState init = const BaseState()}) :super(init: init) {
    on<LoadListEvent> ((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiVersion}knowledge_handbooks?keyword=${event.keyword}&page=${event.page}&limit=${Constants().limitPage*2}', HandbooksModel());
      emit(LoadListState(response));
    });
    on<ChangeExpandEvent>((event, emit) => emit(ChangeExpandState()));
    on<CreateQuestionEvent>((event, emit) async {
      final response = await ApiClient().postAPI('${Constants().apiVersion}knowledge_handbooks?question=${event.question}', 'POST', HandbookModel());
      emit(CreateQuestionState(response));
    });
  }
}