import 'dart:io';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/base_bloc.dart';

class ProductState extends BaseState {
  ProductState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}

class ShowKeyboardState extends ProductState {
  final bool value;
  ShowKeyboardState(this.value);
}

class ShowCataloguesState extends ProductState {
  final bool value;
  ShowCataloguesState(this.value);
}

class LoadImageProductState extends ProductState {}

class CheckHotPickProductState extends ProductState {}

class LoadCatalogueProductState extends ProductState {
  final BaseResponse response;
  LoadCatalogueProductState(this.response);
}
class SetHeightState extends BaseState {
  final double height;
  SetHeightState(this.height);
}

class LoadUnitProductState extends ProductState {
  final BaseResponse response;
  LoadUnitProductState(this.response);
}

class PostProductState extends ProductState {
  final BaseResponse response;
  PostProductState(this.response);
}

class DownloadImagesProductState extends ProductState {
  final List<File> response;
  DownloadImagesProductState(this.response);
}

class EditProductState extends ProductState {
  final BaseResponse response;
  EditProductState(this.response);
}

class AdvancePointsUpdateState extends ProductState {
  final BaseResponse response;
  final bool? isUpdate;
  AdvancePointsUpdateState(this.response, {this.isUpdate = false});
}

class GetAdvancePointsState extends ProductState {
  final BaseResponse data;
  final bool? isUpdate;
  GetAdvancePointsState(this.data, {this.isUpdate = false});
}