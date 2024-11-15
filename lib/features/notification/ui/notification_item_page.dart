import 'notification_import.dart';

class NotificationItemPage extends StatefulWidget {
  final int shopId;
  final HomeBloc blocHome;
  final NotificationModel item;
  final Function openMainTab;
  final ModuleModel? module;
  const NotificationItemPage(this.item, this.shopId,
      this.blocHome, this.openMainTab, {Key? key, this.module}):super(key:key);
  @override
  _NotificationItemPageState createState() => _NotificationItemPageState();
}

class _NotificationItemPageState extends State<NotificationItemPage> {
  final NotificationBloc _bloc = NotificationBloc();
  final String typeSystem = 'system', statusUnseen = 'unseen';
  String asset = 'assets/images/v2/ic_avatar_drawer_v2.png';
  bool _lock = false;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    _setAsset();
    _bloc.stream.listen((state) {
      if (state is SeenNotificationState) {
        _handleResponse(state.response, _handleSeen, setLock: false);
      } else if (state is DeleteNotificationState) {
        _handleResponse(state.response, _handleDelete, setLock: false);
      } else if (state is LoadDetailState) {
        switch(state.type) {
          case 'post':
            _handleResponse(state.resp, () {
              if (state.ext == null) _gotoPostDetail(state.resp.data);
              else if (state.ext == 'comment_detail') {
                final itemPost = PostItemPage(state.resp.data, 0, widget.blocHome, widget.shopId.toString(),
                    isCollapse: false, key: Key(DateTime.now().toString()));
                UtilUI.goToNextPage(context, CommentPage(state.resp.data, post: itemPost, reloadItem: itemPost.commentCallback));
              }
            });
            break;
          case 'marketplace': _handleResponse(state.resp, () => _gotoMarketPrice(state.resp.data)); break;
          case 'shop': _handleResponse(state.resp, () => _gotoShop(state.resp.data)); break;
          case 'comment': _handleResponse(state.resp, () => _gotoComment(state.resp.data)); break;
          case 'image': _handleResponse(state.resp, () => _gotoImageDtl(state.resp.data, state.ext)); break;
          case 'invoiceuser': _handleResponse(state.resp, () => _gotoOrderDtl(state.resp.data)); break;
          case 'plot': _handleResponse(state.resp, () => _gotoPlotDtl(state.resp.data)); break;
          case 'material': _handleResponse(state.resp, () => _gotoMaterialDtl(state.resp.data)); break;
          case 'process_engineering_information': _handleResponse(state.resp, () => _gotoFarmDtl(state.resp.data)); break;
          case 'mission_detail': _handleResponse(state.resp, () => _gotoMissionDtl(state.resp.data)); break;
          case 'membership_packages': _handleResponse(state.resp, () => _gotoMemPackageDtl(state.resp.data)); break;
          case 'product_introduction': _handleResponse(state.resp, () => _gotoProductDtl(state.resp.data)); break;
          case 'contributionmission': _handleResponse(state.resp, () => _gotoExeContributionDtl(state.resp.data)); break;
          case 'new_coupon': _handleResponse(state.resp, () => _gotoCouponDtl(state.resp.data)); break;
          case 'training_data': _handleResponse(state.resp, () => _gotoPestContributionDtl(state.resp.data)); break;
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder(bloc: _bloc,
    buildWhen: (state1, state2) => state2 is SeenNotificationState || state2 is DeleteNotificationState,
    builder: (context, state) {
      if (widget.item.id == -1) return const SizedBox();
      return Container(decoration: ShadowDecoration(size: 40.sp, opacity: 0.15,
          bgColor: widget.item.status == statusUnseen ? Colors.white : Colors.grey.shade300),
        margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
        child: OutlinedButton(onPressed: _checkSeen,
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent), padding: EdgeInsets.all(40.sp)),
          child: Row(children: [
            Container(padding: EdgeInsets.all(10.sp), width: 200.sp, height: 200.sp,
              decoration: ShadowDecoration(size: 30.sp, opacity: 0.2, borderColor: Colors.grey, width: 0.1,
                bgColor: widget.item.status == statusUnseen ? Colors.white : Colors.black.withOpacity(0.1)),
              child: ClipRRect(borderRadius: BorderRadius.circular(20.sp),
                child: ImageNetworkAsset(asset: asset, path: _getPath(), error: 'assets/images/bg_splash.png', width: 190.sp, height: 190.sp))),
            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: EdgeInsets.only(bottom: 20.sp), child: Text(widget.item.title,
                  style: TextStyle(color: Colors.black, fontSize: 40.sp, fontWeight: FontWeight.bold))),
                if (_hasContent()) Container(padding: EdgeInsets.only(bottom: 20.sp),
                  child: Container(constraints: BoxConstraints(maxHeight: 0.28.sh),
                    child: StringHtml('<style>*{font-size: 12px}</style>' + widget.item.content, allowGotoShop: false, clearPage: false))),
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  _createIcon(),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: LabelCustom(widget.module!=null ? widget.module!.name : MultiLanguage.get(widget.item.notification_type == 'system' ? widget.item.sending_group : widget.item.notification_type),
                      color: StyleCustom.textColor2C, size: 35.sp)),
                  LabelCustom(Util.getTimeAgo(widget.item.created_at), color: StyleCustom.textColor6C, size: 20.sp, weight: FontWeight.normal)
                ])
              ]))),
            ButtonImageCircleWidget(60.sp, _delete, child: const Icon(Icons.clear, color: Colors.grey))
          ])));
    });

  Widget _createIcon() {
    Color? color;
    String type = widget.item.notification_type;
    if(type == 'like' || type == 'like_comment' || type == 'like_image') {
      color = Colors.blue;
      type = 'like';
    } else if(type == 'follower') color = Colors.pink;
    else if(type == 'user_share_point' || type == 'invoice_user') color = Colors.green;
    else if(type == 'comment' || type == 'sub_comment') {
      color = Colors.green;
      type = 'comment';
    } else if(type == 'training_data') {
      color = Colors.red;
      type = 'warning';
    } else if (type == 'contribution_missions' || type == 'warning_contribution_mission' || type == 'market_price' ||
      type == 'weather' || type == 'invite_friend' || type == 'plot' || type == 'material' || type == 'ads' ||
      type == 'notice_schedule' || type == 'birthday' || type == 'process_engineering_information' ||
      type == 'mission_detail' || type == 'store_gift' || type == 'invite_use_membership_package' ||
      type == 'membership_packages' || type == 'new_product_introduction' || type == 'new_coupon' ||
      type == 'referral_new_user' || type == 'referral_new_product_introduction' ||
      type == 'update_product_introduction' || type == 'expiry_advance_point_product' || type == 'info_disease' || type == 'training_contribution_data') {
      type = 'system';
    }
    return Image.asset('assets/images/ic_$type.png', color: color,
        width: 30.sp, height: 30.sp, errorBuilder: (context, obj, track) => Image.asset('assets/images/ic_warning.png', color: Colors.red,
        width: 30.sp, height: 30.sp));
  }

  String _getPath() {
    if (widget.item.sender_image.isNotEmpty) return widget.item.sender_image;
    if (widget.module != null) return widget.module!.icon;
    return '';
  }

  bool _hasContent() => widget.item.notification_type == typeSystem ||
      widget.item.notification_type == 'invoice_user' ||
      widget.item.notification_type == 'ads' ||
      widget.item.notification_type == 'notice_schedule' ||
      widget.item.notification_type == 'invite_use_membership_package' ||
      widget.item.notificationable_type == 'noticeschedule' ||
      widget.item.sending_group == 'market_price' ||
      widget.item.notification_type == 'new_product_introduction' ||
      widget.item.notification_type == 'referral_new_product_introduction' ||
      widget.item.notification_type == 'referral_new_user' ||
      widget.item.notification_type == 'update_product_introduction' ||
      widget.item.notification_type == 'expiry_advance_point_product' ||
      widget.item.notificationable_type == 'marketplace'||
      widget.item.notification_type == 'contribution_missions'||
      widget.item.notification_type == 'warning_contribution_mission'||
      widget.item.notification_type == 'training_data';/* ||
      widget.item.notification_type == 'training_contribution_data' ||
      widget.item.notification_type == 'info_disease';*/

  void _setAsset() {
    if (widget.item.notification_type == typeSystem || widget.item.sending_group.isNotEmpty) {
      asset = 'assets/images/ic_fun_${widget.item.sending_group}.png';
      if (widget.item.sending_group.isEmpty || widget.item.sending_group == 'farming_manager' ||
          widget.item.sending_group == 'chat_message' || widget.item.sending_group == 'short_video' ) {
        asset = 'assets/images/bg_splash.png';
      }
    } else if (widget.item.notification_type == 'ads' ||
        widget.item.notification_type == 'plot' ||
        widget.item.notification_type == 'material' ||
        widget.item.notification_type == 'process_engineering_information' ||
        widget.item.notification_type == 'mission_detail' ||
        widget.item.notification_type == 'market_price' ||
        widget.item.notification_type == 'notice_schedule' ||
        widget.item.notification_type == 'store_gift' ||
        widget.item.notification_type == 'membership_packages' ||
        widget.item.notification_type == 'contribution_missions' ||
        widget.item.notification_type == 'new_product_introduction' ||
        widget.item.notification_type == 'update_product_introduction' ||
        widget.item.notification_type == 'info_disease' ||
        widget.item.notification_type == 'training_contribution_data' ||
        widget.item.notification_type == 'referral_new_product_introduction') {
      asset = 'assets/images/bg_splash.png';
    }
  }

  void _checkSeen() async {
    if (widget.item.status == statusUnseen) _bloc.add(SeenNotificationEvent(widget.item.id));
    if (widget.item.sending_group == 'article' || widget.item.sending_group == 'news') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Article Notification item');
      UtilUI.goToNextPage(context, NewsListPage());
      return;
    }
    if (widget.item.sending_group == 'technical_process') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Technical Process item');
      UtilUI.goToNextPage(context, TechnicalProcessListPage());
      return;
    }
    if (widget.item.sending_group == 'market_price') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Market Price item');
      widget.openMainTab(3);
      return;
    }
    if (widget.item.sending_group == 'weather') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Weather item');
      UtilUI.goToNextPage(context, WeatherListPage());
      return;
    }
    if (widget.item.sending_group == 'npk') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch NPK item');
      UtilUI.goToNextPage(context, NpkModulePage(url: Constants().baseUrl,
          title: const Padding(padding: EdgeInsets.only(right: 48), child: TitleHelper('Phối trộn phân bón NPK',
              url: 'https://help.hainong.vn/muc/4'))));
      return;
    }
    if (widget.item.sending_group == 'pest_diagnosis' || widget.item.sending_group == 'traning_data') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Pest Diagnosis item');
      UtilUI.goToNextPage(context, DiagnosePestsPage());
      return;
    }
    if (widget.item.sending_group == 'expert') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Expert item');
      UtilUI.goToNextPage(context, ExpertPage(callBackContact: () {
        UtilUI.goToNextPage(context, const HandbookPage());
        Util.trackActivities('notification', path: 'Function Screen -> Open Hand Books Screen');
      }, callBackLogin: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }));
      return;
    }
    if (widget.item.sending_group == 'post') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Post Notification item');
      widget.openMainTab(2);
      return;
    }
    if (widget.item.sending_group == 'mission') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Mission item');
      UtilUI.goToNextPage(context, const MissionPage());
      return;
    }
    if (widget.item.sending_group == 'farming_manager') {
      await Util.getPermission();
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Farming Management Notification item');
      UtilUI.goToNextPage(context, const FarmManagePage());
      return;
    }
    if (widget.item.sending_group == 'chat_message') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch 2Nông Chat Notification item');
      UtilUI.goToNextPage(context, FriendListPage());
      return;
    }
    if (widget.item.sending_group == 'short_video') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Short Video Notification item');
      UtilUI.goToNextPage(context, VideoListPage());
      return;
    }
    if (widget.item.sending_group == 'video') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Video Notification item');
      UtilUI.goToNextPage(context, VideoListPage());
      return;
    }
    if (widget.item.sending_group == 'diagnostic_map') {
      //Util.trackActivities('notification', path: 'Notification Screen -> Touch Diagnostic Map Notification item');
      //UtilUI.goToNextPage(context, const MapPage());
      return;
    }
    if (widget.item.sending_group == 'traceability') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Traceability Notification item');
      UtilUI.goToNextPage(context, TraceabilityPage(url: Constants().baseUrl, isLogin: Constants().isLogin));
      return;
    }
    if (widget.item.sending_group == 'business_association') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Business Association Notification item');
      UtilUI.goToNextPage(context, BAListPage());
      return;
    }
    if (widget.item.sending_group == 'handbook_of_pest') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Handbook Pest Notification item');
      UtilUI.goToNextPage(context, PestsHandbookListPage(''));
      return;
    }
    if (widget.item.sending_group == 'online_counseling') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Online Counseling Notification item');
      _openVideoCall();
      return;
    }
    if (widget.item.sending_group == 'knowledge_handbook') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Knowledge Handbook Notification item');
      UtilUI.goToNextPage(context, const HandbookPage());
      return;
    }
    if (widget.item.sending_group == 'mini_game') {
      Util.trackActivities('notification', path: 'Game Screen -> Touch Game item');
      UtilUI.goToNextPage(context, GamePage());
      return;
    }
    if (widget.item.sending_group == 'shop_gitf') {
      Util.trackActivities('notification', path: 'Gift Screen -> Touch Gift Notification item');
      UtilUI.goToNextPage(context, GiftShopPage());
      return;
    }
    if (widget.item.sending_group == 'market' || widget.item.sending_group == 'product' ||
        widget.item.notification_type == 'product') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Market/Product Notification item');
      widget.openMainTab(4);
      return;
    }
    if (widget.item.notificationable_type == 'usersharepoint' && !_lock &&
        widget.item.notificationable_id != -1) {
      Util.trackActivities('notification', path: 'Point Screen -> Touch Point Notification item');
      UtilUI.goToNextPage(context, PointListPage());
      return;
    }
    if (widget.item.notification_type == 'warning_comment' && !_lock) {
      await Util.getPermission();
      if (Constants().permission != 'member') UtilUI.goToNextPage(context, AdminPage(Constants().permission == 'admin'));
      return;
    }
    if (widget.item.notificationable_type == 'noticeschedule' && !_lock) {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Weather item');
      UtilUI.goToNextPage(context, WeatherListPage());
      return;
    }
    if (widget.item.notification_type == 'ads') {
      Util.trackActivities('notification', path: 'Notification Screen -> Touch Ads Notification item');
      UtilUI.goToNextPage(context, NotificationDtlPage(widget.item.title, widget.item.content, widget.item.created_at));
      return;
    }
    if (widget.item.notification_type == 'store_gift') {
      Util.trackActivities('notification', path: 'Gift History Screen -> Touch Gift Notification item');
      UtilUI.goToNextPage(context, const GiftHistoryPage());
      return;
    }
    if (widget.item.notification_type == 'invite_friend') {
      Util.trackActivities('notification', path: 'Inviting Friend Screen -> Touch Inviting Friend Notification item');
      UtilUI.goToNextPage(context, FriendListPage());
      return;
    }
    if (widget.item.notification_type == 'referral_new_user') {
      Util.trackActivities('notification', path: 'Introduction History Screen -> Touch Introduction History Notification item');
      UtilUI.goToNextPage(context, IntroductionHistoryPage());
      return;
    }
    if (widget.item.notification_type == 'referral_new_product_introduction') {
      Util.trackActivities('notification', path: 'referrar new product Screen -> Touch referrar Notification item');
      UtilUI.goToNextPage(context, HistoryPointPage());
      return;
    }
    if (widget.item.notificationable_type == 'contributionmissionrewardbypoint') {
      Util.trackActivities('notification', path: 'Point Screen -> Touch Point Notification item');
      UtilUI.goToNextPage(context, PointListPage());
      return;
    }
    if (widget.item.notificationable_type == 'contributionmissionrewardbydataplan') {
      Util.trackActivities('notification', path: 'Gift History Screen -> Touch Gift Notification item');
      UtilUI.goToNextPage(context, const GiftHistoryPage());
      return;
    }

    if (_lock) return;
    _lock = true;

    if (widget.item.notificationable_type == 'post' && widget.item.notificationable_id != -1) {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'post'));
      return;
    }
    if (widget.item.notificationable_type == 'shop' &&
        widget.item.notificationable_id != -1 && widget.item.notificationable_id != widget.shopId) {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'shop'));
      return;
    }
    if ((widget.item.notificationable_type == 'comment' || widget.item.notificationable_type == 'subcomment') &&
        widget.item.notificationable_id != -1) {
      widget.item.source_type == 'Post' ?
        _bloc.add(LoadDetailEvent(widget.item.source_id, 'post', ext: 'comment_detail')) :
        _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'comment'));
      return;
    }
    if (widget.item.notificationable_type == 'marketplace' && widget.item.notificationable_id != -1) {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'marketplace'));
      return;
    }
    if (widget.item.notificationable_type == 'image') {
      _bloc.add(LoadDetailEvent(widget.item.source_id, 'image', ext: widget.item.notificationable_id.toString()));
      return;
    }
    if (widget.item.notificationable_type == 'invoiceuser') {
      _bloc.add(LoadDetailEvent(widget.item.source_id, 'invoiceuser'));
      return;
    }
    if (widget.item.notification_type == 'plot') {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'plot'));
      return;
    }
    if (widget.item.notification_type == 'material') {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'material'));
      return;
    }
    if (widget.item.notification_type == 'process_engineering_information') {
      _bloc.add(LoadDetailEvent(widget.item.source_id, 'process_engineering_information'));
      return;
    }
    if (widget.item.notification_type == 'mission_detail') {
      await Util.getPermission();
      _bloc.add(LoadDetailEvent(widget.item.connectable_id, 'mission_detail'));
      return;
    }
    if (widget.item.notification_type == 'invite_use_membership_package' || widget.item.notification_type == 'membership_packages') {
      _bloc.add(LoadDetailEvent(widget.item.notification_type == 'membership_packages' ?
        widget.item.source_id : widget.item.notificationable_id, 'membership_packages'));
      return;
    }
    if (widget.item.notification_type == 'new_product_introduction' || widget.item.notification_type == 'update_product_introduction') {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'product_introduction'));
      return;
    }
    if (widget.item.notificationable_type == 'contributionmission') {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'contributionmission'));
      return;
    }
    if (widget.item.notification_type == 'new_coupon') {
      _bloc.add(LoadDetailEvent(widget.item.source_id, 'new_coupon'));
      return;
    }
    if (widget.item.notification_type == 'training_data') {
      _bloc.add(LoadDetailEvent(widget.item.notificationable_id, 'training_data'));
      return;
    }

    _lock = false;
  }

  void _openVideoCall() => UtilUI.chatCallNavigation(context, () => UtilUI.goToNextPage(context, ExpertPage(
    callBackContact: () => UtilUI.goToNextPage(context, const HandbookPage()),
    callBackLogin: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())))));

  void _delete() {
    _bloc.add(DeleteNotificationEvent(widget.item.id));
    Util.trackActivities('notification', path: 'Notification Screen -> Remove ${widget.item.content} item');
  }

  void _handleResponse(BaseResponse base, Function funHandleDetail, {bool passString = true, bool setLock = true}) {
    if (base.checkTimeout()) UtilUI.showDialogTimeout(context);
    else if (base.checkOK(passString: passString)) funHandleDetail();
    else if (base.data != null && base.data is String) UtilUI.showCustomDialog(context, base.data);
    if (setLock) _lock = false;
  }

  void _handleSeen() {
    widget.item.status = 'seen';
    BlocProvider.of<MainBloc>(context).add(CountNotificationMainEvent(loadList: false));
  }

  void _handleDelete() {
    widget.item.id = -1;
    BlocProvider.of<MainBloc>(context).add(CountNotificationMainEvent(loadList: false));
  }

  void _gotoPostDetail(post) => UtilUI.goToNextPage(context, PostDetailPage(post, 0, widget.blocHome, widget.shopId.toString(), null));

  void _gotoShop(shop) => UtilUI.goToNextPage(context, ShopPage(shop: shop, isOwner: false, hasHeader: true, isView: true));

  void _gotoComment(comment) {
    comment.source_type = widget.item.source_type;
    comment.source_id = widget.item.source_id;
    UtilUI.goToNextPage(context, CommentDetailPage(comment));
  }

  void _gotoMarketPrice(marketPrice) => UtilUI.goToNextPage(context, MarketPriceDtlPage(marketPrice, (){}));

  void _gotoImageDtl(post, int index) => UtilUI.goToNextPage(context, SliderVideoPage(post, index: index));

  void _gotoOrderDtl(order) => UtilUI.goToNextPage(context, OrderDtlPage(order, false, (){}));

  void _gotoPlotDtl(plot) => UtilUI.goToNextPage(context, PlotsDtlPage(plot, (){}));

  void _gotoMaterialDtl(material) => UtilUI.goToNextPage(context, MaterialDtlPage(material, (){}));

  void _gotoFarmDtl(farm) => UtilUI.goToNextPage(context, FarmManageDtlPage(farm, (){}));

  void _gotoMissionDtl(mission) => UtilUI.goToNextPage(context, (mission['user_id']??-1) != Constants().userId ?
    MissionDetailPage(mission) : MissionMineDetailPage(mission));

  void _gotoMemPackageDtl(memPack) => UtilUI.goToNextPage(context,
      MemPackageDetailPage(memPack, MemPackageContent(memPack),
          isConfirm: widget.item.notification_type == 'invite_use_membership_package',
          inUse: widget.item.notification_type == 'membership_packages'));
  
  void _gotoProductDtl(product) => UtilUI.goToNextPage(context, ProductDetailPage(product, ShopModel()));

  void _gotoExeContributionDtl(exeCont) => UtilUI.goToNextPage(context, ExeContributionDetailPage(exeCont, false));

  void _gotoCouponDtl(coupon) => UtilUI.goToNextPage(context, DisCodeDetailPage(coupon));

  void _gotoPestContributionDtl(detail) => UtilUI.goToNextPage(context, DiagnosePetsContributePage(const [], detail: detail, isReview: true, readOnly: true));
}
