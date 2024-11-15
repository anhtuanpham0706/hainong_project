import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/models/file_byte.dart';
import '../shop_repository.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class AlbumState extends BaseState {
  AlbumState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}
abstract class AlbumEvent extends BaseEvent {}
// event
class CreateNewAlbumEvent extends ShopEvent{
  final String name;
  CreateNewAlbumEvent(this.name);
}

class MoveImageAlbumEvent extends AlbumEvent {
  final String old_album;
  final String album_id;
  final String image_id;
  MoveImageAlbumEvent(this.old_album,this.album_id,this.image_id);
}
class UpdateNameAlbumEvent extends AlbumEvent {
  final String album_id;
  final String name;
  UpdateNameAlbumEvent(this.album_id,this.name);
}
class RemoveImageAlbumEvent extends AlbumEvent {
  final String album_id;
  final String image_id;
  RemoveImageAlbumEvent(this.album_id,this.image_id);
}
class RemoveAlbumEvent extends AlbumEvent {
  final String album_id;
  RemoveAlbumEvent(this.album_id);
}
class AddImageAlbumEvent extends AlbumEvent {
  final String album_id;
  final List<FileByte> list;
  AddImageAlbumEvent(this.list,this.album_id);
}
//state
class CreateNewAlbumState extends ShopState {
  final BaseResponse response;
  CreateNewAlbumState(this.response);
}
class MoveImageAlbumState extends AlbumState {
  final BaseResponse response;
  MoveImageAlbumState(this.response);
}
class UpdateNameAlbumState extends AlbumState {
  final BaseResponse response;
  UpdateNameAlbumState(this.response);
}
class RemoveImageAlbumState extends AlbumState {
  final BaseResponse response;
  RemoveImageAlbumState(this.response);
}
class RemoveAlbumState extends AlbumState {
  final BaseResponse response;
  RemoveAlbumState(this.response);
}
class AddImageAlbumState extends AlbumState {
  final BaseResponse response;
  AddImageAlbumState(this.response);
}



class AlbumBloc extends BaseBloc {
  final repository = ShopRepository();
  AlbumBloc(AlbumState init):super(init:init) {
    on<LoadListImageAlbumEvent>((event, emit) async {
      emit(AlbumState(isShowLoading: true));
      final response = await repository.loadListImageAlbum(event.album_id,event.page.toString());
      emit(LoadListImageAlbumState(response));
    });
    on<UpdateNameAlbumEvent>((event, emit) async {
      emit(AlbumState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}user_albums/${event.album_id}', 'PUT', BaseResponse(),
      body: {'name': event.name});
      emit(UpdateNameAlbumState(response));
    });
    on<MoveImageAlbumEvent>((event, emit) async {
      emit(AlbumState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}user_albums/${event.old_album}/images/${event.image_id}', 'PUT', BaseResponse(),
        body: {'user_album_id': event.album_id}
          );
      emit(MoveImageAlbumState(response));
    });
    on<RemoveImageAlbumEvent>((event, emit) async {
      emit(AlbumState(isShowLoading: true));
      final response = await repository.removeImage(event.album_id,event.image_id);
      emit(RemoveImageAlbumState(response));
    });
    on<RemoveAlbumEvent>((event, emit) async {
      emit(AlbumState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}user_albums/${event.album_id}', 'DELETE', BaseResponse());
      emit(RemoveAlbumState(response));
    });
    on<AddImageAlbumEvent>((event, emit) async {
      emit(AlbumState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}user_albums/${event.album_id}/create_image', 'POST', BaseResponse(),
          realFiles: event.list, paramFile: 'attachment[file][]');
      emit(AddImageAlbumState(response));
    });
    }
  }