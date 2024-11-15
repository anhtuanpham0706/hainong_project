import 'dart:io';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/home/bloc/import_lib_ui.dart';
import 'package:hainong/features/home/home_repository.dart';
import 'package:hainong/features/product/repository/product_repository.dart';
import 'package:hainong/features/shop/shop_repository.dart';

class PostItemState extends BaseState {
  PostItemState({isShowLoading = false}) : super(isShowLoading: isShowLoading);
}

class FollowPostItemState extends PostItemState {
  final BaseResponse response;
  FollowPostItemState(this.response);
}

class GetFollowPostItemState extends PostItemState {
  final BaseResponse response;
  GetFollowPostItemState(this.response);
}

class DownloadFilesPostItemState extends PostItemState {
  final List<File> response;
  DownloadFilesPostItemState(this.response);
}

class LoadShopPostItemState extends PostItemState {
  final BaseResponse response;
  final BuildContext context;
  LoadShopPostItemState(this.response, this.context);
}

class PostItemEvent extends BaseEvent {}

class FollowPostItemEvent extends PostItemEvent {
  final String type;
  final int id;
  FollowPostItemEvent(this.type, this.id);
}

class GetFollowPostItemEvent extends PostItemEvent {
  final String type;
  final int id;
  GetFollowPostItemEvent(this.type, this.id);
}

class DownloadFilesPostItemEvent extends PostItemEvent {
  final List<ItemModel> list;
  DownloadFilesPostItemEvent(this.list);
}

class LoadShopPostItemEvent extends PostItemEvent {
  final BuildContext context;
  final int shopId;
  LoadShopPostItemEvent(this.context, this.shopId);
}

class PostItemBloc extends BaseBloc {
  PostItemBloc(PostItemState init) : super(init:init) {
    on<FollowPostItemEvent>((event, emit) async {
      final response = await ShopRepository().setFollow(event.type, event.id.toString());
      emit(FollowPostItemState(response));
    });
    on<GetFollowPostItemEvent>((event, emit) async {
      final response = await ShopRepository().getUserFollow(event.type, event.id.toString());
      emit(GetFollowPostItemState(response));
    });
    on<DownloadFilesPostItemEvent>((event, emit) async {
      emit(PostItemState(isShowLoading: true));
      List<File> files = await Util.loadFilesFromNetwork(ProductRepository(), event.list);
      emit(DownloadFilesPostItemState(files));
    });
    on<LoadShopPostItemEvent>((event, emit) async {
      final response = await HomeRepository().loadShop(event.shopId.toString());
      emit(LoadShopPostItemState(response, event.context));
    });
  }
}
