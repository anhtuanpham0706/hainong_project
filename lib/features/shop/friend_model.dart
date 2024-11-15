import 'package:hainong/common/util/util.dart';

class FriendModel {
  int id, friend_id, user_id;
  String friend_status;

  FriendModel(
      {this.id = -1,
      this.friend_id = -1,
      this.user_id = -1,
      this.friend_status = "none"});
  FriendModel fromJson(Map<String, dynamic> json) {
    id = Util.getValueFromJson(json, 'id', -1);
    friend_id = Util.getValueFromJson(json, 'friend_id', -1);
    user_id = Util.getValueFromJson(json, 'user_id', -1);
    friend_status = Util.getValueFromJson(json, 'friend_status', "none");
    return this;
  }
}
