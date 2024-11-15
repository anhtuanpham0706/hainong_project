class MetaDataModel {
  String title;
  String description;
  String url;
  String domain;
  String image;
  String icon;

  MetaDataModel({this.title = '', this.description = '', this.url = '', this.domain = '', this.image = '', this.icon = ''});

  @override
  String toString() {
    return {
      'title':title,
      'description':description,
      'url':url,
      'image':image,
      'icon':icon
    }.toString();
  }
}