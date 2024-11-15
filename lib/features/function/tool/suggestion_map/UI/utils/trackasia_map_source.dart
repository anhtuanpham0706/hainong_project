import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import '../../../map_task/models/map_enum.dart';
import 'trackasia_util.dart';

class TrackasiaMapSource {
  //================MAP CHART LAYER==============//
  Future<void>? addTrackasiaClusterMap({required TrackasiaMapController? mapController, required String sourceId, required Map<String, dynamic> dataMap, required String keyChartName}) async {
    final keyChartImageCircleRate = keyChartName + "_chart_image_circle_rate";
    final keyChartCircleRate = keyChartName + "_chart_circle_rate";
    final keyChartChildren = keyChartName + "_chart_circle_children";
    final keyChartCircleCount = keyChartName + "_chart_circle_count";
    if (dataMap.isNotEmpty) {
      dataMap["type"] = "FeatureCollection";
      await addClusteredPointSource(mapController: mapController, sourceId: sourceId, data: dataMap);
      await addClusteredPointLayers(
          mapController: mapController,
          sourceId: sourceId,
          keyChartImageCircleRate: keyChartImageCircleRate,
          keyChartCircleRate: keyChartCircleRate,
          keyChartChildren: keyChartChildren,
          keyChartCircleCount: keyChartCircleCount);
    }
  }

  Future<void>? addPetClusterMap({required TrackasiaMapController? mapController, required String sourceId, required Map<String, dynamic> dataMap, required String keyChartName}) async {
    final keyChartImageCircleRate = keyChartName + "_chart_image_circle_rate";
    final keyChartCircleRate = keyChartName + "_chart_circle_rate";
    final keyChartChildren = keyChartName + "_chart_circle_children";
    final keyPetChildren = keyChartName + "_pet_circle_children";
    final keyChartCircleCount = keyChartName + "_chart_circle_count";
    if (dataMap.isNotEmpty) {
      dataMap["type"] = "FeatureCollection";
      await addClusteredPointSource(mapController: mapController, sourceId: sourceId, data: dataMap);
      await addPetClusteredPointLayers(
          mapController: mapController,
          sourceId: sourceId,
          keyChartImageCircleRate: keyChartImageCircleRate,
          keyChartCircleRate: keyChartCircleRate,
          keyChartChildren: keyChartChildren,
          keyPetChildren: keyPetChildren,
          keyChartCircleCount: keyChartCircleCount);
    }
  }

  Future<void>? addWeatherClusterMap({required TrackasiaMapController? mapController, required String sourceId, required Map<String, dynamic> dataMap, required String keyChartName}) async {
    final keyImage = keyChartName + "_image";
    final keyCircle = keyChartName + "_circle";
    final keyCircleCount = keyChartName + "_circle_count";
    final keyCircleColor = keyChartName + "_circle_color";
    if (dataMap.isNotEmpty) {
      await addClusteredPointSource(mapController: mapController, sourceId: sourceId, data: dataMap, maxZoom: 11);
      await addClusteredWeatherLayers(
          mapController: mapController, sourceId: sourceId, keyChartImage: keyImage, keyChartCircle: keyCircle, keyChartCircleCount: keyCircleCount, keyCircleColor: keyCircleColor);
    }
  }

  Future<void>? addModelClusterMap(
      {required TrackasiaMapController? mapController,
      required MapModelEnum model,
      required String sourceId,
      required Map<String, dynamic> dataMap,
      required String keyChartName,
      required String image}) async {
    final keyImage = keyChartName + "_image";
    final keyText = keyChartName + "_text";
    final keyCircle = keyChartName + "_circle";
    final keyCircleCount = keyChartName + "_circle_count";
    if (dataMap.isNotEmpty) {
      await addClusteredPointSource(mapController: mapController, sourceId: sourceId, data: dataMap, maxZoom: 10);
      await addClusteredModelLayers(
          mapController: mapController, model: model, sourceId: sourceId, keyImage: keyImage, keyText: keyText, keyCircle: keyCircle, keyCircleCount: keyCircleCount, image: image);
    }
  }

  Future<void>? addClusteredPointSource({required TrackasiaMapController? mapController, required String sourceId, required Map<String, dynamic>? data, double? maxZoom}) async {
    final sourceIds = await mapController?.getSourceIds();
    if (sourceIds?.contains(sourceId) == true) {
      logDebug("===SET GEOJSON ===>$sourceId");
      return mapController?.setGeoJsonSource(sourceId, data!);
    } else {
      logDebug("===ADD GEOJSON ===>$sourceId");
      return mapController?.addSource(sourceId, GeojsonSourceProperties(data: data, cluster: true, clusterMaxZoom: maxZoom ?? 10));
    }
  }

  Future<void> addClusteredPointLayers(
      {required TrackasiaMapController? mapController,
      required String sourceId,
      required String keyChartImageCircleRate,
      required String keyChartCircleRate,
      required String keyChartChildren,
      required String keyChartCircleCount}) async {
    await addImageCircleRate(mapController: mapController, keyLayer: keyChartImageCircleRate);
    await addChartCircleRate(mapController: mapController, sourceId: sourceId, keyLayer: keyChartCircleRate, keyImage: keyChartImageCircleRate);
    await addChartChildren(mapController: mapController, sourceId: sourceId, keyLayer: keyChartChildren);
    await addCircleCount(mapController: mapController, sourceId: sourceId, keyLayer: keyChartCircleCount);
  }

  Future<void> addPetClusteredPointLayers(
      {required TrackasiaMapController? mapController,
      required String sourceId,
      required String keyChartImageCircleRate,
      required String keyChartCircleRate,
      required String keyChartChildren,
      required String keyPetChildren,
      required String keyChartCircleCount}) async {
    await addImageCircleRate(mapController: mapController, keyLayer: keyChartImageCircleRate);
    await addChartCircleRate(mapController: mapController, sourceId: sourceId, keyLayer: keyChartCircleRate, keyImage: keyChartImageCircleRate);
    // await addChartChildren(mapController: mapController, sourceId: sourceId, keyLayer: keyChartChildren);
    await addPetCircleColor(mapController: mapController, sourceId: sourceId, keyLayer: keyChartChildren);
    await addIconPetChildren(mapController: mapController, sourceId: sourceId, keyLayer: keyPetChildren);
    await addCircleCount(mapController: mapController, sourceId: sourceId, keyLayer: keyChartCircleCount);
  }

  Future<void> addClusteredWeatherLayers(
      {required TrackasiaMapController? mapController,
      required String sourceId,
      required String keyChartImage,
      required String keyChartCircle,
      required String keyCircleColor,
      required String keyChartCircleCount}) async {
    // await addWeatherColor(mapController: mapController, sourceId: sourceId, keyLayer: keyCircleColor);
    await addWeatherCircle(mapController: mapController, sourceId: sourceId, keyLayer: keyChartCircle, keyImage: keyChartCircle);
    await addImageWeather(mapController: mapController, sourceId: sourceId, keyLayer: keyChartImage);
    // await addWeatherCount(mapController: mapController, sourceId: sourceId, keyLayer: keyChartCircleCount);
  }

  Future<void> addClusteredModelLayers(
      {required TrackasiaMapController? mapController,
      required MapModelEnum model,
      required String sourceId,
      required String keyImage,
      required String keyText,
      required String keyCircle,
      required String keyCircleCount,
      required String image}) async {
    // await addModelCircle(mapController: mapController, model: model, sourceId: sourceId, keyLayer: keyCircle, keyImage: keyCircle);
    await addImageModel(mapController: mapController, sourceId: sourceId, keyLayer: keyImage, image: image);
    await addModelCount(mapController: mapController, sourceId: sourceId, keyLayer: keyCircleCount);
  }

  //================MAP CHART LAYER==============//

  //================MAP CHART ADD==============//
  Future<void> addImageCircleRate({required TrackasiaMapController? mapController, required String keyLayer}) async {
    final svgBytes = await TrackasiaUtils.createDonutChartPng(TrackasiaUtils.segments, width: 100, height: 100);
    if (svgBytes != null) {
      await removeLayer(mapController: mapController, keyLayer: keyLayer);
      await mapController?.addImage(keyLayer, svgBytes);
    }
  }

  Future<void> addImageWeather({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    logDebug("===ADD LAYER ===>$keyLayer");
    await mapController!.addLayer(
        sourceId,
        keyLayer,
        SymbolLayerProperties(
          iconImage: ['get', 'icon'],
          // textField: ['get', 'description'],
          iconSize: Platform.isIOS ? 0.8 : 0.4,
          iconAllowOverlap: true,
          // textColor: '#ff9900',
          // textSize: 8,
          // textHaloColor: '#0066ff',
          // textAnchor: 'bottom',
          // textHaloWidth: 12.0,
          // textPadding: 32,
          // textAllowOverlap: true,
          // textIgnorePlacement: true,
          // textHaloBlur: 1.0
        ));
  }

  Future<void> addImageModel({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer, required String image}) async {
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    logDebug("===ADD LAYER ===>$keyLayer");
    await mapController?.addLayer(
        sourceId,
        keyLayer,
        SymbolLayerProperties(
          iconImage: image,
          iconSize: Platform.isIOS ? 1.6 : 0.9,
          iconAllowOverlap: true,
          // textField: ['get', 'name'],
          // textColor: '#ffffff',
          // textSize: 7,
          // textHaloColor: '#0066ff',
          // textAnchor: 'bottom',
          // textHaloWidth: 12.0,
          // textPadding: 32,
          // textAllowOverlap: true,
          // textIgnorePlacement: true,
          // textHaloBlur: 1.0
        ));
  }

  Future<void> addTextModel({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    logDebug("===ADD LAYER ===>$keyLayer");
    await mapController?.addLayer(sourceId, keyLayer, const SymbolLayerProperties());
  }

  Future<void> addChartCircleRate({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer, required String keyImage}) async {
    const pointKey = "point_count";
    await removeLayer(mapController: mapController, keyLayer: keyLayer).then((value) async {
      await mapController?.addSymbolLayer(
          sourceId,
          keyLayer,
          SymbolLayerProperties(
            textHaloWidth: 1,
            textSize: 6,
            iconImage: keyImage,
            iconSize: [
              Expressions.step,
              [Expressions.get, pointKey],
              50,
              0.9,
              200,
              1.1,
              400,
              1.2,
              800,
              1.3,
              1000,
              1.4
            ],
            iconAllowOverlap: true,
          ),
          filter: [Expressions.has, pointKey]);
    });
  }

  Future<void> addPetCircleRate({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer, required String keyImage}) async {
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addSymbolLayer(
        sourceId,
        keyLayer,
        SymbolLayerProperties(
          textHaloWidth: 1,
          textSize: 6,
          iconImage: keyImage,
          iconSize: [
            'step',
            ['zoom'],
            1, // Zoom level 0: Size 1
            0.9, // Zoom level 1: Size 0.9
            200, // Zoom level 2: Size 200
            1.1, // Zoom level 3: Size 1.1
            400, // Zoom level 4: Size 400
            1.2, // Zoom level 5: Size 1.2
            800, // Zoom level 6: Size 800
            1.3, // Zoom level 7: Size 1.3
            1000, // Zoom level 8: Size 1000
            1.4 // Zoom level 9 and above: Size 1.4
          ],
          iconAllowOverlap: true,
        ),
        filter: [Expressions.has, "point_count"]);
  }

  Future<void> addWeatherCircle({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer, required String keyImage}) async {
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    logDebug("===ADD LAYER ===>$keyLayer");
    await mapController!.addLayer(
        sourceId,
        keyLayer,
        SymbolLayerProperties(
          iconImage: [
            'step',
            ['get', 'point_count'],
            '01dd',
            1000,
            '01dd',
            5000,
            '01dd',
          ],
          iconSize: Platform.isIOS ? 0.6 : 0.32,
          iconAllowOverlap: true,
        ),
        filter: [Expressions.has, "point_count"]);
  }

  Future<void> addModelCircle({required TrackasiaMapController? mapController, required MapModelEnum model, required String sourceId, required String keyLayer, required String keyImage}) async {
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController!.addLayer(
        sourceId,
        keyLayer,
        SymbolLayerProperties(
          iconImage: [
            'step',
            ['get', 'point_count'],
            model == MapModelEnum.demonstration
                ? 'ic_map_model_marker_store_demo'
                : model == MapModelEnum.store
                    ? 'ic_map_model_marker_store'
                    : 'ic_map_model_marker_storage',
            10,
            model == MapModelEnum.demonstration
                ? 'ic_map_model_marker_store_demo'
                : model == MapModelEnum.store
                    ? 'ic_map_store_medium'
                    : 'ic_map_storage_medium',
            100,
            model == MapModelEnum.demonstration
                ? 'ic_map_model_marker_store_demo'
                : model == MapModelEnum.store
                    ? 'ic_map_store_large'
                    : 'ic_map_storage_large',
          ],
          iconSize: Platform.isIOS ? 1.2 : 0.8,
          iconAllowOverlap: true,
        ),
        filter: [Expressions.has, "point_count"]);
  }

  Future<void> addChangeChartCircleRate({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer, required String keyImage, required String suggest}) async {
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addSymbolLayer(
        sourceId,
        keyLayer,
        SymbolLayerProperties(
          iconImage: keyImage,
          iconAllowOverlap: true,
        ),
        filter: [
          '==',
          ['get', 'suggest'],
          suggest,
        ]);
  }

  Future<void> addCircleCount({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointKey = "point_count";
    const pointAbbreviated = "point_count_abbreviated";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addSymbolLayer(sourceId, keyLayer, const SymbolLayerProperties(textField: [Expressions.get, pointAbbreviated], textSize: 12), filter: [Expressions.has, pointKey]);
  }

  Future<void> addWeatherCount({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointAbbreviated = "point_count_abbreviated";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addLayer(
        sourceId,
        keyLayer,
        const SymbolLayerProperties(
            textField: [Expressions.get, pointAbbreviated],
            textSize: 12.0,
            textColor: '#000000',
            // textHaloColor: '#00FF00',
            textHaloWidth: 10.0,
            textPadding: 2.0,
            textHaloBlur: 1.0,
            textAllowOverlap: true,
            textIgnorePlacement: true));
  }

  Future<void> addModelCount({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointAbbreviated = "point_count_abbreviated";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    logDebug("===ADD LAYER ===>$keyLayer");
    await mapController?.addLayer(
        sourceId,
        keyLayer,
        const SymbolLayerProperties(
            textField: [Expressions.get, pointAbbreviated],
            textSize: 12.0,
            textColor: '#000000',
            textHaloColor: '#00FF00',
            textHaloWidth: 10.0,
            textPadding: 2.0,
            textHaloBlur: 1.0,
            textAllowOverlap: true,
            textIgnorePlacement: true));
  }

  Future<void> addChartChildren({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointKey = "point_count";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addCircleLayer(
        sourceId,
        keyLayer,
        const CircleLayerProperties(circleColor: [
          'case',
          ['has', 'mag'],
          ['get', 'mag'],
          '#00CC33'
        ], circleRadius: 10),
        filter: [
          "!",
          [Expressions.has, pointKey]
        ]);
  }

  Future<void> addPetCircleColor({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointKey = "point_count";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addCircleLayer(
        sourceId,
        keyLayer,
        const CircleLayerProperties(circleStrokeColor: [
          'case',
          ['has', 'mag'],
          ['get', 'mag'],
          '#00CC33'
        ], circleColor: 'rgba(0, 0, 0, 0)', circleStrokeWidth: 2, circleRadius: 16),
        filter: [
          "!",
          [Expressions.has, pointKey]
        ]);
  }

  Future<void> addWeatherColor({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointKey = "point_count";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addCircleLayer(
        sourceId,
        keyLayer,
        const CircleLayerProperties(
          circleStrokeColor: 'rgba(255, 165, 0, 0.5)',
          circleColor: 'rgba(0, 0, 0, 0)',
          circleStrokeWidth: 2,
          circleRadius: 17,
        ),
        filter: [
          "!",
          [Expressions.has, pointKey]
        ]);
  }

  Future<void> addPetColor({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointKey = "point_count";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addCircleLayer(
      sourceId,
      keyLayer,
      const CircleLayerProperties(
        circleStrokeColor: 'rgba(255, 165, 0, 0.5)',
        circleColor: 'rgba(0, 0, 0, 0)',
        circleStrokeWidth: 2,
        circleRadius: 17,
      ),
      // filter: [
      //   "!",
      //   [Expressions.has, pointKey]
      // ]
    );
  }

  Future<void> addIconPetChildren({required TrackasiaMapController? mapController, required String sourceId, required String keyLayer}) async {
    const pointKey = "point_count";
    await removeLayer(mapController: mapController, keyLayer: keyLayer);
    await mapController?.addLayer(
        sourceId,
        keyLayer,
        // const CircleLayerProperties(circleColor: [
        //   'case',
        //   ['has', 'mag'],
        //   ['get', 'mag'],
        //   '#00CC33'
        // ], circleRadius: 10, circleStrokeWidth: 1, circleStrokeColor: "#FFA500"),
        SymbolLayerProperties(
          iconImage: ['get', 'category_id'],
          iconSize: Platform.isIOS ? 0.8 : 0.5,
          iconAllowOverlap: true,
        ),
        filter: [
          "!",
          [Expressions.has, pointKey]
        ]);
  }

  static Future<void> removeSource({required TrackasiaMapController? mapController, required String sourceId}) async {
    final sourceIds = await mapController?.getSourceIds();
    if (sourceIds?.contains(sourceId) == true) {
      await mapController?.removeSource(sourceId);
      logDebug("===REMOVE SOURCE ID===>$sourceId");
    }
  }

  static Future<void> removeLayer({required TrackasiaMapController? mapController, required String keyLayer, List<dynamic>? layerIds}) async {
    List<dynamic>? _layerIds = layerIds;
    _layerIds ??= await mapController?.getLayerIds();
    if (_layerIds?.contains(keyLayer) == true) {
      await mapController?.removeLayer(keyLayer);
      logDebug("===REMOVE LAYER ID===>$keyLayer");
    }
  }

  Future<void> addChangeChartCircleData({required TrackasiaMapController? mapController, required String sourceId, required List<dynamic> dataMap}) async {
    if (dataMap.isNotEmpty == true) {
      for (Map<String, dynamic> feature in dataMap) {
        var rnd = Random();
        String id = feature['properties']['id'] ?? rnd.nextInt(1000);
        String keyLayer = createKeyLayer(id);
      }
    }
  }

  String createKeyLayer(String id) => 'pet_chart_keylayer_circle_rate$id';

  String createImageId(String suggest) => 'pet_chart_image_circle_rate$suggest';

  //================MAP CHART ADD==============//

  static void addSourceNutritionMap(TrackasiaMapController? mapController, String sourceIdNutritionMap, Map<String, dynamic> data) async {
    mapController?.getSourceIds().then((value) {
      logDebug("===ADD SOURCE ID===>$sourceIdNutritionMap");
      return value.contains(sourceIdNutritionMap) ? mapController.setGeoJsonSource(sourceIdNutritionMap, data) : mapController.addGeoJsonSource(sourceIdNutritionMap, data);
    });
    _addLayers(mapController, sourceIdNutritionMap);
  }

  static void removeSourceNutritionMap(TrackasiaMapController? mapController, String sourceId) {
    removeSource(mapController: mapController, sourceId: sourceId);
    mapController?.getLayerIds().then((value) {
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "n-layer");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "p-layer");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "k-layer");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "ph-layer");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "ec-layer");
    });
  }

  static void removeSourcePetMap(TrackasiaMapController? mapController, String sourceId, String layerId) {
    removeSource(mapController: mapController, sourceId: sourceId);
    mapController?.getLayerIds().then((value) {
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_chart_image_circle_rate");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_chart_circle_rate");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_chart_circle_children");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_pet_circle_children");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_chart_circle_count");
    });
  }

  static void removeSourceWeatherMap(TrackasiaMapController? mapController, String sourceId, String layerId) {
    removeSource(mapController: mapController, sourceId: sourceId);
    mapController?.getLayerIds().then((value) {
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_image");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_circle");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_circle_count");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_circle_color");
    });
  }

  static void removeSourceModelMap(TrackasiaMapController? mapController, String sourceId, String layerId) {
    removeSource(mapController: mapController, sourceId: sourceId);
    mapController?.getLayerIds().then((value) {
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_image");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_circle");
      removeLayer(layerIds: value, mapController: mapController, keyLayer: "${layerId}_circle_count");
    });
  }

  static Future<void> _addLayers(TrackasiaMapController? mapController, String sourceId) async {
    await _addLayer(
      mapController: mapController,
      sourceId: sourceId,
      layerId: 'n-layer',
      filter: [
        '==',
        ['get', 'layer'],
        'n'
      ],
      fillColor: [
        "match",
        ["get", "n"],
        ["0,091-0,18", "0.091-0.18"],
        "#59D400",
        ["0,181-0,27", "0.181-0.27"],
        "#6AFF00",
        ["0,271-0,36", "0.271-0.36"],
        "#00FF00",
        ["0,361-0,45", "0.361-0.45"],
        "#FF00FF",
        ["> 0,45"],
        "#FEF6CE",
        "transparent"
      ],
    );
    await _addLayer(mapController: mapController, sourceId: sourceId, layerId: 'p-layer', filter: [
      '==',
      ['get', 'layer'],
      'p'
    ], fillColor: [
      "match",
      ["get", "p"],
      ["3,76-7,5", "< 5.25"],
      "#59D400",
      ["7,6-11,25", "5.25-10.5"],
      "#6AFF00",
      ["11,26-15,0", "10.51-15.7"],
      "#00FF00",
      ["15,1-18,75", "15.76-21"],
      "#F0A0E2",
      ["> 18,75", "21.1-26.25"],
      "#FF00FF",
      ["> 26.25"],
      "#FEF6CE",
      "transparent"
    ]);
    await _addLayer(mapController: mapController, sourceId: sourceId, layerId: 'k-layer', filter: [
      '==',
      ['get', 'layer'],
      'k'
    ], fillColor: [
      "match",
      ["get", "k"],
      ["0,076-0,15", "0.091-0.18"],
      "#59D400",
      ["0,151-0,225", "0.181-0.27"],
      "#6AFF00",
      ["0,226-0,3", "0.271-0.36"],
      "#00FF00",
      ["0,31-0,375", "0.361-0.45"],
      "#FF00FF",
      ["> 0,375", "> 0.45"],
      "#FEF6CE",
      "transparent"
    ]);
    await _addLayer(mapController: mapController, sourceId: sourceId, layerId: 'ph-layer', filter: [
      '==',
      ['get', 'layer'],
      'ph'
    ], fillColor: [
      "case",
      [
        "==",
        ["get", "ph"],
        "< 5,0"
      ],
      "#FFFCA8",
      [
        "==",
        ["get", "ph"],
        "5,0-6,0"
      ],
      "#fec300",
      [
        "==",
        ["get", "ph"],
        "6-7,5"
      ],
      "#d4a200",
      "transparent"
    ]);

    await _addLayer(mapController: mapController, sourceId: sourceId, layerId: 'ec-layer', filter: [
      '==',
      ['get', 'layer'],
      'ec'
    ], fillColor: [
      "case",
      [
        "==",
        ["get", "ec"],
        "< 0.8"
      ],
      "#b0fdff",
      [
        "==",
        ["get", "ec"],
        "0,8-1,6"
      ],
      "#3096f8",
      [
        "==",
        ["get", "ec"],
        "> 1.6"
      ],
      "#043e76",
      "transparent"
    ]);
  }

  static Future<void> _addLayer(
      {required TrackasiaMapController? mapController, required String sourceId, required String layerId, required List<dynamic> filter, required List<dynamic> fillColor}) async {
    mapController?.getLayerIds().then((value) async {
      if (!value.contains(layerId)) {
        logDebug("===ADD LAYER ===>$layerId");
        await mapController.addLayer(sourceId, layerId, FillLayerProperties(fillColor: fillColor, fillOpacity: 0.6), filter: filter, belowLayerId: 'waterway');
      }
    });
  }
}
