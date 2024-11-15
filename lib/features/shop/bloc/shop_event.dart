import 'package:hainong/common/base_bloc.dart';

abstract class ShopEvent extends BaseEvent {}

class LoadShopEvent extends ShopEvent {}

class GetFollowShopEvent extends ShopEvent {
  final String type;
  final int id;
  GetFollowShopEvent(this.type, this.id);
}
class LoadAlbumUserEvent extends ShopEvent {
  final int? user_id;
  final int page;
  LoadAlbumUserEvent(this.user_id,this.page);
}
class LoadListImageAlbumEvent extends ShopEvent {
  final int album_id;
  final int page;
  LoadListImageAlbumEvent(this.album_id,this.page);
}


class FollowShopEvent extends ShopEvent {
  final String type;
  final int id;
  FollowShopEvent(this.type, this.id);
}

class UnFollowShopEvent extends ShopEvent {
  final String type;
  final int id;
  UnFollowShopEvent(this.type, this.id);
}

class LoadHighlightProductsShopEvent extends ShopEvent {
  final int shopId, page;
  LoadHighlightProductsShopEvent(this.shopId, this.page);
}

class LoadOtherProductsShopEvent extends ShopEvent {
  final int shopId, page, businessId;
  LoadOtherProductsShopEvent(this.shopId, this.page, this.businessId);
}

class ChangeTabShopEvent extends ShopEvent {
  final int index;
  final bool status;
  ChangeTabShopEvent(this.index, this.status);
}

class DeleteProductShopEvent extends ShopEvent {
  final int productId;
  DeleteProductShopEvent(this.productId);
}

class PinProductShopEvent extends ShopEvent {
  final int productId;
  PinProductShopEvent(this.productId);
}

class ExpandShopEvent extends ShopEvent {
  final bool highlight, other;
  ExpandShopEvent(this.highlight, this.other);
}

class UploadBackgroundImageShopEvent extends ShopEvent {
  final String path;
  UploadBackgroundImageShopEvent(this.path);
}

class ReloadBackgroundImageShopEvent extends ShopEvent {}

class DeleteBackgroundImageShopEvent extends ShopEvent {}

class GetPointEvent extends ShopEvent {}

class TransferPointShopEvent extends ShopEvent {
  final String point, phone;
  TransferPointShopEvent(this.point, this.phone);
}

class GetFriendStatusEvent extends ShopEvent {
  final String userId;
  GetFriendStatusEvent({required this.userId});
}

class PostAddFriendStatusEvent extends ShopEvent {
  final String phone;
  PostAddFriendStatusEvent({required this.phone});
}

class PostUnFriendStatusEvent extends ShopEvent {
  final String friendId;
  PostUnFriendStatusEvent({required this.friendId});
}
