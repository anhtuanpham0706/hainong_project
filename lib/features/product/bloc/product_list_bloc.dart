import 'package:hainong/common/base_bloc.dart';
import '../repository/product_repository.dart';
import 'package:hainong/features/signup/sign_up_repository.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';
export 'product_list_event.dart';
export 'product_list_state.dart';

class ProductListBloc extends BaseBloc {
  final repository = ProductRepository();

  ProductListBloc(ProductListState init, {String type = 'product'}) : super(init:init) {
    if (type == 'producer') {
      on<LoadBAsEvent>((event, emit) async {
        emit(ProductListState(isShowLoading: true));
        final response = await repository.loadBAs(false, param: '/enterprise/all?page=${event.page}&limit=30&keyword='+event.keyword!);
        emit(LoadBAsState(response));
      });
      return;
    }

    on<LoadCatalogueEvent>((event, emit) async {
      final response = await repository.loadCatalogues(event.type);
      emit(LoadCatalogueState(response));
    });
    on<ChangeCatalogueEvent>((event, emit) => emit(ChangeCatalogueState()));
    on<ExpandedCatalogueEvent>((event, emit) => emit(ExpandedCatalogueState()));
    on<SelectedCatalogueEvent>((event, emit) => emit(SelectedCatalogueState()));
    on<ShowCatalogueEvent>((event, emit) => emit(ShowCatalogueState(event.value)));
    on<LoadSubCatalogueEvent>((event, emit) async {
      emit(ProductListState(isShowLoading: true));
      final response = await repository.loadSubCatalogues(event.id);
      if (response.checkOK())
        emit(LoadSubCatalogueState(response.data.list, event.index));
      else emit(LoadSubCatalogueState([], event.index));
    });

    if (type == 'catalogue') {
      on<ChangeProvinceEvent>((event, emit) => emit(ChangeProvinceState(id: event.id)));
      return;
    }

    on<LoadProductsEvent>((event, emit) async {
      emit(ProductListState(isShowLoading: true));
      final response = await repository.loadProducts(event.keyword, event.catalogueId, event.provinceId, event.page.toString(),
          event.productId, isHighlight: event.isHighlight, hasExceptCatalogue: event.hasExceptCatalogue, isMine: event.isMine,
          type: event.type, businessId: event.businessId);
      emit(LoadProductsState(response));
    });
    on<LoadFavouriteProductsEvent>((event, emit) async {
      emit(ProductListState(isShowLoading: true));
      final response = await repository.loadFavouriteProducts(event.page.toString());
      emit(LoadProductsState(response));
    });
    on<AddFavoriteEvent>((event, emit) async {
      final response = await repository.addFavorite(event.classableId, event.classableType);
      emit(AddFavoriteState(response, event.context));
    });
    on<RemoveFavoriteEvent>((event, emit) async {
      final response = await repository.removeFavorite(event.favoriteId);
      emit(RemoveFavoriteState(response, event.context));
    });
    on<LoadProvincesEvent>((event, emit) async {
      final response = await SignUpRepository().loadProvince();
      emit(LoadProvincesState(response));
    });
    on<ChangeProvinceEvent>((event, emit) => emit(ChangeProvinceState()));
    on<ReloadHighlightEvent>((event, emit) => emit(ReloadHighlightState()));
    on<LoadBAsEvent>((event, emit) async {
      final response = await repository.loadBAs(event.isBMarket);
      if (response.checkOK() && response.data.list.isNotEmpty) emit(LoadBAsState(response.data.list));
    });
  }
}
