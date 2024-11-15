class Constants {
  static Constants? _instance;
  Constants._();
  factory Constants() {
    _instance??=Constants._();
    return _instance!;
  }

  final String jvWebView = '''
    var span = document.body.getElementsByTagName("span");
    var i = 0;
    while (i < span.length) {
      span[i].style.fontSize = "22px";
      span[i].style.fontFamily = 'Tahoma, Geneva, sans-serif';
      i++;
    }
    var figure = document.body.getElementsByTagName("figure");
    i = 0;
    while (i < figure.length) {
      var img = figure[i].firstChild;
      img.style.maxWidth = "100%";
      img.style.width = "100%";
      var parent = figure[i].parentNode;
      parent.replaceChild(img, figure[i]);
      i++;
    }
    var img = document.body.getElementsByTagName("img");
    i = 0;
    while (i < img.length) {
      img[i].style.maxWidth = "100%";
      img[i].style.width = "100%";
      i++;
    }
    var iframe = document.body.getElementsByTagName("iframe");
    i = 0;
    while (i < iframe.length) {
      iframe[i].style.maxWidth = "100%";
      iframe[i].style.width = "100%";
      i++;
    }
    var video = document.body.getElementsByTagName("video");
    i = 0;
    while (i < video.length) {
      video[i].style.maxWidth = "100%";
      video[i].style.maxHeight = "100%";
      video[i].style.width = "device-width";
      video[i].style.height = "auto";
      i++;
    }
    var table = document.body.getElementsByTagName("table");
    i = 0;
    while (i < table.length) {
      table[i].style.borderCollapse = "collapse";
      table[i].style.display = "block";
      table[i].style.overflowX = "scroll";
      table[i].style.whiteSpace = "nowrap";
      i++;
    }
    var td = document.body.getElementsByTagName("td");
    i = 0;
    while (i < td.length) {
      td[i].style.border = "1px solid #ddd";
      i++;
    }   
    var p = document.body.getElementsByTagName("p");
    i = 0;
    while (i < p.length) {
      p[i].style.fontFamily = 'Tahoma, Geneva, sans-serif';
      i++;
    }    
  ''';

  final String assetsEyeOpen = 'assets/images/ic_eye_open.png';
  final String assetsEyeClose = 'assets/images/ic_eye_close.png';
  final String patternLinkHtml = r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.,&]+';

  final String loginKeyFinger = 'loginkey_finger';
  final String passwordFinger = 'password_finger';
  final String loginKey = 'loginkey';
  final String password = 'password';
  final String isRemember = 'remember';
  final String name = 'name';
  final String image = 'image';
  final String provinceName = 'province_name';
  final String memberRate = 'member_rate';
  final String hideToolbar = 'hidden_toolbar';
  final String autoPlayVideo = 'auto_play_video';

  final String shopId = 'shop_id';
  final String shopName = 'shop_name';
  final String shopEmail = 'shop_email';
  final String shopPhone = 'shop_phone';
  final String shopImage = 'shop_image';
  final String shopProvinceId = 'shop_province_id';
  final String shopProvinceName = 'shop_province_name';
  final String shopDistrictId = 'shop_district_id';
  final String shopDistrictName = 'shop_district_name';
  final String shopWebsite = 'shop_website';
  final String shopFacebook = 'shop_facebook';
  final String shopStar = 'shop_star';
  final String shopDescription = 'shop_des';
  final String shopHiddenPhone = 'shop_hidden_phone';
  final String shopHiddenEmail = 'shop_hidden_email';
  final String shopHideToolbar = 'shop_hidden_toolbar';

  final String dateMinDefault = '1900-01-01';
  final String datePattern = 'yyyy-MM-dd';
  final String datePatternVI = 'dd.MM.yyyy';
  final String localeVI = 'vi_VN';
  final String localeVILang = 'vi';
  final String localeEN = 'en_US';
  final String localeENLang = 'en';
  final String defaultCurrency = 'đ';
  final String apiVersion = '/api/v2/';
  final String apiPerVer = '/api/managers/v2/';
  final String apiConVer = '/api/contributors/v2/';
  String domain = 'https://hainong.vn';
  String baseUrl = 'https://admin.hainong.vn';
  String baseUrlImage = 'https://admin.hainong.vn';
  String baseUrlIPortal = 'https://agrid.vn';
  String mapUrl = 'https://gis-api.hainong.vn';

  String? permission;
  int? userId, indexPage;
  Map<String, dynamic>? contributeRole;
  bool isLogin = false;
  dynamic funChatBotLink, errorMsg;

  final int timeout = 900;
  final int limitPage = 10;
  final int limitLargePage = 50;
  final int passwordMaxLength = 6;
  final int otpMaxLength = 6;

  final styleMap = "https://maps.hainong.vn/styles/v1/streets.json?key=public_key";
}
