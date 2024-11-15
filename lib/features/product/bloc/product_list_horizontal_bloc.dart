import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:flutter/material.dart';
import '../repository/product_repository.dart';

class ProListHorState extends BaseState {
  ProListHorState({isShowLoading = false}) : super(isShowLoading: isShowLoading);
}

class LoadProductsHorState extends ProListHorState {
  final BaseResponse response;
  LoadProductsHorState(this.response);
}

class ReloadProductsHorState extends ProListHorState {}

class AddFavoriteState extends ProListHorState {
  final BaseResponse response;
  final BuildContext context;
  AddFavoriteState(this.response, this.context);
}

class RemoveFavoriteState extends ProListHorState {
  final BaseResponse response;
  final BuildContext context;
  RemoveFavoriteState(this.response, this.context);
}

abstract class ProListHorEvent extends BaseEvent {}

class LoadProductsHorEvent extends ProListHorEvent {
  final String keyword;
  final String catalogueId;
  final String provinceId;
  final int page;
  final String productId;
  final bool isHighlight, hasExceptCatalogue;

  LoadProductsHorEvent(this.keyword, this.catalogueId, this.provinceId,
      this.page, this.productId,
      {this.isHighlight = false, this.hasExceptCatalogue = false});
}

class ReloadProductsHorEvent extends ProListHorEvent {}

class AddFavoriteEvent extends ProListHorEvent {
  final String classableType;
  final int classableId;
  final BuildContext context;
  AddFavoriteEvent(this.classableId, this.classableType, this.context);
}

class RemoveFavoriteEvent extends ProListHorEvent {
  final int favoriteId;
  final BuildContext context;
  RemoveFavoriteEvent(this.favoriteId, this.context);
}

class ProListHorBloc extends BaseBloc {
  final repository = ProductRepository();

  ProListHorBloc(ProListHorState init) : super(init:init) {
    on<LoadProductsHorEvent>((event, emit) async {
      emit(ProListHorState(isShowLoading: true));
      final response = await repository.loadProducts(event.keyword,
          event.catalogueId, event.provinceId, event.page.toString(),
          event.productId, isHighlight: event.isHighlight, limit: 5, hasExceptCatalogue: event.hasExceptCatalogue);
      emit(LoadProductsHorState(response));
    });
    on<AddFavoriteEvent>((event, emit) async {
      final response =
      await repository.addFavorite(event.classableId, event.classableType);
      emit(AddFavoriteState(response, event.context));
    });
    on<RemoveFavoriteEvent>((event, emit) async {
      final response = await repository.removeFavorite(event.favoriteId);
      emit(RemoveFavoriteState(response, event.context));
    });
    on<ReloadProductsHorEvent>((event, emit) => emit(ReloadProductsHorState()));
  }
}
