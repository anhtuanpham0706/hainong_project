import 'package:hainong/common/util/util.dart';

class ItemListModel {
  final List<ItemModel> list = [];
  final String? keyName;
  ItemListModel({this.keyName});

  ItemListModel fromJson(data) {
    data.forEach((v) => list.add(ItemModel().fromJson(v, keyName: keyName)));
    return this;
  }

  listsToObjects(List<String> listInt, List<String> listStr) {
    if (listInt.length == listStr.length)
      for (int i = 0; i < listInt.length; i++)
        list.add(ItemModel(id: listInt[i], name: listStr[i]));
  }

  stringsToObjects(List<String> listStr) {
    for (int i = 0; i < listStr.length; i++)
        list.add(ItemModel(id: listStr[i], name: listStr[i]));
  }

  List<String> objectsToStrings() {
    final List<String> tmp = [];
    list.forEach((element) => tmp.add(element.name));
    return tmp;
  }

  List<String> objectsToInts() {
    final List<String> tmp = [];
    list.forEach((element) => tmp.add(element.id));
    return tmp;
  }
}

class ItemModel {
  String id, name;
  bool selected;
  ItemModel({this.id = '', this.name = '', this.selected = false});

  ItemModel fromJson(json, {String? keyName}) {
    id = Util.getValueFromJson(json, 'id', -1).toString();
    name = Util.getValueFromJson(json, keyName??'name', '');
    return this;
  }

  void setValue(String id, String name) {
    this.id = id;
    this.name = name;
  }
}

class ItemListModel2 {
  final List<ItemModel2> list = [];
  final String? keyName;

  ItemListModel2({this.keyName});

  ItemListModel2 fromJson(data) {
    data.forEach((v) => list.add(ItemModel2().fromJson(v, keyName: keyName)));
    return this;
  }
}

class ItemModel2 extends ItemModel {
  String created_at = '', classable_type = '', shop_name = '', shop_image = '';
  int shop_id = -1, classable_id = -1, total_comment = 0, total_like = 0;
  bool user_liked = false, user_comment = false, user_shared = false;

  ItemModel2({String id = '', String name = '', bool selected = false, this.shop_name = ''}):super(id: id, name: name, selected: selected);

  @override
  ItemModel2 fromJson(json, {String? keyName}) {
    super.fromJson(json, keyName: keyName);
    shop_id = Util.getValueFromJson(json, 'shop_id', -1);
    classable_id = Util.getValueFromJson(json, 'classable_id', 0);
    total_comment = Util.getValueFromJson(json, 'total_comment', 0);
    total_like = Util.getValueFromJson(json, 'total_like', 0);
    created_at = Util.getValueFromJson(json, 'created_at', '');
    classable_type = Util.getValueFromJson(json, 'classable_type', '');
    shop_name = Util.getValueFromJson(json, 'shop_name', '');
    shop_image = Util.getValueFromJson(json, 'shop_image', '');
    user_liked = Util.getValueFromJson(json, 'user_liked', false);
    user_comment = Util.getValueFromJson(json, 'user_comment', false);
    user_shared = Util.getValueFromJson(json, 'user_shared', false);
    return this;
  }

  void copyComment(ItemModel2 value) {
    total_comment = value.total_comment;
    user_comment = value.user_comment;
  }
}