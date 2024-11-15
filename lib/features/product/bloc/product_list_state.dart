import 'package:hainong/common/base_response.dart';
import 'package:flutter/material.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/models/catalogue_model.dart';

class ProductListState extends BaseState {
  ProductListState({isShowLoading = false}):super(isShowLoading: isShowLoading);
}

class LoadProductsState extends ProductListState {
  final BaseResponse response;
  LoadProductsState(this.response);
}

class AddFavoriteState extends ProductListState {
  final BaseResponse response;
  final BuildContext context;
  AddFavoriteState(this.response, this.context);
}

class RemoveFavoriteState extends ProductListState {
  final BaseResponse response;
  final BuildContext context;
  RemoveFavoriteState(this.response, this.context);
}

class LoadCatalogueState extends ProductListState {
  final BaseResponse response;
  LoadCatalogueState(this.response);
}

class LoadProvincesState extends ProductListState {
  final BaseResponse response;
  LoadProvincesState(this.response);
}

class ChangeCatalogueState extends ProductListState {}

class ChangeProvinceState extends ProductListState {
  final int id;
  ChangeProvinceState({this.id = -1});
}

class ReloadHighlightState extends ProductListState {}

class ExpandedCatalogueState extends ProductListState {}

class SelectedCatalogueState extends ProductListState {}

class ShowCatalogueState extends ProductListState {
  final bool value;
  ShowCatalogueState(this.value);
}

class LoadSubCatalogueState extends ProductListState {
  final List<CatalogueModel> list;
  final int index;
  LoadSubCatalogueState(this.list, this.index);
}

class LoadBAsState extends ProductListState {
  final dynamic bas;
  LoadBAsState(this.bas);
}