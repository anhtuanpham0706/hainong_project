import 'dart:io';
import 'package:hainong/common/base_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../repository/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

export 'product_event.dart';
export 'product_state.dart';

class ProductBloc extends BaseBloc {
  final repository = ProductRepository();

  ProductBloc({BaseState init = const BaseState(), bool hasUpdateInfo = false}) : super(init:init, hasUpdateInfo: hasUpdateInfo) {
    on<ShowKeyboardEvent>((event, emit) => emit(ShowKeyboardState(event.value)));
    on<LoadCatalogueProductEvent>(_handleLoadCatalogue);
    on<LoadUnitProductEvent>(_handleLoadUnit);
    on<LoadImageProductEvent>((event, emit) => emit(LoadImageProductState()));
    on<PostProductEvent>(_handlePostProduct);
    on<EditProductEvent>(_handleEditProduct);
    on<DownloadImagesProductEvent>(_handleDownloadImages);
    on<CheckHotPickProductEvent>((event, emit) => emit(CheckHotPickProductState()));
    //on<EditDescriptionEvent> ((event, emit) => emit(EditDescriptionState(event.description)));
    on<ShowCataloguesEvent>((event, emit) => emit(ShowCataloguesState(event.value)));
    on<SetHeightEvent>((event, emit) => emit(SetHeightState(event.height)));
    on<PostAdvancePointsEvent>(_postAdvancePoints);
    on<GetAdvancePointsEvent>(_getAdvancePoints);
  }

  _handleLoadCatalogue(event, emit) async {
    emit(ProductState(isShowLoading: true));
    final response = await repository.loadCatalogue();
    emit(LoadCatalogueProductState(response));
  }

  _handleLoadUnit(event, emit) async {
    emit(ProductState(isShowLoading: true));
    final response = await repository.loadUnit();
    emit(LoadUnitProductState(response));
  }

  _handlePostProduct(event, emit) async {
    emit(ProductState(isShowLoading: true));
    final response = await repository.postProduct(event.list, event.product, event.idBusiness);
    emit(PostProductState(response));
  }

  _handleEditProduct(event, emit) async {
    emit(ProductState(isShowLoading: true));
    final response = await repository.editProduct(event.list, event.product, event.idBusiness, permission: event.permission);
    emit(EditProductState(response));
  }

  _handleDownloadImages(event, emit) async {
    emit(ProductState(isShowLoading: true));
    final List<File> list = [];
    final String path = await _localPath();
    for(int i = 0; i < event.list.length; i++) {
      final File? file = await repository.downloadImage(event.list[i].name, path);
      if (file != null) list.add(file);
    }
    emit(DownloadImagesProductState(list));
  }
  // int pointableId, String pointableType, String actionChange

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path + '/images/';
  }

  _postAdvancePoints(event, emit) async {
    emit(ProductState(isShowLoading: true));
    final response = await repository.postAdvancePoint(event.pointableId, event.pointableType, event.actionChange, event.point);
    emit(AdvancePointsUpdateState(response, isUpdate: event.isUpdate));
  }

  _getAdvancePoints(event, emit) async {
    emit(ProductState(isShowLoading: true));
    final response = await repository.getAdvancePoints(event.id);
    emit(GetAdvancePointsState(response, isUpdate: event.isUpdate));
  }
}