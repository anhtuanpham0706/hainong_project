import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import '../shop_model.dart';

class ShopState extends BaseState {
  ShopState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}

class GetPointState extends ShopState {
  final int point;
  GetPointState(this.point);
}

class GetFollowShopState extends ShopState {
  final BaseResponse response;
  GetFollowShopState(this.response);
}
class LoadAlbumUserState extends ShopState {
  final BaseResponse response;
  LoadAlbumUserState(this.response);
}
class LoadListImageAlbumState extends ShopState {
  final BaseResponse response;
  LoadListImageAlbumState(this.response);
}


class FollowShopState extends ShopState {
  final BaseResponse response;
  FollowShopState(this.response);
}

class UnFollowShopState extends ShopState {
  final BaseResponse response;
  UnFollowShopState(this.response);
}

class DeleteProductShopState extends ShopState {
  final BaseResponse response;
  DeleteProductShopState(this.response);
}

class PinProductShopState extends ShopState {
  final BaseResponse response;
  PinProductShopState(this.response);
}

class LoadShopState extends ShopState {
  final ShopModel shop;
  LoadShopState(this.shop);
}

class ChangeTabShopState extends ShopState {
  final int index;
  final bool status;
  ChangeTabShopState(this.index, this.status);
}

class ExpandShopState extends ShopState {
  final bool highlight;
  final bool other;
  ExpandShopState(this.highlight, this.other);
}

class LoadHighlightProductsShopState extends ShopState {
  final BaseResponse response;
  LoadHighlightProductsShopState(this.response);
}

class LoadOtherProductsShopState extends ShopState {
  final BaseResponse response;
  LoadOtherProductsShopState(this.response);
}

class UploadBackgroundImageShopState extends ShopState {
  final BaseResponse response;
  UploadBackgroundImageShopState(this.response);
}

class DeleteBackgroundImageShopState extends ShopState {
  final BaseResponse response;
  DeleteBackgroundImageShopState(this.response);
}

class ReloadBackgroundImageShopState extends ShopState {}

class TransferPointShopState extends ShopState {
  final BaseResponse response;
  TransferPointShopState(this.response);
}

class GetFriendStatusState extends ShopState {
  final String status;
  GetFriendStatusState(this.status);
}

class AddFriendState extends ShopState {
  AddFriendState();
}

class UnFriendState extends ShopState {
  UnFriendState();
}


