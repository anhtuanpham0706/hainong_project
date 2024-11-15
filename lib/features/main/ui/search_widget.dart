import 'package:hainong/common/multi_language.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController _ctrSearch;
  final FocusNode _focusSearch;
  final Function _funSearch;

  const SearchWidget(this._ctrSearch, this._focusSearch, this._funSearch, {Key? key}):super(key:key);

  @override
  Widget build(context) => TextField(
        style: TextStyle(color: Colors.white, fontSize: 35.sp),
        onSubmitted: (value) {
          _focusSearch.requestFocus();
          _funSearch();
        },
        textInputAction: TextInputAction.search,
        controller: _ctrSearch,
        cursorColor: Colors.white,
        decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white),
            isDense: true,
            filled: true,
            fillColor: Colors.black12,
            contentPadding: EdgeInsets.only(
                top: 22.sp, left: 80.sp, right: 80.sp, bottom: 22.sp),
            hintText: MultiLanguage.get('lbl_search'),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(100.sp))));
}