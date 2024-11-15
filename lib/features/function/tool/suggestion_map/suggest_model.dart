import 'package:hainong/common/util/util.dart';
import 'package:trackasia_gl/mapbox_gl.dart';

class SuggestionList {
  final List<Suggestion> features = [];
  SuggestionList fromJson(Map<String, dynamic> json) {
    if (Util.checkKeyFromJson(json, 'features')) {
      json['features'].forEach((ele) {
        try {
          features.add(Suggestion().fromJson(ele));
        } catch (_) {}
      });
    }
    return this;
  }
}

class Suggestion {
  String type = '';
  SuggestProperty properties = SuggestProperty();
  SuggestGeometry geometry = SuggestGeometry();

  Suggestion fromJson(Map<String, dynamic> json) {
    type = Util.getValueFromJson(json, 'type', '');
    if (Util.checkKeyFromJson(json, 'properties')) properties.fromJson(json['properties']);
    if (Util.checkKeyFromJson(json, 'geometry')) geometry.fromJson(json['geometry']);
    return this;
  }
}

class SuggestProperty {
  String id, suggest, address, province_name;
  double percent;
  int time, mag;
  SuggestProperty({this.id = '', this.percent = -1, this.time = -1, this.suggest = '',
      this.mag = -1, this.address = '', this.province_name = ''});

  SuggestProperty fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', '');
    percent = Util.getValueFromJson(json, 'percent', .0);
    time = Util.getValueFromJson(json, 'time', -1);
    suggest = Util.getValueFromJson(json, 'suggest', '');
    mag = Util.getValueFromJson(json, 'mag', -1);
    address = Util.getValueFromJson(json, 'address', '');
    province_name = Util.getValueFromJson(json, 'province_name', '');
    return this;
  }
}

class SuggestGeometry {
  String type;
  LatLng coordinates;
  SuggestGeometry({this.type = '', this.coordinates = const LatLng(0, 0)});
  SuggestGeometry fromJson(Map<String, dynamic> json) {
    type = Util.getValueFromJson(json, 'type', '');
    List<double>? temp;
    if (Util.checkKeyFromJson(json, 'coordinates')) {
      temp = json['coordinates'].cast<double>() ?? [0.0, 0.0];
    }
    if (temp != null && temp.isNotEmpty) coordinates = LatLng(temp.last, temp.first);
    return this;
  }
}

class Options {
  final List<Option> list = [];
  Options fromJson(json) {
    if (json.isNotEmpty) json.forEach((item) => list.add(Option().fromJson(item)));
    return this;
  }
}

class Option {
  int id;
  String key, value;
  Option({this.id = -1, this.key = '', this.value = ''});
  Option fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', '');
    key = Util.getValueFromJson(json, 'key', '');
    value = Util.getValueFromJson(json, 'value', '');
    return this;
  }
}
