// import 'package:hainong/common/util/util.dart';
// import 'nutrition_map_page.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';

// class NutritionModels {
//   final List<Marker> list = [];
//   Future<NutritionModels> fromJson(json, map, funOnTouch) async {
//     if (Util.checkKeyFromJson(json, 'features')) {
//       json = json['features'];
//       if (json.isNotEmpty) {
//         final Map<String, Marker> temp = {};
//         for(int i = json.length - 1; i > -1; i--) {
//           try {
//             final data = NutritionModel().fromJson(json[i]);
//             String key = data.lat.toString() + data.lng.toString();
//             if (temp.containsKey(key)) {
//               temp[key]!.data.add(data);
//             } else {
//               final point = await map.toScreenLocation(LatLng(data.lat, data.lng));
//               final marker = Marker([data], point, funOnTouch);
//               temp.putIfAbsent(key, () => marker);
//             }
//           } catch (_) {}
//         }
//         list.addAll(temp.values);
//       }
//     }
//     return this;
//   }
// }

// class NutritionModel {
//   double salinity = .0, pH = .0, lat = .0, lng = .0, n = .0, p = .0, k = .0, s = .0, ca = .0, organic = .0;
//   String province_name = '', district_name = '', address = '', harvest = '', harvest_description = '', plant_name = '',
//       plant_description = '', nutrition = '', id = '-1';
//   NutritionModel fromJson(Map<String, dynamic> data) {
//     if (Util.checkKeyFromJson(data, 'properties')) {
//       dynamic json = data['properties'];
//       id = Util.getValueFromJson(json, 'id', '-1').toString();
//       salinity = Util.getValueFromJson(json, 'salinity', -1.0);
//       pH = Util.getValueFromJson(json, 'pH', -1.0);
//       harvest = Util.getValueFromJson(json, 'harvest', '');
//       harvest_description = Util.getValueFromJson(json, 'harvest_description', '');
//       plant_name = Util.getValueFromJson(json, 'plant_name', '');
//       plant_description = Util.getValueFromJson(json, 'plant_description', '');
//       nutrition = Util.getValueFromJson(json, 'nutrition', '');
//       n = Util.getValueFromJson(json, 'nutrition_n', .0);
//       p = Util.getValueFromJson(json, 'nutrition_p', .0);
//       k = Util.getValueFromJson(json, 'nutrition_k', .0);
//       s = Util.getValueFromJson(json, 'nutrition_s', .0);
//       ca = Util.getValueFromJson(json, 'nutrition_ca', .0);
//       organic = Util.getValueFromJson(json, 'nutrition_organic', .0);
//       province_name = Util.getValueFromJson(json, 'province_name', '');
//       district_name = Util.getValueFromJson(json, 'district_name', '');
//       address = Util.getValueFromJson(json, 'address', '');
//       if (Util.checkKeyFromJson(data, 'geometry')) {
//         json = data['geometry'];
//         if (Util.checkKeyFromJson(json, 'coordinates')) {
//           json = json['coordinates'];
//           if (json.length == 2) {
//             lng = json[0]??.0;
//             lat = json[1]??.0;
//           }
//         }
//       }
//     }
//     return this;
//   }

//   bool isAll() => salinity > -1.0 && pH > -1.0 && nutrition.isNotEmpty;
//   bool isSaPh() => salinity > -1.0 && pH > -1.0 && nutrition.isEmpty;
//   bool isSaNu() => salinity > -1.0 && pH == -1.0 && nutrition.isNotEmpty;
//   bool isPhNu() => salinity == -1.0 && pH > -1.0 && nutrition.isNotEmpty;
//   bool isSa() => salinity > -1.0 && pH == -1.0 && nutrition.isEmpty;
//   bool isPh() => salinity == -1.0 && pH > -1.0 && nutrition.isEmpty;
//   bool isNu() => salinity == -1.0 && pH == -1.0 && nutrition.isNotEmpty;
// }