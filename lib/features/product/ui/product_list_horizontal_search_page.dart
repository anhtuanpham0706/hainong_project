import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/base_product_list_page.dart';
import 'product_item_horizontal_page.dart';

class ProductListHorizontalSearchPage extends BaseProductListPage {
  ProductListHorizontalSearchPage(shop, {Key? key, catalogueId = '-1',
    productId = '', hasExceptCatalogue = false}) : super(shop, catalogueId: catalogueId, productId:
    productId, hasExceptCatalogue: hasExceptCatalogue, pageState: _ProductListHorizontalPageSearchState(), key: key);
}

class _ProductListHorizontalPageSearchState extends BaseProductListPageState {
  _ProductListHorizontalPageSearchState() : super('') {
    title = 'ttl_other_products';
  }

  @override
  Widget createList(context) => GridView.count(
        controller: scroller, childAspectRatio: 0.58,
        crossAxisCount: 2, shrinkWrap: true,
        padding: EdgeInsets.all(20.sp),
        children: List.generate(list.length,
            (index) => ProductItemHorizontalPage(
                list[index], (widget as BaseProductListPage).shop,
                0.5.sw, loginOrCreateCallback: () => showLoginOrCreate(context))),
      );
}
