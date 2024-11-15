import 'package:hainong/features/function/tool/map_task/models/map_enum.dart';

class MapDeepLinkModel {
  String id;
  String lat;
  String lng;
  String classable_type;
  MapMenuEnum menu;
  MapModelEnum tab;

  MapDeepLinkModel({this.id = '', this.lat = '', this.lng = '', this.menu = MapMenuEnum.pet, this.tab = MapModelEnum.demonstration,this.classable_type = ''});
}
