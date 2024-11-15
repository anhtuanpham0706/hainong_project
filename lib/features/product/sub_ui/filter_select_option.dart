import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/models/item_list_model.dart';
import '../bloc/product_list_bloc.dart';

class FilterSelectOption extends StatelessWidget {
  final String _title;
  final List<ItemModel> _list;
  final ProductListBloc _bloc;
  final Map<String, String> _values;
  final Function _funSearch;
  final bool lock,showCatalog;
  const FilterSelectOption(this._bloc, this._title, this._list, this._values, this._funSearch,
      {this.lock = false,this.showCatalog = false ,Key? key}):super(key:key);

  @override
  Widget build(context) => Expanded(child: ButtonImageWidget(0, () => _selectOption(_list, _title, context),
      Padding(padding: EdgeInsets.all(40.sp),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(child: BlocBuilder(bloc: _bloc,
            buildWhen: (state1, state2) => state2 is ChangeProvinceState,
            builder: (context, state) => Text(_values[_title]!.isNotEmpty
              ? _values[_title + 'Name']! : MultiLanguage.get(_title),
              style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
          const Icon(Icons.arrow_drop_down)
        ]))));

  _setOption(String key, {id = '', name = ''}) {
    _values.update(key, (value) => id, ifAbsent: () => id);
    _values.update(key + 'Name', (value) => name, ifAbsent: () => name);
    //if (_bloc != null) {
      //final LanguageKey languageKey = LanguageKey();
      //if (key == languageKey.lblCatalogue)
      //  _bloc.add(ChangeCatalogueEvent());
      //else

      _bloc.add(ChangeProvinceEvent());
    Util.trackActivities('products', path: 'Products Screen -> Show filter for $name');
      _funSearch();
    //}
  }

  _selectOption(List<ItemModel> list, String key, BuildContext context) {
    if(showCatalog) _bloc.add(ShowCatalogueEvent(false));
    if (!lock) UtilUI.showOptionDialog(context, MultiLanguage.get(key), list, _values[key]!)
      .then((value) => _setOption(key, id: value!.id, name: value.name));
  }
}
