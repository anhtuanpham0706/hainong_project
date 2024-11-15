import 'package:hainong/common/language_key.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/multi_language.dart';

class Variant {
  final Map<String, String> values = {};
  final List<ItemModel> imageTypes = [];
  late String locale;
  String image = '';

  Variant() {
    _initImageTypes();
  }

  _initImageTypes() {
    final LanguageKey languageKey = LanguageKey();
    imageTypes
        .add(ItemModel(id: languageKey.lblCamera, name: MultiLanguage.get(languageKey.lblCamera)));
    imageTypes
        .add(ItemModel(id: languageKey.lblGallery, name: MultiLanguage.get(languageKey.lblGallery)));
  }

  dispose() {
    values.clear();
    imageTypes.clear();
  }
}