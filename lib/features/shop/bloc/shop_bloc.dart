import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/base_response.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/features/home/home_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/album_bloc.dart';
import '../shop_repository.dart';
import 'shop_event.dart';
import 'shop_state.dart';

export 'shop_event.dart';
export 'shop_state.dart';

class ShopBloc extends BaseBloc {
  final repository = ShopRepository();

  ShopBloc(ShopState init):super(init:init) {
    on<GetFollowShopEvent>((event, emit) async {
      final response = await repository.getUserFollow(event.type, event.id.toString());
      emit(GetFollowShopState(response));
    });
    on<FollowShopEvent>((event, emit) async {
      final response = await repository.setFollow(event.type, event.id.toString());
      emit(FollowShopState(response));
    });
    on<UnFollowShopEvent>((event, emit) async {
      final response = await repository.setUnFollow(event.type, event.id.toString());
      emit(UnFollowShopState(response));
    });
    on<LoadShopEvent>((event, emit) async {
      final shop = await Util.getShop();
      emit(LoadShopState(shop));
    });
    on<ExpandShopEvent>((event, emit) => emit(ExpandShopState(event.highlight, event.other)));
    on<ChangeTabShopEvent>((event, emit) => emit(ChangeTabShopState(event.index, event.status)));
    on<LoadHighlightProductsShopEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await repository.loadHighlightProducts(event.shopId.toString(), event.page.toString());
      emit(LoadHighlightProductsShopState(response));
    });
    on<LoadOtherProductsShopEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await repository.loadOtherProducts(event.shopId, event.page.toString(), event.businessId);
      emit(LoadOtherProductsShopState(response));
    });
    on<LoadAlbumUserEvent>((event, emit) async {
      //emit(ShopState(isShowLoading: true));
      final response = await repository.loadAlbumUser(event.user_id,event.page.toString());
      emit(LoadAlbumUserState(response));
    });
    on<LoadListImageAlbumEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await repository.loadListImageAlbum(event.album_id,event.page.toString());
      emit(LoadListImageAlbumState(response));
    });
    on<CreateNewAlbumEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await ApiClient().postAPI('${Constants().apiVersion}user_albums', 'POST', BaseResponse(),
          body: {'name': event.name});
      emit(CreateNewAlbumState(response));
    });
    on<DeleteProductShopEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await repository.deleteProduct(event.productId.toString());
      emit(DeleteProductShopState(response));
    });
    on<PinProductShopEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await repository.pinProduct(event.productId.toString());
      emit(PinProductShopState(response));
    });
    on<UploadBackgroundImageShopEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await repository.uploadBackgroundImage(event.path);
      emit(UploadBackgroundImageShopState(response));
    });
    on<DeleteBackgroundImageShopEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await repository.deleteBackgroundImage();
      emit(DeleteBackgroundImageShopState(response));
    });
    on<ReloadBackgroundImageShopEvent>((event, emit) => emit(ReloadBackgroundImageShopState()));
    on<GetPointEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      int point = prefs.getInt('points')??0;
      final response = await repository.getPoint();
      if (response.checkOK()) {
        prefs.setString('member_rate', response.data.member_rate);
        prefs.setString('user_level', response.data.user_level);
        point = response.data.points;
        prefs.setInt('points', point);
      }
      emit(GetPointState(point));
    });
    on<TransferPointShopEvent>((event, emit) async {
      emit(ShopState(isShowLoading: true));
      final response = await HomeRepository().transferPoint(event.point, event.phone, isUser: false);
      emit(TransferPointShopState(response));
      if (response.checkOK(passString: true)) {
        SharedPreferences.getInstance().then((prefs) {
          int point = prefs.getInt('points') ?? 0;
          point -= int.parse(event.point.toString());
          prefs.setInt('points', point);
        });
      }
    });
    on<GetFriendStatusEvent>((event, emit) async {
      final response = await repository.getFriendStatus(event.userId);
      if (response.checkOK()) {
        emit(GetFriendStatusState(response.data.friend_status));
      }
    });
    on<PostAddFriendStatusEvent>((event, emit) async {
      final response = await repository.postAddFriend(event.phone);
      if (response.success) {
        emit(AddFriendState());
      }
    });
    on<PostUnFriendStatusEvent>((event, emit) async {
      final response = await repository.postUnFriend(event.friendId);
      if (response.success) {
        emit(UnFriendState());
      }
    });
    on<LoadStatusMemberPackageEvent>((event, emit) async {
      dynamic data = await ApiClient().getData('base/option?key=membership_package');
      if (data != null && (data[0]['value']??'false') == 'true') emit(LoadStatusMemberPackageState(true));
    });
  }
}