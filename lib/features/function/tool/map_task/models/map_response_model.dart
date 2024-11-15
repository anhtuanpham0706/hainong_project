import 'dart:ui';

import 'package:hainong/common/util/util.dart';


class MapResponseModel {
  Map<String, dynamic>? data;
  MapResponseModel({this.data});

  MapResponseModel fromJson(Map<String, dynamic>? json) {
    data = json;
    return this;
  }

  void setValue(Map<String, dynamic> data) {
    this.data = data;
  }
}

class MapGeoJsonModel{
  String? sourceId;
  String? layerId;
  Color? color;
  Map<String, dynamic> data;

  MapGeoJsonModel(this.data, {this.color, this.sourceId, this.layerId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapGeoJsonModel && runtimeType == other.runtimeType && sourceId == other.sourceId;

  @override
  int get hashCode => layerId.hashCode;
}