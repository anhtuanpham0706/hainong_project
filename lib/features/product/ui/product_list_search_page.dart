import 'package:hainong/common/ui/base_product_list_page.dart';
import 'product_item_page.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class ProductListSearchPage extends BaseProductListPage {
  ProductListSearchPage(shop, {Key? key, catalogueId = '-1', productId = ''})
    : super(shop, catalogueId: catalogueId, productId: productId,
            pageState: _ProductListPageSearchState(), key: key);
}

class _ProductListPageSearchState extends BaseProductListPageState {
  _ProductListPageSearchState() : super('ttl_similar_products');

  @override
  Widget createList(context) => ListView.builder(
      padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
      controller: scroller, itemCount: list.length,
      itemBuilder: (context, index) => ProductItemPage(
          list[index], (widget as ProductListSearchPage).shop,
          () {}, () {}, () {}, loginOrCreateCallback: () => showLoginOrCreate(context)));
}
