import 'package:hainong/common/base_repository.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/features/comment/model/comment_model.dart';

class RatingRepository extends BaseRepository {
  Future<BaseResponse> postRating(int point, String content, String type, String id, int commentId)
    => commentId == -1 ?
      apiClient.postAPI('${Constants().apiVersion}comments', 'POST', CommentModel(), body: {
        'content': content, 'rate': point.toString(),
        'commentable_type': type, 'commentable_id': id
      }) : apiClient.postAPI('${Constants().apiVersion}comments/$commentId', 'PUT', CommentModel(), body: {
        'content': content, 'rate': point.toString()
      });

  Future<BaseResponse> likeComment(String id, String type) => apiClient.postAPI('${Constants().apiVersion}'
      'account/like_item', 'POST', BaseResponse(), body: {'classable_id': id, 'classable_type': type});

  Future<BaseResponse> unlikeComment(String id, String type) => apiClient.postAPI('${Constants().apiVersion}'
      'account/unlike', 'POST', BaseResponse(), body: {'classable_id': id, 'classable_type': type});

  Future<BaseResponse> answerComment(String id, String content, int? replierId, int? parentId) => apiClient.postAPI('${Constants().apiVersion}'
      'comments/$id/create_answer', 'POST', CommentModel(preFix: 'sub_'), body: {'content': content,
      if (replierId != null && replierId > 0) 'replier_id': replierId.toString(),
      if (parentId != null && parentId > 0) 'parent_id': parentId.toString(),
    });

  Future<BaseResponse> reportComment(String id, String type, String reason) => apiClient.postAPI('${Constants().apiVersion}'
      'comments/warning_comment', 'POST', BaseResponse(), body: {'classable_id': id, 'classable_type': type, 'reason': reason});

  Future<BaseResponse> deleteComment(int id, bool owner, bool isComment) {
    String path = '${owner ? Constants().apiVersion : Constants().apiPerVer}comments/$id';
    if (!isComment) path = '${owner ? Constants().apiVersion : Constants().apiPerVer}comments/destroy_answer/$id';
    return apiClient.postAPI(path, 'DELETE', BaseResponse());
  }

  Future<BaseResponse> getComment(int id) => apiClient.getAPI('${Constants().apiVersion}comments/$id', CommentModel());

  Future<BaseResponse> loadAnswers(String id, int page, {limit}) {
    limit ??= Constants().limitPage;
    return apiClient.getAPI('${Constants().apiVersion}comments/$id/answers?page=$page&limit=$limit', CommentsModel());
  }

  Future<BaseResponse> editComment(int id, String content, bool owner, bool isComment) {
    String path = '${owner ? Constants().apiVersion : Constants().apiPerVer}comments/$id';
    if (!isComment) path = '${owner ? Constants().apiVersion : Constants().apiPerVer}comments/update_answer/$id';
    return apiClient.postAPI(path, 'PUT', BaseResponse(), body: {'content': content});
  }
}
