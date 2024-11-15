import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/file_byte.dart';
import '../product_model.dart';

abstract class ProductEvent extends BaseEvent {}

class ShowKeyboardEvent extends ProductEvent {
  final bool value;
  ShowKeyboardEvent(this.value);
}

class ShowCataloguesEvent extends ProductEvent {
  final bool value;
  ShowCataloguesEvent(this.value);
}

class SetHeightEvent extends BaseEvent {
  final double height;
  SetHeightEvent(this.height);
}
// class SetHeightState extends BaseState {
//   final double height;
//   SetHeightState(this.height);
// }

class LoadCatalogueProductEvent extends ProductEvent {}
//class EditDescriptionEvent extends ProductEvent {
//  final String description;
//  EditDescriptionEvent(this.description);
//}

class LoadUnitProductEvent extends ProductEvent {}

class LoadImageProductEvent extends ProductEvent {}

class CheckHotPickProductEvent extends ProductEvent {}

class PostProductEvent extends ProductEvent {
  final List<FileByte> list;
  final ProductModel product;
  final int idBusiness;
  PostProductEvent(this.list, this.product, this.idBusiness);
}

class DownloadImagesProductEvent extends ProductEvent {
  final List<ItemModel> list;
  DownloadImagesProductEvent(this.list);
}

class EditProductEvent extends ProductEvent {
  final List<FileByte> list;
  final ProductModel product;
  final String? permission;
  final int idBusiness;
  EditProductEvent(this.list, this.product, this.idBusiness, {this.permission});
}

class PostAdvancePointsEvent extends ProductEvent {
  final int pointableId;
  final String pointableType;
  final String actionChange;
  final String point;
  final bool? isUpdate;
  PostAdvancePointsEvent(this.pointableId, this.actionChange, this.point, {this.pointableType = "product", this.isUpdate = false});
}

class GetAdvancePointsEvent extends ProductEvent {
  final int id;
  final bool isUpdate;
  GetAdvancePointsEvent(this.id, {this.isUpdate = false});
}