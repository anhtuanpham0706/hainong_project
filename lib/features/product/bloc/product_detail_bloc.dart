import 'dart:convert';

import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/base_bloc.dart';
import '../repository/product_detail_repository.dart';

class ProductDetailState extends BaseState {
  ProductDetailState({isShowLoading = false})
      : super(isShowLoading: isShowLoading);
}

class ChangeTabProDtlState extends ProductDetailState {}

class HeightEvent extends ProductDetailEvent {
  final double height;
  HeightEvent(this.height);
}
class HeightState extends ProductDetailState {
  final double height;
  HeightState(this.height);
}

class LoadRatingsProDtlState extends ProductDetailState {
  final BaseResponse response;
  LoadRatingsProDtlState(this.response);
}

class GetProDtlState extends ProductDetailState {
  final BaseResponse response;
  GetProDtlState(this.response);
}

class RefreshStarProDtlState extends ProductDetailState {}

class HideSimilarListState extends ProductDetailState {}
class HideOtherListState extends ProductDetailState {}

class DeleteState extends ProductDetailState {
  final BaseResponse response;
  DeleteState(this.response);
}

class GetReferralProductState extends ProductDetailState {
  final String link;
  GetReferralProductState(this.link);
}

class ProductDetailEvent extends BaseEvent {}

class DeleteEvent extends ProductDetailEvent {
  final int id;
  final String? permission;
  DeleteEvent(this.id, this.permission);
}

class ChangeTabProDtlEvent extends ProductDetailEvent {}

class RefreshStarProDtlEvent extends ProductDetailEvent {}

class GetProDtlEvent extends ProductDetailEvent {
  final int id;
  GetProDtlEvent(this.id);
}

class HideSimilarListEvent extends ProductDetailEvent {}
class HideOtherListEvent extends ProductDetailEvent {}

class ChangeIndexSlideEvent extends ProductDetailEvent {
  final int index;
  ChangeIndexSlideEvent(this.index);
}

class GetReferralProductEvent extends ProductDetailEvent {
  final int id;
  GetReferralProductEvent(this.id);
}

class ChangeIndexSlideState extends ProductDetailState {
  final int index;
  ChangeIndexSlideState(this.index);
}

class ProductDetailBloc extends BaseBloc {
  ProductDetailBloc(ProductDetailState init) : super(init: init) {
    on<ChangeIndexSlideEvent>((event, emit) => emit(ChangeIndexSlideState(event.index)));
    on<ChangeTabProDtlEvent>((event, emit) => emit(ChangeTabProDtlState()));
    on<RefreshStarProDtlEvent>((event, emit) => emit(RefreshStarProDtlState()));
    on<GetProDtlEvent>((event, emit) async {
      emit(ProductDetailState(isShowLoading: true));
      final response = await ProductDetailRepository().getProductDetail(event.id);
      emit(GetProDtlState(response));
    });
    on<HeightEvent>((event, emit) => emit(HeightState(event.height)));
    on<HideSimilarListEvent>((event, emit) => emit(HideSimilarListState()));
    on<HideOtherListEvent>((event, emit) => emit(HideOtherListState()));
    on<DeleteEvent>((event, emit) async {
      emit(ProductDetailState(isShowLoading: true));
      final response = await ProductDetailRepository().delete(event.id, event.permission);
      emit(DeleteState(response));
    });
    on<GetReferralProductEvent>((event, emit) async {
      emit(ProductDetailState(isShowLoading: true));
      final response = await ProductDetailRepository().getRefeffalLinkProduct(event.id);
      if (response.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response);
        emit(GetReferralProductState(json["data"]));
      } else {
        emit(GetReferralProductState(""));
      }
    });
  }
}
