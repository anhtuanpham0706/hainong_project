import 'package:hainong/common/util/util.dart';
import 'user_model.dart';

class CommentsModel {
  final List<CommentModel> list = [];
  final String preFix;
  CommentsModel({this.preFix = ''});
  CommentsModel fromJson(data) {
    if (data.isNotEmpty) data.forEach((ele) => list.add(CommentModel(preFix: preFix).fromJson(ele)));
    return this;
  }
}

class CommentModel {
  bool user_liked, user_commented;
  int id, rate, total_likes, comment_id, total_answers;
  String content, created_at, preFix;
  String commentable_type;
  int commentable_id;
  String classable_type;
  String classable_id;
  String source_type;
  int source_id;
  CommentModel? answer;
  late UserModel user;
  late UserModel replier;

  CommentModel({
    this.id = -1,
    this.comment_id = -1,
    this.content = '',
    this.source_id = -1,
    this.source_type = '',
    this.created_at = '',
    this.preFix = '',
    this.rate = 0,
    this.total_likes = 0,
    this.total_answers = 0,
    this.commentable_type = '',
    this.commentable_id = 0,
    this.classable_type = '',
    this.classable_id = '',
    this.user_liked = false,
    this.user_commented = false
  }) {
    user = UserModel();
    replier = UserModel();
  }

  CommentModel fromJson(Map<String, dynamic> json) {
    try {
      id = Util.isNullFromJson(json, 'id') ? json['id'] : -1;
      comment_id = Util.isNullFromJson(json, 'comment_id') ? json['comment_id'] : -1;
      user_liked = Util.isNullFromJson(json, 'user_liked') ? json['user_liked'] : false;
      user_commented = Util.isNullFromJson(json, 'user_commented?') ? json['user_commented?'] : false;
      content = Util.isNullFromJson(json, 'content') ? json['content']:'';
      created_at = Util.isNullFromJson(json, 'created_at') ? json['created_at']:'';
      rate = Util.isNullFromJson(json, 'rate') ? json['rate'] : 0;
      total_likes = Util.isNullFromJson(json, 'total_likes') ? json['total_likes'] : 0;
      total_answers = Util.isNullFromJson(json, 'total_answers') ? json['total_answers'] : 0;
      commentable_type = Util.isNullFromJson(json, preFix+'commentable_type') ? json[preFix+'commentable_type']:'';
      commentable_id = Util.isNullFromJson(json, preFix+'commentable_id') ? json[preFix+'commentable_id'] : -1;
      classable_type = Util.isNullFromJson(json, 'classable_type') ? json['classable_type']:'';
      classable_id = Util.isNullFromJson(json, 'classable_id') ? json['classable_id'].toString() : '';
      if (Util.isNullFromJson(json, 'user')) user.fromJson(json['user']);
      if (Util.isNullFromJson(json, 'replier')) replier.fromJson(json['replier']);
      if (Util.isNullFromJson(json, 'answer')) {
        answer = CommentModel(preFix: 'sub_').fromJson(json['answer']);
      }
    } catch(e) {
      return CommentModel();
    }
    return this;
  }

  void copyAnswer(CommentModel value) {
    if (answer == null) {
      answer = value;
      return;
    }
    answer!.id = value.id;
    answer!.comment_id = value.comment_id;
    answer!.content = value.content;
    answer!.created_at = value.created_at;
    answer!.user_liked = value.user_liked;
    answer!.user_commented = value.user_commented;
    answer!.total_likes = value.total_likes;
    answer!.rate = value.rate;
    answer!.classable_id = value.classable_id;
    answer!.classable_type = value.classable_type;
    answer!.commentable_id = value.commentable_id;
    answer!.commentable_type = value.commentable_type;
    answer!.user.copy(value.user);
    answer!.replier.copy(value.replier);
  }

  void copy(CommentModel value) {
    id = value.id;
    comment_id = value.comment_id;
    content = value.content;
    created_at = value.created_at;
    user_liked = value.user_liked;
    user_commented = value.user_commented;
    total_likes = value.total_likes;
    total_answers = value.total_answers;
    rate = value.rate;
    classable_id = value.classable_id;
    classable_type = value.classable_type;
    commentable_id = value.commentable_id;
    commentable_type = value.commentable_type;
    user.copy(value.user);
    replier.copy(value.replier);
    answer = value.answer;
  }
}
