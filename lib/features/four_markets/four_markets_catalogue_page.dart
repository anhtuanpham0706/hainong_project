import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hainong/common/models/catalogue_model.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:npk_core/service/util.dart';
import '../main/ui/header_main.dart';
import '../product/bloc/product_list_bloc.dart';
import '../product/sub_ui/product_catalogue_item.dart';
import 'four_markets_list_page.dart';

class FourMarketsCatPage extends StatefulWidget {
  const FourMarketsCatPage({Key? key}) : super(key: key);

  @override
  _FourMarketsCatPageState createState() => _FourMarketsCatPageState();
}

class _FourMarketsCatPageState extends State<FourMarketsCatPage> {
  final bloc = ProductListBloc(ProductListState(), type: 'catalogue');
  final List<CatalogueModel> _catalogues = [];
  final Map<String, ItemModel> _selectCats = {};
  int _index = -1;
  String _type = '';

  @override
  void dispose() {
    bloc.close();
    _catalogues.clear();
    _selectCats.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bloc.stream.listen((state) {
      if (state is LoadCatalogueState) _handleLoadCatalogue(state);
      else if (state is LoadSubCatalogueState) _handleLoadSubCatalogue(state);
      else if (state is ChangeProvinceState) bloc.add(LoadCatalogueEvent(type: _type));
      else if (state is SelectedCatalogueState) {
        UtilUI.goToNextPage(context, FourMarketListPage(_selectCats.values.last, _type));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      leading: Padding(child: const HeaderBack(), padding: EdgeInsets.only(left: 40.sp)),
      centerTitle: true, titleSpacing: 0, elevation: 5, leadingWidth: 320.sp,
      //actions: [
      //  IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
      //],
      title: UtilUI.createLabel('Chợ Hai Nông')), backgroundColor: Colors.white,
      body: Row(children: [
        Column(children: [
          _MenuItem('Chợ\nVật Tư', 'ic_materials_market.png', bloc, 0, _changeIndex),
          _MenuItem('Chợ Sỉ\nNông Nghiệp', 'ic_agri_market.png', bloc, 1, _changeIndex),
          _MenuItem('Chợ\nNông Sản', 'ic_farmers_market.png', bloc, 2, _changeIndex),
          _MenuItem('Chợ Nhà\nSản xuất', 'ic_producer_market.png', bloc, 3, _changeIndex),
        ]),
        Expanded(child: BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadCatalogueState,
          builder: (context, state) => ListView.builder(padding: EdgeInsets.only(top: 20.sp),
            physics: const AlwaysScrollableScrollPhysics(), itemCount: _catalogues.length,
            itemBuilder: (context, index) => ProductCatalogueItem(bloc, index, _catalogues[index], _loadSubCatalogue,
                _selectedSub, _unselectedSub, _selectCats, first: -1))))
      ])
    );
  }

  void _changeIndex(int index) {
    if (index != _index) {
      _index = index;
      _setType();
      setState(() => _catalogues.clear());
      bloc.add(ChangeProvinceEvent(id: index));
    }
  }

  void _setType() {
    switch(_index) {
      case 0: _type = 'agricultural_materials_market'; break;
      case 1: _type = 'agricultural_wholesale_market'; break;
      case 2: _type = 'farmers_markets'; break;
      case 3: _type = 'producer_market';
    }
  }

  void _handleLoadCatalogue(LoadCatalogueState state) {
    if (state.response.checkOK() && state.response.data.list != null && state.response.data.list.isNotEmpty) {
      _catalogues.addAll(state.response.data.list);
    }
  }

  void _loadSubCatalogue(int id, int index) {
    final expanded = !_catalogues[index].expanded;
    if (expanded) _catalogues.forEach((element) => element.expanded = false);
    _catalogues[index].expanded = expanded;
    bloc.add(ExpandedCatalogueEvent());
    if (!_catalogues[index].hasSub) bloc.add(LoadSubCatalogueEvent(id, index));
  }

  void _handleLoadSubCatalogue(LoadSubCatalogueState state) {
    if (state.list.isNotEmpty) {
      final cat = _catalogues[state.index];
      if (cat.subList == null) cat.subList = state.list;
      else if (cat.subList!.isEmpty) cat.subList!.addAll(state.list);
      cat.hasSub = true;
    }
  }

  void _selectedSub(int index) {
    _unselectedSub();
    _selectCats.putIfAbsent(_catalogues[index].id.toString() + _catalogues[index].name,
        () => ItemModel(id: _catalogues[index].id.toString(), name: _catalogues[index].name));
    _catalogues[index].selected = true;
    bloc.add(SelectedCatalogueEvent());
  }

  void _unselectedSub() {
    for(int i = _catalogues.length - 1; i > -1; i--) {
      _unselectAll(_catalogues[i]);
    }
  }

  void _unselectAll(CatalogueModel item) {
    _selectCats.remove(item.id.toString()+item.name);
    item.selected = false;
    if (item.hasSub && item.subList != null) for(int i = item.subList!.length - 1; i > -1; i--) _unselectAll(item.subList![i]);
  }
}

class _MenuItem extends StatelessWidget {
  final String title, asset;
  final Function funAction;
  final ProductListBloc bloc;
  final int index;
  const _MenuItem(this.title, this.asset, this.bloc, this.index, this.funAction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final temp = Column(children: [
      Image.asset('assets/images/v8/' + asset, width: 60, height: 60, fit: BoxFit.cover),
      const SizedBox(height: 10),
      LabelCustom(title, color: Colors.black, size: 40.sp, weight: FontWeight.normal, align: TextAlign.center)
    ]);
    return ButtonImageWidget(0, () => funAction(index),
      BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ChangeProvinceState,
      builder: (context, state) {
        bool active = false;
        if (state is ChangeProvinceState) active = index == state.id;
        return Container(child: temp, padding: EdgeInsets.symmetric(vertical: 40.sp, horizontal: 20.sp),
            color: active ? Colors.white : const Color(0xFFEFEFEF), width: 320.sp, margin: const EdgeInsets.only(bottom: 1));
      }));
  }
}
