import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/multi_language.dart';
import 'package:hainong/features/function/tool/map_task/models/map_data_model.dart';
import 'package:hainong/features/function/tool/map_task/models/map_enum.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_menu_model.dart';
import 'package:hainong/features/shop/ui/import_ui_shop.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import 'package:intl/intl.dart';

//======================================DOCUMENT===========================================//
// feels like day: cảm giác như ngày
// temp min: nhiệt độ tối thiểu
// temp max: nhiệt độ tối đa
// pressure: Áp suất khí quyển
// humidity: độ ẩm
// description: trạng thái
// clouds: đám mây
// pop: khả năng mưa
// uvi: UV

// N lúa:         "0,091-0,18", "0,181-0,27", "0,271-0,36", "0,361-0,45", "> 0,45"
// N cây ăn trái: "0.091-0.18", "0.181-0.27", "0.271-0.36", "0.361-0.45"

// P lúa:        "3,76-7,5", "7,6-11,25", "11,26-15,0", "15,1-18,75", "> 18,75"
// P cây ăn trái: "< 5.25", "5.25-10.5", "10.51-15.7", "15.76-21", "21.1-26.25", "> 26.25"

// K lúa:         "0,076-0,15", "0,151-0,225", "0,226-0,3", "0,31-0,375", "> 0,375"
// K cây ăn trái: "0.091-0.18", "0.181-0.27", "0.271-0.36", "0.361-0.45", "> 0.45"
//======================================DOCUMENT===========================================//
class MapUtils {
  static List<MenuItemMap> menuListMap() => [
        MenuItemMap(id: 1, image: "assets/images/v9/map/ic_map_pet.png", name: "Bản đồ sâu bệnh"),
        MenuItemMap(id: 2, image: "assets/images/v9/map/ic_map_farming.png", name: "Bản đồ canh tác"),
        MenuItemMap(id: 3, image: "assets/images/v9/map/ic_map_weather.png", name: "Bản đồ thời tiết"),
        MenuItemMap(id: 4, image: "assets/images/v9/map/ic_map_model.png", name: "Bản đồ mô hình")
      ];

  static List<MenuItemMap> modelListMap() => [
        MenuItemMap(id: 1, image: "ic_map_model_demo.png", name: "Mô hình"),
        MenuItemMap(id: 2, image: "ic_map_model_store.png", name: "Cửa hàng"),
        MenuItemMap(id: 3, image: "ic_map_model_warehouse.png", name: "Kho hàng"),
      ];

  static List<MenuItemMap> menuListModel() => [
        MenuItemMap(id: 1, image: "assets/images/v9/map/ic_map_model_direction.png", name: "Chỉ đường"),
        MenuItemMap(id: 2, image: "assets/images/v9/map/ic_map_model_share.png", name: "Chia sẻ"),
        MenuItemMap(id: 3, image: "assets/images/v9/map/ic_map_model_update.png", name: "Cập nhật"),
      ];

  static List<MenuItemMap> menuListPet() => [
        MenuItemMap(id: 1, image: "assets/images/v9/map/ic_map_model_direction.png", name: "Chỉ đường"),
        MenuItemMap(id: 2, image: "assets/images/v9/map/ic_map_model_share.png", name: "Chia sẻ"),
        MenuItemMap(id: 3, image: "assets/images/v9/map/ic_map_contribute.png", name: "Đóng góp"),
      ];

  static List<MenuItemMap> regionTreeType() => [
        MenuItemMap(id: 1, image: "", name: "Vùng đồng bằng ven biển cao", value: "Vùng đồng bằng ven biển cao"),
        MenuItemMap(id: 2, image: "", name: "Vùng ven biển", value: "Vùng ven biển"),
        MenuItemMap(id: 3, image: "", name: "Vùng tứ giác Long Xuyên", value: "Vùng tứ giác Long Xuyên"),
        MenuItemMap(id: 4, image: "", name: "Vùng Đồng Tháp mười", value: "Vùng Đồng Tháp mười"),
        MenuItemMap(id: 5, image: "", name: "Vùng Phù Xa (Sông Tiền - Sông hậu)", value: "Vùng Phù Xa (Sông Tiền - Sông hậu)"),
        MenuItemMap(id: 6, image: "", name: "Vùng bán đảo Cà Mau", value: "Vùng bán đảo Cà Mau"),
      ];

  static List<MenuItemMap> farmingTreeType() => [
        MenuItemMap(id: 0, image: "", name: "Canh tác vô cơ", value: "0"),
        MenuItemMap(id: 1, image: "", name: "Canh tác hữu cơ", value: "1"),
      ];

  static List<MenuItemMap> menuNutritionalTypeModel() => [
        MenuItemMap(id: 1, image: "assets/images/v9/map/ic_map_npk.png", name: "N/P/K", value: "npk"),
        MenuItemMap(id: 2, image: "assets/images/v9/map/ic_map_dam.png", name: "Đạm", value: "n"),
        MenuItemMap(id: 3, image: "assets/images/v9/map/ic_map_lan.png", name: "Lân", value: "p"),
        MenuItemMap(id: 4, image: "assets/images/v9/map/ic_map_kali.png", name: "Kali", value: "k"),
        MenuItemMap(id: 5, image: "assets/images/v9/map/ic_map_ph.png", name: "pH", value: "ph"),
        MenuItemMap(id: 6, image: "assets/images/v9/map/ic_map_ec.png", name: "EC", value: "ec"),
      ];

  static List<MenuItemMap> menuNutritionalTypeBottomModel() => [
        MenuItemMap(id: 1, image: "assets/images/v9/map/ic_map_npk.png", name: "Tất cả", value: "npk"),
        MenuItemMap(id: 2, image: "assets/images/v9/map/ic_map_dam.png", name: "Đạm", value: "n"),
        MenuItemMap(id: 3, image: "assets/images/v9/map/ic_map_lan.png", name: "Lân", value: "p"),
        MenuItemMap(id: 4, image: "assets/images/v9/map/ic_map_kali.png", name: "Kali", value: "k")
      ];

  static MenuItemMap menuTreeRiceItem() => MenuItemMap(id: 1, image: "assets/images/v9/map/ic_map_lua.png", name: "Lúa", value: "lua");

  static List<MenuItemMap> menuFruitItem() => [
        MenuItemMap(id: 2, image: "assets/images/v9/map/ic_map_saurieng.png", name: "Sầu riêng", value: "sau_rieng"),
        MenuItemMap(id: 3, image: "assets/images/v9/map/ic_map_buoi.png", name: "Bưởi", value: "buoi"),
        MenuItemMap(id: 4, image: "assets/images/v9/map/ic_map_thanhlong.png", name: "Thanh long", value: "thanh_long"),
        MenuItemMap(id: 5, image: "assets/images/v9/map/ic_map_xoai.png", name: "Xoài", value: "xoai"),
        MenuItemMap(id: 6, image: "assets/images/v9/map/ic_map_cam.png", name: "Cam", value: "cam"),
        MenuItemMap(id: 7, image: "assets/images/v9/map/ic_map_nhan.png", name: "Nhãn", value: "nhan")
      ];

  static List<MenuItemMap> menuTreeValueModel() => [
        MenuItemMap(id: 1, image: "assets/images/v9/map/ic_map_npk.png", name: "N/P/K", value: "npk"),
        MenuItemMap(id: 2, image: "assets/images/v9/map/ic_map_dam.png", name: "Đạm", value: "n"),
        MenuItemMap(id: 3, image: "assets/images/v9/map/ic_map_lan.png", name: "Lân", value: "p"),
        MenuItemMap(id: 4, image: "assets/images/v9/map/ic_map_kali.png", name: "Kali", value: "k"),
        MenuItemMap(id: 5, image: "assets/images/v9/map/ic_map_ph.png", name: "pH", value: "ph"),
        MenuItemMap(id: 6, image: "assets/images/v9/map/ic_map_ec.png", name: "EC", value: "ec"),
      ];

  static List<ColorItemMap> menuNLayerColor() => [
        ColorItemMap(id: 1, value: "0,091-0,18", value2: "0,091-0,18", color: "#59D400"),
        ColorItemMap(id: 1, value: "0,181-0,27", value2: "0.181-0.27", color: "#6AFF00"),
        ColorItemMap(id: 1, value: "0,271-0,36", value2: "0.271-0.36", color: "#00FF00"),
        ColorItemMap(id: 1, value: "0,361-0,45", value2: "0.361-0.45", color: "#FF00FF"),
        ColorItemMap(id: 1, value: "> 0,45", value2: "", color: "#FEF6CE")
      ];

  static List<ColorItemMap> menuPLayerColor() => [
        ColorItemMap(id: 1, value: "3,76-7,5", value2: "< 5.25", color: "#59D400"),
        ColorItemMap(id: 2, value: "7,6-11,25", value2: "5.25-10.5", color: "#6AFF00"),
        ColorItemMap(id: 3, value: "11,26-15,0", value2: "10.51-15.7", color: "#00FF00"),
        ColorItemMap(id: 4, value: "15,1-18,75", value2: "15.76-21", color: "#F0A0E2"),
        ColorItemMap(id: 5, value: "> 18,75", value2: "21.1-26.25", color: "#FF00FF"),
        ColorItemMap(id: 6, value: "> 26.25", value2: "", color: "#FEF6CE"),
      ];

  static List<ColorItemMap> menuKLayerColor() => [
        ColorItemMap(id: 1, value: "0,076-0,15", value2: "0.091-0.18", color: "#59D400"),
        ColorItemMap(id: 2, value: "0,151-0,225", value2: "0.181-0.27", color: "#6AFF00"),
        ColorItemMap(id: 3, value: "0,226-0,3", value2: "0.271-0.36", color: "#00FF00"),
        ColorItemMap(id: 4, value: "0,31-0,375", value2: "0.361-0.45", color: "#FF00FF"),
        ColorItemMap(id: 5, value: "> 0,375", value2: "> 0.45", color: "#FEF6CE"),
      ];

  static List<ColorItemMap> menuPHLayerColor() => [
        ColorItemMap(id: 1, value: "< 5,0", color: "#FFFCA8"),
        ColorItemMap(id: 2, value: "5,0-6,0", color: "#fec300"),
        ColorItemMap(id: 3, value: "6-7,5", color: "#d4a200"),
      ];

  static List<ColorItemMap> menuECLayerColor() => [
        ColorItemMap(id: 1, value: "< 0.8", color: "#b0fdff"),
        ColorItemMap(id: 2, value: "0,8-1,6", color: "#3096f8"),
        ColorItemMap(id: 3, value: "> 1.6", color: "#043e76"),
      ];

  static List<ColorItemMap> riceNColor() => [
        ColorItemMap(id: 1, value: "0,091-0,18", color: "#59D400"),
        ColorItemMap(id: 1, value: "0,181-0,27", color: "#6AFF00"),
        ColorItemMap(id: 1, value: "0,271-0,36", color: "#00FF00"),
        ColorItemMap(id: 1, value: "0,361-0,45", color: "#FF00FF"),
        ColorItemMap(id: 1, value: "> 0,45", color: "#FEF6CE")
      ];

  static List<ColorItemMap> fruitNColor() => [
        ColorItemMap(id: 1, value: "0,091-0,18", color: "#59D400"),
        ColorItemMap(id: 1, value: "0,181-0,27", color: "#6AFF00"),
        ColorItemMap(id: 1, value: "0,271-0,36", color: "#00FF00"),
        ColorItemMap(id: 1, value: "0,361-0,45", color: "#FF00FF"),
        ColorItemMap(id: 1, value: "> 0,45", color: "#FEF6CE")
      ];

  static List<ColorItemMap> ricePColor() => [
        ColorItemMap(id: 1, value: "3,76-7,5", color: "#59D400"),
        ColorItemMap(id: 2, value: "7,6-11,25", color: "#6AFF00"),
        ColorItemMap(id: 3, value: "11,26-15,0", color: "#00FF00"),
        ColorItemMap(id: 4, value: "15,1-18,75", color: "#FF00FF"),
        ColorItemMap(id: 5, value: "> 18,75", color: "#FEF6CE"),
      ];

  static List<ColorItemMap> fruitKColor() => [
        ColorItemMap(id: 1, value: "0,091-0,18", color: "#59D400"),
        ColorItemMap(id: 1, value: "0,181-0,27", color: "#6AFF00"),
        ColorItemMap(id: 1, value: "0,271-0,36", color: "#00FF00"),
        ColorItemMap(id: 1, value: "0,361-0,45", color: "#FF00FF"),
        ColorItemMap(id: 1, value: "> 0,45", color: "#FEF6CE")
      ];

  static List<ColorItemMap> riceKColor() => [
        ColorItemMap(id: 1, value: "0,076-0,15", color: "#59D400"),
        ColorItemMap(id: 2, value: "0,151-0,225", color: "#6AFF00"),
        ColorItemMap(id: 3, value: "0,226-0,3", color: "#00FF00"),
        ColorItemMap(id: 4, value: "0,31-0,375", color: "#FF00FF"),
        ColorItemMap(id: 5, value: "> 0,375", color: "#FEF6CE"),
      ];

  static List<ColorItemMap> fruitPColor() => [
        ColorItemMap(id: 1, value: "0.091-0.18", color: "#59D400"),
        ColorItemMap(id: 2, value: "0.181-0.27", color: "#6AFF00"),
        ColorItemMap(id: 3, value: "0.271-0.36", color: "#00FF00"),
        ColorItemMap(id: 4, value: "0.361-0.45", color: "#FF00FF"),
        ColorItemMap(id: 5, value: "> 0.45", color: "#FEF6CE"),
      ];

  static List<ColorItemMap> pHColor() => [
        ColorItemMap(id: 1, value: "< 5,0", color: "#FFFCA8"),
        ColorItemMap(id: 2, value: "5,0-6,0", color: "#fec300"),
        ColorItemMap(id: 3, value: "6-7,5", color: "#d4a200"),
      ];

  static List<ColorItemMap> eCColor() => [
        ColorItemMap(id: 1, value: "< 0.8", color: "#b0fdff"),
        ColorItemMap(id: 2, value: "0,8-1,6", color: "#3096f8"),
        ColorItemMap(id: 3, value: "> 1.6", color: "#043e76"),
      ];

  static String nameOptionMap(MapMenuEnum _selectMenu) {
    switch (_selectMenu) {
      case MapMenuEnum.pet:
        return "Bản đồ sâu bệnh";
      case MapMenuEnum.nutrition:
        return "Bản đồ canh tác";
      case MapMenuEnum.weather:
        return "Bản đồ thời tiết";
      case MapMenuEnum.model:
        return "Bản đồ mô hình";
      default:
        return "Bản đồ nông nghiệp";
    }
  }

  static String getImageNameModelMap(MapModelEnum _selectMenu) {
    switch (_selectMenu) {
      case MapModelEnum.demonstration:
        return "ic_map_model_marker_demo";
      case MapModelEnum.store:
        return "ic_map_model_marker_store";
      case MapModelEnum.storage:
        return "ic_map_model_marker_storage";
      default:
        return "ic_map_model_marker_demo";
    }
  }

  static String titleTabBodyMap(MapModelEnum _selectMenu) {
    switch (_selectMenu) {
      case MapModelEnum.demonstration:
        return "Mô hình trình diễn";
      case MapModelEnum.store:
        return "Cửa hàng";
      case MapModelEnum.storage:
        return "Kho hàng";
      default:
        return "Mô hình trình diễn";
    }
  }

  static MapModelEnum indexEnumModelMap(int index) {
    switch (index) {
      case 1:
        return MapModelEnum.demonstration;
      case 2:
        return MapModelEnum.store;
      case 3:
        return MapModelEnum.storage;
      default:
        return MapModelEnum.demonstration;
    }
  }

  static MapMenuEnum indexEnumMenuMap(int index) {
    switch (index) {
      case 1:
        return MapMenuEnum.pet;
      case 2:
        return MapMenuEnum.nutrition;
      case 3:
        return MapMenuEnum.weather;
      default:
        return MapMenuEnum.model;
    }
  }

  static String iconModelMap(MapModelEnum _selectMenu) {
    switch (_selectMenu) {
      case MapModelEnum.demonstration:
        return "assets/images/v9/map/ic_map_model_marker_demo.png";
      case MapModelEnum.store:
        return "assets/images/v9/map/ic_map_model_marker_store.png";
      case MapModelEnum.storage:
        return "assets/images/v9/map/ic_map_model_marker_storage.png";
      default:
        return "assets/images/v9/map/ic_map_model_marker_demo.png";
    }
  }

  static IconData iconOptionMap(MapMenuEnum _selectMenu) {
    switch (_selectMenu) {
      case MapMenuEnum.pet:
        return Icons.filter_list_alt;
      case MapMenuEnum.nutrition:
        return Icons.layers;
      default:
        return Icons.filter_list_alt;
    }
  }

  static List<MenuItemMap> menuTreeTypeModel(String type) {
    switch (type) {
      case "npk":
      case "n":
      case "p":
      case "k":
        return menuFruitItem();
      case "ph":
      case "ec":
        return [];
      default:
        return [];
    }
  }

  static List<ColorItemMap> menuLayerColor(String type, typeTree) {
    switch (type) {
      case "n":
        switch (typeTree) {
          case "lua":
            return riceNColor();
          case "sau_rieng":
          case "buoi":
          case "xoai":
          case "cam":
          case "nhan":
          case "thanh_long":
            return fruitNColor();
        }
        break;
      case "p":
        switch (typeTree) {
          case "lua":
            return ricePColor();
          case "sau_rieng":
          case "buoi":
          case "xoai":
          case "cam":
          case "nhan":
          case "thanh_long":
            return fruitPColor();
        }
        break;
      case "k":
        switch (typeTree) {
          case "lua":
            return riceKColor();
          case "sau_rieng":
          case "buoi":
          case "xoai":
          case "cam":
          case "nhan":
          case "thanh_long":
            return fruitKColor();
        }
        break;
      case "ph":
        return pHColor();
      case "ec":
        return eCColor();
    }
    return [];
  }

  static final List<String> imageIconMapPaths = [
    'assets/images/v9/map/pet/1.png',
    'assets/images/v9/map/pet/2.png',
    'assets/images/v9/map/pet/3.png',
    'assets/images/v9/map/pet/4.png',
    'assets/images/v9/map/ic_map_storage_medium.png',
    'assets/images/v9/map/ic_map_storage_large.png',
    'assets/images/v9/map/ic_map_store_medium.png',
    'assets/images/v9/map/ic_map_store_large.png',
    'assets/images/v9/map/ic_map_model_marker_demo.png',
    'assets/images/v9/map/ic_map_model_marker_store.png',
    'assets/images/v9/map/ic_map_model_marker_storage.png',
    'assets/images/v9/map/weather/weather_large.png',
    'assets/images/v9/map/weather/weather_medium.png',
    'assets/images/v9/map/weather/01d.png',
    'assets/images/v9/map/weather/01dd-1.png',
    'assets/images/v9/map/weather/01dd.png',
    'assets/images/v9/map/weather/01ddd.png',
    'assets/images/v9/map/weather/01n.png',
    'assets/images/v9/map/weather/02d.png',
    'assets/images/v9/map/weather/02n.png',
    'assets/images/v9/map/weather/03d.png',
    'assets/images/v9/map/weather/3n.png',
    'assets/images/v9/map/weather/03n.png',
    'assets/images/v9/map/weather/04d.png',
    'assets/images/v9/map/weather/04n.png',
    'assets/images/v9/map/weather/6-02.png',
    'assets/images/v9/map/weather/9d.png',
    'assets/images/v9/map/weather/09d.png',
    'assets/images/v9/map/weather/09n.png',
    'assets/images/v9/map/weather/10d.png',
    'assets/images/v9/map/weather/10dd.png',
    'assets/images/v9/map/weather/10n.png',
    'assets/images/v9/map/weather/11d.png',
    'assets/images/v9/map/weather/11dd.png',
    'assets/images/v9/map/weather/11n.png',
    'assets/images/v9/map/weather/13d.png',
    'assets/images/v9/map/weather/13n.png',
    'assets/images/v9/map/weather/50d.png',
    'assets/images/v9/map/weather/50n.png',
    'assets/images/v9/map/weather/50d-1.png',
  ];

  //======================================HANDLE===========================================//

  static MapDataModel? handleFeaturesData(List<dynamic> features, {bool isPoint = false}) {
    var feature = HashMap.from(features.first);
    try {
      if (isPoint) {
        final data = MapDataModel(
          id: convertFieldKeyToInt(feature, "id"),
          description: feature["properties"]["description"] ?? '',
          lat: feature["geometry"]["coordinates"][1] ?? 0.0,
          lng: feature["geometry"]["coordinates"][0] ?? 0.0,
        );
        return (data.id == -1 || data.id == 0) ? null : data;
      } else {
        final data = MapDataModel(
          id: convertFieldKeyToInt(feature, "id"),
          total_comment: convertFieldKeyToInt(feature, "total_comment"),
          total_user_comments: convertFieldKeyToInt(feature, "total_user_comments"),
          classable_id: convertFieldKeyToInt(feature, "classable_id"),
          description: feature["properties"]["description"] ?? '',
          address: feature["properties"]["address"] ?? "",
          suggest: feature["properties"]["suggest"] ?? "",
          name: feature["properties"]["category_name"] ?? "",
          updated_at: feature["properties"]["updated_at"] ?? "",
          percent: convertFieldKeyToDouble(feature, "percent"),
          rate: convertFieldKeyToDouble(feature, "rate"),
          images: feature["properties"]["image"] ?? [],
          category_image: feature["properties"]["category_image"] ?? '',
          lat: feature["geometry"]["coordinates"][1] ?? 0.0,
          lng: feature["geometry"]["coordinates"][0] ?? 0.0,
          classable_type: feature["properties"]["classable_type"] ?? "TrainingData",
          has_commented: feature["properties"]["has_commented"] ?? false,
          old_rate: convertFieldKeyToDouble(feature, "old_rate"),
          old_comment: feature["properties"]["old_comment"] ?? "",
        );
        return data;
      }
    } catch (e) {
      logDebug(e);
      return null;
    }
  }

  static int convertFieldKeyToInt(HashMap<dynamic, dynamic> feature, String key) {
    try {
      return feature["properties"][key] != null
          ? (feature["properties"][key] is String)
              ? int.parse((feature["properties"][key]))
              : (feature["properties"][key] is double)
                  ? (feature["properties"][key] as double).toInt()
                  : feature["properties"][key]
          : 0;
    } catch (e) {
      return 0;
    }
  }

  static double convertFieldKeyToDouble(HashMap<dynamic, dynamic> feature, String key) {
    try {
      return feature["properties"][key] != null
          ? (feature["properties"][key] is String)
              ? double.parse((feature["properties"][key]))
              : (feature["properties"][key] is int)
                  ? (feature["properties"][key] as int).toDouble()
                  : feature["properties"][key]
          : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static double convertMapKeyToDouble(Map<String, dynamic> feature, String key) {
    try {
      return feature[key] != null
          ? (feature[key] is String)
              ? double.parse((feature[key]))
              : (feature[key] is int)
                  ? (feature[key] as int).toDouble()
                  : feature[key]
          : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static Future<Position> getCurrentPositionMap() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error(MultiLanguage.get('msg_gps_disable'));
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return Future.error(MultiLanguage.get('msg_gps_deny_forever'));
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return Future.error(MultiLanguage.get('msg_gps_denied'));
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static String colorToHex(Color color) => '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  static Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }

  static Future<void> openMapApp(LatLng _origin, LatLng _destination) async {
    final String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Unable open the map.';
    }
  }

  static int calculateTotalBytes(List<FileByte> images) {
    int total = 0;
    for (var fileByte in images) {
      total += fileByte.bytes.length;
    }
    return total;
  }

  static String datetimeToFormat(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    return formattedDate;
  }

  static String datetimeToFormat2(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : "";
  }

  static String getCurrentTimeFormatted() {
    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('dd/MM/yyyy');
    return '${timeFormat.format(now)}; ${dateFormat.format(now)}';
  }

  static String getFormattedDateRange(DateTime? fromDate, DateTime? toDate) {
    if (fromDate == null || toDate == null) {
      return '';
    }
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    final String formattedFromDate = formatter.format(fromDate);
    final String formattedToDate = formatter.format(toDate);
    return '$formattedFromDate - $formattedToDate';
  }
  //======================================HANDLE===========================================//
}

void logDebug(dynamic message) {
  if (kDebugMode) {
    print("MAP=====$message");
  }
}
