import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/permission_image_page_state.dart';
import 'package:hainong/features/function/tool/farm_management/ui/task_detail_page.dart';
import 'package:hainong/features/post/bloc/post_item_bloc.dart';
import 'package:hainong/features/shop/ui/import_ui_shop.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_device_id/platform_device_id.dart';
import '../harvest_task_bloc.dart';
import 'harvest_task_detail_page.dart';

class HarvestTaskListPage extends BasePage {
  final int id, planId;
  final String qrCode, name, status, start, end;
  final Function updateWork;
  HarvestTaskListPage(this.id, this.planId, this.start, this.end, this.qrCode, this.name, this.status, this.updateWork, {Key? key}) : super(pageState: _HarvestTaskListPageState(), key: key);
}

class _HarvestTaskListPageState extends PermissionImagePageState {
  final ScrollController _scroller = ScrollController();
  final List _list = [true];
  final Map<String, String> _works = {
    'making_land': 'Làm đất',
    'pruning': 'Cắt tỉa',
    'sowing_seeds': 'Gieo hạt',
    'fertilize': 'Bón phân',
    'spray': 'Tưới cây',
    'harvest': 'Thu hoạch',
    'other': 'Khác'
  };
  int _pageHarvest = 1, _pagePlan = 1;
  bool _isFinish = false;

  @override
  void loadFiles(List<File> files) {}

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _works.clear();
    super.dispose();
  }

  @override
  void initState() {
    showCamGal = false;
    final page = widget as HarvestTaskListPage;
    _isFinish = page.status != 'working';
    bloc = HarvestTaskBloc(page.id);
    if (page.planId < 0) _pagePlan = 0;
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadTaskDtlState) {
        _list.addAll(state.resp.data);
        _pageHarvest = state.pageHarvest;
        _pagePlan = state.pagePlan;
      } else if (state is FinishHarvestState && isResponseNotError(state.resp, passString: true)) {
        (widget as HarvestTaskListPage).updateWork();
        setState(() {
          _isFinish = true;
        });
      } else if (state is DownloadFilesPostItemState && state.response.isNotEmpty) {
        bloc!.add(SaveFileEvent(state.response[0]));
      } else if (state is SaveFileState) {
        UtilUI.showCustomDialog(context, state.value ? 'Lưu ảnh thành công' : 'Lưu ảnh thất bại', title: state.value ? 'Thông báo' : 'Cảnh báo');
      }
    });
    _loadMore();
    _scroller.addListener(_listenScroller);
    _setPermission();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
          onTapDown: (value) {clearFocus();},
          child: Stack(children: [
            createUI(),
            Loading(bloc)
          ])));

  @override
  Widget createUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: RefreshIndicator(child: BlocBuilder(bloc: bloc,
      buildWhen: (oldState, newState) => newState is LoadTaskDtlState && _list.length > 1,
      builder: (context, state) {
        return ListView.separated(
          padding: _isFinish ? EdgeInsets.only(bottom: 40.sp) : EdgeInsets.zero, controller: _scroller,
          itemCount: _list.length, physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: index > 0 ? 10.sp : 0),
          itemBuilder: (context, index) {
            if (index > 0) {
              return Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp),
                child: IntrinsicHeight(child: Row(children: [
                  _itemTitle(index, _list[index][1].working_date, _list[index][1].jobs, _list[index][1].images, false),
                  SizedBox(width: 5.sp),
                  _itemTitle(index, _list[index][0].working_date, _list[index][0].jobs, _list[index][0].images, true)
                ], mainAxisAlignment: MainAxisAlignment.start)));
            }

            final String qrCode = (widget as HarvestTaskListPage).qrCode;
            final Widget qr = Image.asset('assets/images/ic_default.png', width: 240.sp, height: 240.sp, fit: BoxFit.cover);
            return Column(children: [
              Container(padding: EdgeInsets.all(40.sp),
                  alignment: Alignment.centerLeft,
                  child: LabelCustom('Tên mùa vụ: ' + (widget as HarvestTaskListPage).name,
                      align: TextAlign.left, size: 42.sp, color: const Color(0xFF1AAD80), weight: FontWeight.normal)),
              ButtonImageWidget(0, _downloadQR, Column(children: [
                qrCode.isEmpty ? qr : FadeInImage.assetNetwork(
                    placeholder: 'assets/images/ic_default.png',
                    imageErrorBuilder: (_,__,___) => qr,
                    image: Util.getRealPath(qrCode),
                    width: 420.sp, height: 420.sp, fit: BoxFit.cover, imageScale: 0.5),
                if (qrCode.isEmpty) SizedBox(height: 20.sp),
                LabelCustom('Quét mã', size: 36.sp, color: const Color(0xFF2D2D2D), weight: FontWeight.normal)
              ])),
              Divider(height: 100.sp, color: const Color(0xFFF4F4F4), thickness: 20.sp),
              Container(padding: EdgeInsets.symmetric(horizontal: 40.sp),
                  alignment: Alignment.centerLeft,
                  child: LabelCustom('Danh sách công việc theo kế hoạch và thực tế',
                  align: TextAlign.left, size: 42.sp, color: const Color(0xFF1AAD80), weight: FontWeight.normal)),
              Container(child: Row(children: const [
                Expanded(child: LabelCustom('Kế hoạch', align: TextAlign.center, weight: FontWeight.normal)),
                Expanded(child: LabelCustom('Thực tế', align: TextAlign.center, weight: FontWeight.normal)),
              ]), color: const Color(0xFF1AAD80), padding: EdgeInsets.all(20.sp),
                  margin: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0)),
            ]);
          });
        }), onRefresh: () async => _reset())),

    if (!_isFinish) Container(padding: EdgeInsets.all(40.sp), child: ButtonImageWidget(16.sp, () => _gotoDetail(-1, true),
        Container(padding: EdgeInsets.all(40.sp), child: Row(children: [
          Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 60.sp),
          const SizedBox(width: 5),
          LabelCustom('Thêm công việc', color: Colors.white, size: 48.sp, weight: FontWeight.normal)
        ], mainAxisAlignment: MainAxisAlignment.center)), color: StyleCustom.primaryColor)),
    if (!_isFinish) Container(padding: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp), width: 1.sw,
      child: ButtonImageWidget(16.sp, _finish, Container(padding: EdgeInsets.all(40.sp),
          child: LabelCustom('Kết thúc mùa vụ', color: Colors.white, size: 48.sp,
              weight: FontWeight.normal, align: TextAlign.center)), color: Colors.grey))
  ]);

  List<Widget> _itemDetails(String date, List<dynamic> jobs, List<String> images, bool isHarvest) {
    List<Widget> temp = [
      if (date.isNotEmpty) Padding(child: Row(children: [
        Icon(Icons.calendar_month, color: const Color(0xFF1AAD80), size: 42.sp),
        LabelCustom(' ' + Util.strDateToString(date, pattern: 'dd/MM/yyyy'), color: const Color(0xFF414141), weight: FontWeight.normal)
      ]), padding: EdgeInsets.only(bottom: 20.sp))
    ];

    String title = '';
    for(int i = 0; i < jobs.length; i++) {
      title = jobs[i].title;
      if (isHarvest && title.isEmpty && jobs[i].working_type.isNotEmpty) {
        title = _works[jobs[i].working_type]??'';
      }
      if (title.isNotEmpty) temp.add(Padding(child: LabelCustom(' - ' + title, color: Colors.black, weight: FontWeight.normal), padding: EdgeInsets.only(bottom: 20.sp)));
    }

    if (images.isNotEmpty) {
      temp.add(Padding(child: const LabelCustom('Hình ảnh', color: Color(0xFF5F5F5F), weight: FontWeight.normal, style: FontStyle.italic), padding: EdgeInsets.only(bottom: 20.sp)));

      Widget image1 = _image(images[0]);
      Widget? image2 = images.length > 1 ? _image(images[1]) : null;
      temp.add(images.length > 1 ? Row(children: [
        image1,
        SizedBox(width: 10.sp),
        images.length > 2 ? Stack(children: [
          image2!,
          Container(child: LabelCustom('+' + (images.length - 2).toString(), weight: FontWeight.normal, size: 36.sp),
              alignment: Alignment.center, padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(100)),)
        ], alignment: Alignment.center) : image2!
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween) : image1);
    }

    return temp;
  }

  Widget _image(String image) => ClipRRect(child: FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png',
      imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', width: 0.25.sw - 50.sp, height: 0.12.sw, fit: BoxFit.fill),
  image: Util.getRealPath(image),
  width: 0.25.sw - 50.sp, height: 0.12.sw, fit: BoxFit.fill, imageScale: 0.5), borderRadius: BorderRadius.circular(8.sp));

  Widget _itemTitle(int index, String date, List<dynamic> jobs, List<String> images, bool isHarvest) =>
    Expanded(child: ButtonImageWidget(0, () => _gotoDetail(index, isHarvest),
      Container(color: const Color(0xFFF1FCF9), padding: EdgeInsets.all(20.sp),
        child: Column(children: _itemDetails(date, jobs, images, isHarvest), crossAxisAlignment: CrossAxisAlignment.start)
    )));

  Future<void> _setPermission() async {
    dynamic per = [];
    if (Platform.isAndroid) {
      var info = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      if (info.version.sdkInt >= 32) {
        per.add(Permission.photos);
        per.add(Permission.audio);
        per.add(Permission.videos);
      } else {
        per.add(Permission.storage);
      }
    } else per.add(Permission.storage);
    funCheckPermissions(arrayPer: per);
  }

  void _loadMore() => bloc!.add(LoadTaskDtlEvent(_pageHarvest, _pagePlan, (widget as HarvestTaskListPage).planId));

  void _listenScroller() {
    if ((_pageHarvest + _pagePlan > 0) && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _reset() {
   setState(() => _list.removeRange(1, _list.length));
   _pageHarvest = 1;
   _pagePlan = 1;
   if ((widget as HarvestTaskListPage).planId < 0) _pagePlan = 0;
   _loadMore();
  }

  void _gotoDetail(int index, bool isHarvest) {
    final page = widget as HarvestTaskListPage;
    if (isHarvest) {
      if (index < 0) {
        UtilUI.goToNextPage(context, HarvestTaskDtlPage(page.id, HarvestTaskModel(), _reset, _works, _isFinish));
        return;
      }

      final temp = _list[index][0];
      if (temp.id > 0) UtilUI.goToNextPage(context, HarvestTaskDtlPage(page.id, temp, _reset, _works, _isFinish));
      return;
    }

    final temp = _list[index][1];
    if (temp.id > 0) UtilUI.goToNextPage(context, TaskDtlPage(page.planId, page.start, page.end, temp, _reset));
  }

  void _finish() => bloc!.add(FinishHarvestEvent());

  void _downloadQR() {
    final String link = (widget as HarvestTaskListPage).qrCode;
    if (link.isNotEmpty) bloc!.add(DownloadFilesPostItemEvent([ItemModel(name: link)]));
  }
}