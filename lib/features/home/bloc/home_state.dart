import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'import_lib_ui.dart';

class HomeState extends BaseState {
  HomeState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}

class LoadCataloguesHomeState extends HomeState {
  final List<dynamic> response;
  LoadCataloguesHomeState(this.response);
}

class ChangeIndexHomeState extends HomeState {
  final int index;
  ChangeIndexHomeState(this.index);
}

class AddImageHomeState extends HomeState {}

class AddHashTagHomeState extends HomeState {
  final List<dynamic>? filters;
  final String? key;
  AddHashTagHomeState({this.filters, this.key});
}

class CreatePostHomeState extends HomeState {
  final BaseResponse response;
  final BuildContext? context;
  CreatePostHomeState(this.response, {this.context});
}

class LoadPostsHomeState extends HomeState {
  final BaseResponse response;
  LoadPostsHomeState(this.response);
}

class LoadHighlightPostsHomeState extends HomeState {
  final BaseResponse response;
  LoadHighlightPostsHomeState(this.response);
}

class LoadLikePostsHomeState extends HomeState {
  final BaseResponse response;
  LoadLikePostsHomeState(this.response);
}

class ReloadLikePostsHomeState extends HomeState {}

class LoadCatalogueHomeState extends HomeState {
  final dynamic response;
  LoadCatalogueHomeState(this.response);
}

class SharePostHomeState extends HomeState {
  final BaseResponse response;
  final int index;
  SharePostHomeState(this.response, this.index);
}

class LoadPostHomeState extends HomeState {
  final BaseResponse response;
  final int index;
  LoadPostHomeState(this.response, this.index);
}

class LoadImageDtlHomeState extends HomeState {
  final BaseResponse response;
  LoadImageDtlHomeState(this.response);
}

class ReloadPostHomeState extends HomeState {}

class LoadSubPostHomeState extends HomeState {
  final BaseResponse response;
  LoadSubPostHomeState(this.response);
}

class WarningPostHomeState extends HomeState {
  final BaseResponse response;
  final int index;
  WarningPostHomeState(this.response, this.index);
}

class ReportPostHomeState extends HomeState {
  final BaseResponse response;
  final int index;
  ReportPostHomeState(this.response, this.index);
}

class DeletePostHomeState extends HomeState {
  final BaseResponse response;
  final int index;
  DeletePostHomeState(this.response, this.index);
}

class LikePostHomeState extends HomeState {
  final BaseResponse response;
  final int index;
  final String id;
  LikePostHomeState(this.response, this.index, this.id);
}

class UnlikePostHomeState extends HomeState {
  final BaseResponse response;
  final int index;
  final String id;
  UnlikePostHomeState(this.response, this.index, this.id);
}

class LoadShopHomeState extends HomeState {
  final BaseResponse response;
  final BuildContext? context;
  LoadShopHomeState(this.context, this.response);
}

class ReloadHighlightPostsHomeState extends HomeState {}

class ReloadPostsHomeState extends HomeState {}

class TransferPointState extends HomeState {
  final BaseResponse response;
  TransferPointState(this.response);
}

class FollowPostState extends HomeState{
  final BaseResponse response;
  FollowPostState(this.response);
}
class UnFollowPostState extends HomeState{
  final BaseResponse response;
  UnFollowPostState(this.response);
}
class CheckProcessPostAutoState extends HomeState{
  bool? isActive;

  CheckProcessPostAutoState({required this.isActive});
}