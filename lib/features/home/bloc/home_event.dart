import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/features/post/model/post.dart';
import 'import_lib_ui.dart';

abstract class HomeEvent extends BaseEvent {}

class LoadCataloguesHomeEvent extends HomeEvent {}

class ChangeIndexHomeEvent extends HomeEvent {
  final int index;
  ChangeIndexHomeEvent(this.index);
}

class LoadPostsHomeEvent extends HomeEvent {
  final String key, hashTag, shopId;
  final int page;
  final bool isMyPost, showLoading;
  LoadPostsHomeEvent(this.key, this.page, {this.isMyPost = false, this.hashTag = '', this.showLoading = false, this.shopId = ''});
}

class LoadLikePostsHomeEvent extends HomeEvent {
  final int page;
  LoadLikePostsHomeEvent(this.page);
}

class ReloadLikePostsHomeEvent extends HomeEvent {}

class LoadHighlightPostsHomeEvent extends HomeEvent {
  final int page;
  LoadHighlightPostsHomeEvent(this.page);
}

class ShowLoadingHomeEvent extends HomeEvent {
  final bool isShow;
  ShowLoadingHomeEvent(this.isShow);
}

class AddImageHomeEvent extends HomeEvent {}

class AddHashTagHomeEvent extends HomeEvent {
  final List<dynamic>? filters;
  final String? key;
  AddHashTagHomeEvent({this.filters, this.key});
}

class CreatePostHomeEvent extends HomeEvent {
  final List<String> files, hashTags;
  final List<FileByte>? realFiles;
  final String title, description, id, permission, idAlbum;
  final BuildContext? context;
  CreatePostHomeEvent(this.files, this.hashTags, this.title, this.description, this.id, {this.context, this.realFiles, this.permission = '', this.idAlbum = ''});
}

class SharePostHomeEvent extends HomeEvent {
  final Post item;
  final String des;
  final int index;
  final List<String> hashTags;
  SharePostHomeEvent(this.item, this.des, this.index, this.hashTags);
}

class LoadPostHomeEvent extends HomeEvent {
  final String id;
  final int index;
  LoadPostHomeEvent(this.id, this.index);
}

class LoadImageDtlHomeEvent extends HomeEvent {
  final String id, postId;
  LoadImageDtlHomeEvent(this.id, this.postId);
}

class ReloadPostHomeEvent extends HomeEvent {}

class LoadCatalogueHomeEvent extends HomeEvent {}

class LoadSubPostHomeEvent extends HomeEvent {
  final String id;
  LoadSubPostHomeEvent(this.id);
}

class WarningPostHomeEvent extends HomeEvent {
  final String id, imageId;
  final String reason;
  final int index;
  WarningPostHomeEvent(this.id, this.reason, this.index, {this.imageId = ''});
}

class ReportPostHomeEvent extends HomeEvent {
  final String classableType;
  final String classableId;
  ReportPostHomeEvent(this.classableId, this.classableType);
}

class DeletePostHomeEvent extends HomeEvent {
  final String id, permission;
  final int index;
  DeletePostHomeEvent(this.id, this.index, this.permission);
}

class LikePostHomeEvent extends HomeEvent {
  final String classableType;
  final String classableId;
  final int index;
  final dynamic response;
  LikePostHomeEvent(this.classableId, this.classableType, this.index, {this.response});
}

class UnlikePostHomeEvent extends HomeEvent {
  final String classableType;
  final String classableId;
  final int index;
  final dynamic response;
  UnlikePostHomeEvent(this.classableId, this.classableType, this.index, {this.response});
}

class LoadShopHomeEvent extends HomeEvent {
  final String id;
  final BuildContext? context;
  LoadShopHomeEvent(this.context, this.id);
}

class ReloadHighlightPostsHomeEvent extends HomeEvent {}

class ReloadPostsHomeEvent extends HomeEvent {}

class TransferPointEvent extends HomeEvent {
  final String point, userId;
  TransferPointEvent(this.point, this.userId);
}

class FollowPostEvent extends HomeEvent{
  final String classableType;
  final String classableId;
  final dynamic response;
  FollowPostEvent(this.classableType, this.classableId, {this.response});
}

class UnFollowPostEvent extends HomeEvent{
  final String classableType;
  final String classableId;
  final dynamic response;
  UnFollowPostEvent(this.classableType, this.classableId, {this.response});
}

class CheckProcessPostAutoEvent extends HomeEvent{

}