import 'package:hainong/common/language_key.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_list_bloc.dart';
import '../sub_ui/filter_select_option.dart';

class FilterProduct extends StatelessWidget {
  final ProductListBloc _bloc;
  final Map<String,ItemModel> _selectCats;
  final List<ItemModel> _provinces;
  final Map<String, String> _values;
  final Function _funSearch, _funCatalogue;
  const FilterProduct(this._bloc, this._selectCats, this._provinces, this._values, this._funSearch,
      this._funCatalogue, {Key? key}):super(key:key);

  @override
  Widget build(context) => Row(children: [
      Expanded(child: ButtonImageWidget(0, ()=>_funCatalogue(), Padding(
        padding: EdgeInsets.all(40.sp),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(child: BlocBuilder(bloc: _bloc,
                buildWhen: (oldState, newState) => newState is SelectedCatalogueState,
                builder: (context, state) {
                  String text = MultiLanguage.get(LanguageKey().lblCatalogue);
                  if (_selectCats.isNotEmpty) text = _selectCats.values.last.name;
                  return Text(text, style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center);
                })),
                BlocBuilder(bloc: _bloc,
                    buildWhen: (oldState, newState) => newState is ShowCatalogueState,
                    builder: (context, state) {
                      bool show = false;
                      if (state is ShowCatalogueState) show = state.value;
                      return Icon(show ? Icons.arrow_drop_up : Icons.arrow_drop_down);
                    })
        ])))),
      Container(color: Colors.grey.shade300, width: 3.sp, height: 60.sp),
      BlocBuilder(bloc: _bloc,
        buildWhen: (oldState, newState) => newState is ShowCatalogueState,
        builder: (context, state) {
          bool lock = false;
          if (state is ShowCatalogueState) lock = state.value;
          return FilterSelectOption(_bloc, LanguageKey().lblProvince, _provinces, _values, _funSearch, lock: false,showCatalog: lock,);
        })
    ]);
}
