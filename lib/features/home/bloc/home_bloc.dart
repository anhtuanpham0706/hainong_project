import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/function/info_news/news/news_bloc.dart';
import 'package:hainong/features/post/model/post.dart';
import 'package:hainong/features/post/post_list_repository.dart';
import '../../function/tool/suggestion_map/suggest_model.dart';
import '../../shop/album_model.dart';
import '../home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:hainong/features/shop/bloc/shop_event.dart';
import 'package:hainong/features/shop/bloc/shop_state.dart';

export 'home_event.dart';
export 'home_state.dart';

class HomeBloc extends BaseBloc {
  final repository = HomeRepository();
  HomeBloc(HomeState init) : super(init: init) {
    on<ChangeIndexHomeEvent>((event, emit) => emit(ChangeIndexHomeState(event.index)));
    on<LoadCataloguesHomeEvent>((event, emit) async {
      final response = await repository.loadHomeCatalogues();
      if (response.isNotEmpty) emit(LoadCataloguesHomeState(response));
    });
    on<LoadPostsHomeEvent>((event, emit) async {
      if (event.showLoading) emit(HomeState(isShowLoading: true));
      final response = await repository.loadPosts(event.key, event.page,
          isMyPost: event.isMyPost, hashTag: event.hashTag, shopId: event.shopId);
      emit(LoadPostsHomeState(response));
    });
    on<LoadLikePostsHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.loadLikePosts(event.page);
      emit(LoadLikePostsHomeState(response));
    });
    on<ReloadLikePostsHomeEvent>((event, emit) => emit(ReloadLikePostsHomeState()));
    on<LoadHighlightPostsHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.loadHighlightPosts(event.page, limit: 5);
      emit(LoadHighlightPostsHomeState(response));
    });
    on<ReloadHighlightPostsHomeEvent>((event, emit) => emit(ReloadHighlightPostsHomeState()));
    on<ReloadPostsHomeEvent>((event, emit) => emit(ReloadPostsHomeState()));
    on<LoadCatalogueHomeEvent>((event, emit) async {
      final response = await repository.loadCatalogue();
      emit(LoadCatalogueHomeState(response));
    });
    on<LikePostHomeEvent>((event, emit) async {
      if (event.response != null) {
        emit(LikePostHomeState(event.response, event.index, event.classableId));
        return;
      }
      final response = await repository.likePost(event.classableId, event.classableType);
      emit(LikePostHomeState(response, event.index, event.classableId));
    });
    on<UnlikePostHomeEvent>((event, emit) async {
      if (event.response != null) {
        emit(UnlikePostHomeState(event.response, event.index, event.classableId));
        return;
      }
      final response = await repository.unlikePost(event.classableId, event.classableType);
      emit(UnlikePostHomeState(response, event.index, event.classableId));
    });
    on<DeletePostHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = event.permission.isEmpty ? await repository.deletePost(event.id) : await repository.deletePostPer(event.id);
      emit(DeletePostHomeState(response, event.index));
    });
    on<LoadPostHomeEvent>((event, emit) async {
      final response = await repository.loadPost(event.id);
      emit(LoadPostHomeState(response, event.index));
    });
    on<LoadImageDtlHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.loadImageDetail(event.id, event.postId);
      emit(LoadImageDtlHomeState(response));
    });
    on<ReloadPostHomeEvent>((event, emit) => emit(ReloadPostHomeState()));
    on<LoadSubPostHomeEvent>((event, emit) async {
      final response = await repository.loadPost(event.id);
      emit(LoadSubPostHomeState(response));
    });
    on<WarningPostHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.warningPost(event.id, event.reason, imageId: event.imageId);
      emit(WarningPostHomeState(response, event.index));
    });
    on<SharePostHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.sharePost(event.item, event.des, event.hashTags);
      emit(SharePostHomeState(response, event.index));
    });
    on<AddImageHomeEvent>((event, emit) => emit(AddImageHomeState()));
    on<AddHashTagHomeEvent>((event, emit) => emit(AddHashTagHomeState(filters: event.filters, key: event.key)));
    on<CreatePostHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.createPost(event.files, event.hashTags,
          event.title, event.description, event.id, realFiles: event.realFiles,
          permission: event.permission, idAlbum: event.idAlbum);
      emit(CreatePostHomeState(response, context: event.context));
    });
    on<ShowLoadingHomeEvent>((event, emit) => emit(HomeState(isShowLoading: event.isShow)));
    on<LoadShopHomeEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.loadShop(event.id);
      emit(LoadShopHomeState(event.context, response));
    });
    on<TransferPointEvent>((event, emit) async {
      emit(HomeState(isShowLoading: true));
      final response = await repository.transferPoint(event.point, event.userId);
      emit(TransferPointState(response));
      if (response.checkOK(passString: true)) {
        SharedPreferences.getInstance().then((prefs) {
          int point = prefs.getInt('points') ?? 0;
          point -= int.parse(event.point.toString());
          prefs.setInt('points', point);
        });
      }
    });
    on<FollowPostEvent>((event, emit) async{
      if (event.response != null) {
        emit(FollowPostState(event.response));
        return;
      }
      emit(HomeState(isShowLoading: true));
      final response = await PostListRepository().setFollowPost(event.classableType, event.classableId);
      emit(FollowPostState(response));
    });
    on<UnFollowPostEvent>((event, emit) async{
      if (event.response != null) {
        emit(UnFollowPostState(event.response));
        return;
      }
      emit(HomeState(isShowLoading: true));
      final response = await PostListRepository().unFollowPost(event.classableType, event.classableId);
      emit(UnFollowPostState(response));
    });
    on<CreatePostEvent>((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().postAPI(
          Constants().apiVersion + 'posts', 'POST', Post(),
          body: {
            "title": event.title, "post_type": 'public', "description": "", "hash_tag": "[]"
          });
      emit(CreatePostState(response));
    });
    on<LoadAlbumUserEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      int id = prefs.getInt('shop_id')??-1;
      if (id > 0) {
        int page = 1;
        final List<AlbumModel> list = [];
        while (page > 0) {
          dynamic resp = await ApiClient().getAPI(Constants().apiVersion + 'user_albums?shop_id=$id&page=$page&limit=50', AlbumsModel(), timeout: 10);
          if (resp.checkOK()) {
            final temp = resp.data.list;
            if (temp.isEmpty) page = 0;
            else {
              list.addAll(temp);
              temp.length == 50 ? page++ : page = 0;
            }
          } else page = 0;
        }
        emit(LoadAlbumUserState(BaseResponse(success: true, data: list)));
      }
    });
    on<CheckProcessPostAutoEvent>((event, emit) async{
      emit(const BaseState(isShowLoading: true));
      bool? status;
      final response  = await ApiClient().getAPI(Constants().apiVersion + 'base/option?key=process_post_auto', Options(), hasHeader: false);
      if (response.checkOK() && response.data.list.length > 0) status = response.data.list[0].value == 'true';
      emit(CheckProcessPostAutoState(isActive: status));
    });
  }
}
