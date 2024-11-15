import 'package:hainong/common/util/util.dart';

class WeatherModel {
  WeatherModel({
    this.totalNextDate = -1,
  }) {
    currentDate = CurrentDate();
    nextDay = [];
  }

  int totalNextDate;
  late CurrentDate currentDate;
  late List<CurrentDate> nextDay;
  WeatherModel fromJson(Map<String, dynamic> json) {
    try {
      totalNextDate = Util.getValueFromJson(json, 'total_next_date', -1);
      if (Util.checkKeyFromJson(json, 'current_date')) {
        currentDate = CurrentDate().fromJson(json['current_date']);
      }
      if (Util.checkKeyFromJson(json,'next_day')) {
        // json['next_day'].entries.forEach((ele) {
        //   nextDay.add(CurrentDate().fromJson(ele));
        // });
        nextDay = List<CurrentDate>.from(json["next_day"].map((x) => CurrentDate().fromJson(x)));
      }
    } catch (_) {}
    return this;
  }
}

class CurrentDate {
  CurrentDate({
    this.id = -1,
    this.createdAt = '',
    this.updatedAt = '',
    this.deletedAt = '',
    this.temp = 0.0,
    this.feelsLike = 0.0,
    this.tempMin = 0.0,
    this.tempMax = 0.0,
    this.pressure = -1,
    this.grndLevel = -1,
    this.humidity = -1,
    this.weatherStatus = '',
    this.weatherStatusIcon = '',
    this.cloudsAll = -1,
    this.windSpeed = 0.0,
    this.windDeg = -1,
    this.windGust = 0.0,
    this.visibility = -1,
    this.pop = 0.0,
    this.pod = '',
    this.dtTxt = '',
    this.weatherDetailsPlaceId = -1,
    this.cityid = -1,
    this.weekName = '',
    this.provinceName = '',
    this.name = '',
    this.sunrise = '',
    this.sunset = '',
    this.district_name = '',
    this.location_fullname = '',
    this.location_name = '',
    this.audio_link = '',
    this.status_color = 0xFFFFFFFF,
    this.uv = 0.0,
    this.percent_rain = 0.0
  }){
    currentWeatherGroup = [];
  }

  int id;
  String audio_link;
  String createdAt;
  String updatedAt;
  String deletedAt;
  double temp;
  double feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int grndLevel;
  int humidity;
  String weatherStatus;
  String weatherStatusIcon;
  int cloudsAll;
  double windSpeed;
  int windDeg;
  double windGust;
  int visibility;
  String name,location_name,location_fullname;
  String district_name;

  String sunrise;
  String sunset;
  double pop;
  String pod;
  String dtTxt;
  int weatherDetailsPlaceId;
  int cityid, status_color;
  late List<CurrentWeatherGroup> currentWeatherGroup;
  String weekName;
  String provinceName;
  double uv,percent_rain;


  CurrentDate fromJson(Map<String, dynamic> json) {
    try {
      id = Util.getValueFromJson(json, 'id', -1);
      createdAt = Util.getValueFromJson(json, 'created_at', '');
      updatedAt = Util.getValueFromJson(json, 'updated_at', '');
      deletedAt = Util.getValueFromJson(json, 'deleted_at', '');
      windSpeed = Util.getValueFromJson(json, 'wind_speed', 0.0);
      temp = Util.getValueFromJson(json, 'temp', 0.0);
      feelsLike = Util.getValueFromJson(json, 'feels_like', 0.0);
      tempMin = Util.getValueFromJson(json, 'temp_min', 0.0);
      tempMax = Util.getValueFromJson(json, 'temp_max', 0.0);
      pressure = Util.getValueFromJson(json, 'pressure', -1);
      humidity = Util.getValueFromJson(json, 'humidity', -1);
      visibility = Util.getValueFromJson(json, 'visibility', -1);
      windDeg = Util.getValueFromJson(json, 'wind_deg', -1);
      cloudsAll = Util.getValueFromJson(json, 'clouds_all', -1);
      name = Util.getValueFromJson(json, 'name', '');
      sunrise = Util.getValueFromJson(json, 'sunrise', '');
      sunset = Util.getValueFromJson(json, 'sunset', '');
      weatherStatus = Util.getValueFromJson(json, 'weather_status', '');
      weatherStatusIcon = Util.getValueFromJson(json, 'weather_status_icon', '');
      weatherDetailsPlaceId = Util.getValueFromJson(json, 'weather_details_place_id', -1);
      weekName = Util.getValueFromJson(json, 'week_name', '');
      provinceName = Util.getValueFromJson(json, 'province_name', '');
      location_name = Util.getValueFromJson(json, 'location_name', '');
      location_fullname = Util.getValueFromJson(json, 'location_full_name', '');
      district_name = Util.getValueFromJson(json, 'district_name', '');
      audio_link = Util.getValueFromJson(json, 'audio_link', '');
      uv = Util.getValueFromJson(json, 'uv', 0.0);
      percent_rain = Util.getValueFromJson(json, 'percent_rain', 0.0);
      String color = Util.getValueFromJson(json, 'status_color', 'FFFFFF');
      status_color = 0xFF000000 + (int.tryParse(color, radix: 16)??0xFFFFFFFF);
      if (Util.checkKeyFromJson(json, 'current_weather_group')) {
        json['current_weather_group'].forEach((ele) {
          currentWeatherGroup.add(CurrentWeatherGroup().fromJson(ele));
        });
      }
    } catch (_) {}
    return this;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "temp": temp,
    "feels_like": feelsLike,
    "temp_min": tempMin,
    "temp_max": tempMax,
    "pressure": pressure,
    "grnd_level": grndLevel,
    "humidity": humidity,
    "weather_status": weatherStatus,
    "weather_status_icon": weatherStatusIcon,
    "clouds_all": cloudsAll,
    "wind_speed": windSpeed,
    "wind_deg": windDeg,
    "wind_gust": windGust,
    "visibility": visibility,
    "pop": pop,
    "pod": pod,
    "dt_txt": dtTxt,
    "weather_details_place_id": weatherDetailsPlaceId,
    "cityid": cityid,
    "week_name": weekName,
    "province_name": provinceName,
  };
}
class CurrentWeatherGroup {
  CurrentWeatherGroup({
    this.label = '',
    this.hour = '',
    this.key = '',
    this.temp = 0.0,
    this.weatherStatus = '',
    this.weatherStatusIcon = '',
  });

  String label;
  String hour;
  String key;
  double temp;
  String weatherStatus;
  String weatherStatusIcon;

  CurrentWeatherGroup fromJson(Map<String, dynamic> json) {
    try {
      label = Util.getValueFromJson(json, 'label', '');
      hour = Util.getValueFromJson(json, 'hour', '');
      key = Util.getValueFromJson(json, 'key', '');
      temp = Util.getValueFromJson(json, 'temp', 0.0);
      weatherStatus = Util.getValueFromJson(json, 'weather_status', '');
      weatherStatusIcon = Util.getValueFromJson(json, 'weather_status_icon', '');
    } catch (_) {}
    return this;
  }

  Map<String, dynamic> toJson() => {
    "label": label,
    "hour": hour,
    "key": key,
    "temp": temp,
    "weather_status": weatherStatus,
    "weather_status_icon": weatherStatusIcon,
  };
}
