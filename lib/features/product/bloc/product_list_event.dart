import 'package:flutter/cupertino.dart';
import 'package:hainong/common/base_bloc.dart';

abstract class ProductListEvent extends BaseEvent{}

class LoadProductsEvent extends ProductListEvent {
  final String keyword, catalogueId, provinceId, productId, type;
  final int page, businessId;
  final bool isHighlight, hasExceptCatalogue, isMine;
  LoadProductsEvent(this.keyword, this.catalogueId, this.provinceId, this.page,
    this.productId, {this.isHighlight = false, this.hasExceptCatalogue = false,
    this.isMine = false, this.type = '', this.businessId = -1});
}

class LoadFavouriteProductsEvent extends ProductListEvent {
  final int page;
  LoadFavouriteProductsEvent(this.page);
}

class AddFavoriteEvent extends ProductListEvent {
  final String classableType;
  final int classableId;
  final BuildContext context;
  AddFavoriteEvent(this.classableId, this.classableType, this.context);
}

class RemoveFavoriteEvent extends ProductListEvent {
  final int favoriteId;
  final BuildContext context;
  RemoveFavoriteEvent(this.favoriteId, this.context);
}

class LoadCatalogueEvent extends ProductListEvent {
  final String type;
  LoadCatalogueEvent({this.type = ''});
}

class LoadProvincesEvent extends ProductListEvent {}

class ChangeCatalogueEvent extends ProductListEvent {}

class ChangeProvinceEvent extends ProductListEvent {
  final int id;
  ChangeProvinceEvent({this.id = -1});
}

class ReloadHighlightEvent extends ProductListEvent {}

class ExpandedCatalogueEvent extends ProductListEvent {}

class SelectedCatalogueEvent extends ProductListEvent {}

class ShowCatalogueEvent extends ProductListEvent {
  final bool value;
  ShowCatalogueEvent(this.value);
}

class LoadSubCatalogueEvent extends ProductListEvent {
  final int id, index;
  LoadSubCatalogueEvent(this.id, this.index);
}

class LoadBAsEvent extends ProductListEvent {
  final int? page;
  final String? keyword;
  final bool isBMarket;
  LoadBAsEvent({this.isBMarket = false, this.page, this.keyword});
}