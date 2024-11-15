import 'package:hainong/common/util/util.dart';
export 'package:hainong/features/function/module_model.dart';

class NotificationsModel {
  final List<NotificationModel> list = [];

  NotificationsModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(NotificationModel().fromJson(ele)));
    return this;
  }
}

class NotificationModel {
  int id, notificationable_id, source_id = -1, connectable_id = -1;
  String title, content, status, created_at, notification_type, notificationable_type, sender_image, sending_group, source_type;

  NotificationModel({this.id = -1, this.title = '', this.content = '', this.status = 'unseen',
    this.created_at = '', this.notification_type = 'system', this.sending_group = '',
    this.sender_image = '', this.notificationable_id = -1, this.notificationable_type = '', this.source_id = -1, this.source_type = ''});

  NotificationModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    notificationable_id = Util.getValueFromJson(json, 'notificationable_id', -1);
    title = Util.getValueFromJson(json, 'title', '');
    connectable_id = Util.getValueFromJson(json, 'connectable_id', -1);
    source_id = Util.getValueFromJson(json, 'source_id', -1);
    source_type = Util.getValueFromJson(json, 'source_type', '');
    content = Util.getValueFromJson(json, 'content', '');
    status = Util.getValueFromJson(json, 'status', 'unseen');
    created_at = Util.getValueFromJson(json, 'created_at', '');
    notification_type = Util.getValueFromJson(json, 'notification_type', 'system').toLowerCase();
    if (notification_type == 'market_place') notification_type = 'market_price';
    if (notification_type == 'follow') notification_type = 'follower';
    notificationable_type = Util.getValueFromJson(json, 'notificationable_type', '').toLowerCase();
    if (notification_type == 'like' && notificationable_type == 'image') notification_type = 'like_image';
    sender_image = Util.getValueFromJson(json, 'sender_image', '');
    sending_group = Util.getValueFromJson(json, 'sending_group', '').toLowerCase();
    return this;
  }
}
