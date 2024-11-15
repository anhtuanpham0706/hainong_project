import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/show_popup_html.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'package:hainong/features/function/support/mission/ui/mission_review_page.dart';
import 'package:hainong/features/function/tool/nutrition_map/nutrition_location_page.dart';
import 'package:trackasia_gl/mapbox_gl.dart';
import '../mission_bloc.dart';
import 'mission_sub_detail_page.dart';
import 'mission_mine_sub_detail_page.dart';

class MissionMineDetailPage extends BasePage {
  dynamic item;
  final Function? reload;
  MissionMineDetailPage(this.item, {this.reload, Key? key}) : super(pageState: _MissionMineDetailPageState(), key: key);
}

class _MissionMineDetailPageState extends BasePageState {
  final List _list = [], _members = [], _reviews = [];
  final TextEditingController _ctrName = TextEditingController(), _ctrCat = TextEditingController(),
      _ctrStart = TextEditingController(), _ctrEnd = TextEditingController(), _ctrDes = TextEditingController(),
      _ctrProvince = TextEditingController(), _ctrDistrict = TextEditingController(), _ctrAddress = TextEditingController();
  final FocusNode _fcName = FocusNode(), _fcCat = FocusNode(), _fcStart = FocusNode(), _fcEnd = FocusNode(),
      _fcDes = FocusNode(), _fcProvince = FocusNode(), _fcDistrict = FocusNode(), _fcAddress = FocusNode();
  final List<ItemModel> _cats = [], _provinces = [], _districts = [];
  final ItemModel _cat = ItemModel(), _province = ItemModel(), _district = ItemModel();
  LatLng? _address;
  bool _isView = false;
  int _id = -1;

  @override
  void dispose() {
    _reviews.clear();
    _members.clear();
    _list.clear();
    _ctrName.dispose();
    _fcName.dispose();
    _ctrCat.dispose();
    _fcCat.dispose();
    _ctrStart.dispose();
    _fcStart.dispose();
    _ctrEnd.dispose();
    _fcEnd.dispose();
    _ctrDes.dispose();
    _fcDes.dispose();
    _ctrProvince.dispose();
    _fcProvince.dispose();
    _ctrDistrict.dispose();
    _fcDistrict.dispose();
    _ctrAddress.dispose();
    _fcAddress.dispose();
    _cats.clear();
    _provinces.clear();
    _districts.clear();
    super.dispose();
  }

  @override
  void initState() {
    _initData();
    bloc = MissionBloc('mine_detail',typeInfo: 'mission');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadMissionsState) {
        _list.addAll(state.resp);
        if (state.counts != null) {
          setState(() {
            final item = (widget as MissionMineDetailPage).item;
            if (item != null) {
              item['number_joins'] = state.counts![0];
              item['total_points'] = state.counts![1];
            }
          });
        }
      } else if (state is LoadMembersState) {
        _members.addAll(state.resp);
      } else if (state is LoadReviewsState) {
        _reviews.addAll(state.resp);
      } else if (state is LoadCatalogueState) {
        _cats.addAll(state.resp);
      } else if (state is LoadProvinceState) {
        _provinces.addAll(state.list);
      } else if (state is LoadDistrictState) {
        _districts.addAll(state.list);
      } else if (state is GetAddressState) {
        final json = state.address;
        final hasPro = Util.checkKeyFromJson(json, 'province_id');
        _setProvince(hasPro ? ItemModel(id: json['province_id'].toString(), name: json['province_name']) : ItemModel(), loadDistrict: hasPro);
        _setDistrict(Util.checkKeyFromJson(json, 'district_id') ? ItemModel(id: json['district_id'].toString(), name: json['district_name']) : ItemModel());
        _ctrAddress.text = Util.checkKeyFromJson(json, 'address_full') ? json['address_full'] : '';
      } else if (state is GetLocationState) {
        try {
          double lat = double.parse((state.latLng['lat']??.0).toString());
          double lng = double.parse((state.latLng['lng']??.0).toString());
          _address = LatLng(lat, lng);
        } catch (_) {}
      } else if (state is ReviewMissionState && isResponseNotError(state.resp, passString: true)) {
        _loadSubMissions(reload: true);
        _loadMembers(reload: true);
        _loadReviews(reload: true);
        UtilUI.showCustomDialog(context, 'Đã ${state.status == 'accepted' ? 'đồng ý' : 'từ chối'} duyệt thành công');
      } else if (state is SetLeaderState && isResponseNotError(state.resp, passString: true)) {
        for (int i = _members.length - 1; i > -1; i--) {
          if (_members[i]['mission_detail_id'] == _members[state.index]['mission_detail_id']) _members[i]['regency'] = 'normal';
        }
        setState(() {
          _members[state.index]['regency'] = 'leader';
        });
      } else if (state is SaveMissionState && isResponseNotError(state.resp, passString: true)) {
        final page = widget as MissionMineDetailPage;
        if (page.reload != null) page.reload!();
        String msg = 'Lưu thành công';
        switch(state.status) {
          case 'completed': msg = 'Kết thúc nhiệm vụ thành công'; break;
          case 'delete': msg = 'Xoá nhiệm vụ thành công'; break;
        }
        UtilUI.showCustomDialog(context, msg).whenComplete(() => UtilUI.goBack(context, true));
      }
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final item = (widget as MissionMineDetailPage).item;
    double joined = .0, total = .0, points = .0, width = 1.sw - 80.sp;
    if (item != null) {
      joined = (item['total_joined']??.0).toDouble();
      total = (item['number_joins']??.0).toDouble();
      points = (item['total_points']??.0).toDouble();
      width = joined == .0 ? 0.33.sw - 40.sp : 0.5.sw - 60.sp;
    }
    return Stack(children: [
      Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true, title: UtilUI.createLabel('Nhiệm vụ tự tạo'),
          actions: [IconButton(onPressed: clearFocus, icon: Icon(Icons.keyboard, color: Colors.white, size: 48.sp))]),
          backgroundColor: color, body: Column(children: [
            Expanded(child: ListView(padding: EdgeInsets.zero, children: [
              _header(),
              Divider(height: 20.sp, thickness: 20.sp, color: const Color(0xFFF4F4F4)),
              Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
                LabelCustom('Danh sách nhiệm vụ con', size: 46.sp, color: Colors.black, weight: FontWeight.normal),
                if (item != null && !_isView) ButtonImageWidget(5, _addSubMission, Row(children: [
                  Icon(Icons.add_circle_outline, size: 48.sp, color: const Color(0xFF26B186)),
                  LabelCustom(' Thêm', size: 46.sp, color: const Color(0xFF26B186), weight: FontWeight.normal)
                ]))
              ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),
              const FarmManageTitle([['Tên nhiệm vụ', 3], ['Thời gian\nthực hiện', 3, TextAlign.center], ['Số người', 2, TextAlign.center], ['Số điểm', 2, TextAlign.center]]),
              BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadMissionsState,
                builder: (context, state) => ListView.builder(itemBuilder: (context, index) => _item(index),
                  padding: EdgeInsets.zero, itemCount: _list.length, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics())),
              FarmManageTitle([const ['Tổng', 6],
                [Util.doubleToString(joined) + '/' + Util.doubleToString(total), 2, TextAlign.center],
                [Util.doubleToString(points), 2, TextAlign.center]], hasBg: false),

              Divider(height: 20.sp, thickness: 20.sp, color: const Color(0xFFF4F4F4)),
              Padding(padding: EdgeInsets.all(40.sp), child: LabelCustom('Thành viên tham gia', size: 46.sp, color: Colors.black, weight: FontWeight.normal)),
              const FarmManageTitle([['Thành viên', 2], ['Số ĐT', 3, TextAlign.center], ['Tên NV', 2], ['Nhóm trưởng', 3, TextAlign.center]]),
              BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadMembersState || newS is SetLeaderState,
                  builder: (context, state) => ListView.builder(itemBuilder: (context, index) => _itemMember(index),
                      padding: EdgeInsets.zero, itemCount: _members.length, shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics())),

              Divider(height: 20.sp, thickness: 20.sp, color: const Color(0xFFF4F4F4)),
              Padding(padding: EdgeInsets.all(40.sp), child: LabelCustom('Danh sách các thành viên chờ duyệt',
                  size: 46.sp, color: Colors.black, weight: FontWeight.normal)),
              const FarmManageTitle([['Thành viên', 2], ['Số ĐT', 3, TextAlign.center], ['Tên NV', 3], ['', 2]]),
              BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadReviewsState,
                  builder: (context, state) => ListView.builder(itemBuilder: (context, index) => _itemReview(index),
                      padding: EdgeInsets.zero, itemCount: _reviews.length, shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics())),
            ])),

            const Divider(height: 0.5, color: Colors.black12),
            if (!_isView) Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
              if (item != null && joined == .0) ButtonImageWidget(16.sp, _remove,
                  Container(padding: EdgeInsets.all(40.sp), width: width, child: LabelCustom('Xoá NV',
                      color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26),
              if (item != null) ButtonImageWidget(16.sp, _complete,
                  Container(padding: EdgeInsets.all(40.sp), width: width, child: LabelCustom('Kết thúc',
                      color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor),
              ButtonImageWidget(16.sp, _save,
                  Container(padding: EdgeInsets.all(40.sp), width: width, child: LabelCustom('Lưu',
                      color: Colors.white, size: 48.sp, weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor)
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),
          ])),
      Loading(bloc)
    ]);
  }

  Widget _header() {
    final color = const Color(0XFFF5F6F8);
    final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
    return Padding(child: Column(children: [
      Row(children: [_title('Tên nhiệm vụ'), require,ShowInfo(bloc, "title")]),
      Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrName,
          _fcName, null, 'Nhập tên nhiệm vụ', size: 42.sp, color: color, readOnly: _isView,
          borderColor: color, maxLine: 0, inputAction: TextInputAction.newline,
          type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

      Row(children: [_title('Danh mục nhiệm vụ'), require]),
      Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
          child: TextFieldCustom(_ctrCat, _fcCat, null, 'Chọn danh mục nhiệm vụ',
              size: 42.sp, color: color, borderColor: color, readOnly: true,
              onPressIcon: _selectCat, maxLine: 0, inputAction: TextInputAction.newline,
              type: TextInputType.multiline, padding: EdgeInsets.all(30.sp),
              suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp))),

      Row(children: [_title('Thời gian thực hiện nhiệm vụ'), require]),
      SizedBox(height: 16.sp),
      Row(children: [
        Expanded(child: Column(children: [
          Row(children: [_title('Bắt đầu', style: FontStyle.italic),ShowInfo(bloc, "start_date")],),
          Padding(child: TextFieldCustom(_ctrStart, _fcStart, null, 'dd/MM/yyyy', size: 42.sp,
              color: color, borderColor: color, readOnly: true, onPressIcon: _selectDate,
              suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
        ], crossAxisAlignment: CrossAxisAlignment.start)),
        const SizedBox(width: 10),
        Expanded(child: Column(children: [
          Row(children: [_title('Kết thúc', style: FontStyle.italic),ShowInfo(bloc, "end_date")],),
          Padding(child: TextFieldCustom(_ctrEnd, _fcEnd, null, 'dd/MM/yyyy', size: 42.sp,
              color: color, borderColor: color, readOnly: true, onPressIcon: () => _selectDate(isStart: false),
              suffix: Icon(Icons.calendar_today, color: Colors.grey, size: 48.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
        ], crossAxisAlignment: CrossAxisAlignment.start))
      ]),

      Row(children: [_title('Mô tả tổng quát'),ShowInfo(bloc, "content")],),
      Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child: TextFieldCustom(_ctrDes,
          _fcDes, null, 'Nhập mô tả ...', size: 42.sp, color: color, readOnly: _isView,
          borderColor: color, maxLine: 0, inputAction: TextInputAction.newline,
          type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),

      Row(children: [
        Expanded(child: Column(children: [
          Row(children: [_title('Tình/ Thành phố'), require]),
          Padding(child: TextFieldCustom(_ctrProvince, _fcProvince, null, 'Chọn tình/ Thành phố', size: 42.sp,
              color: color, borderColor: color, readOnly: true, onPressIcon: _selectProvince,
              type: TextInputType.multiline, inputAction: TextInputAction.newline, maxLine: 0,
              suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp),
              padding: EdgeInsets.all(30.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
        ], crossAxisAlignment: CrossAxisAlignment.start)),
        const SizedBox(width: 10),
        Expanded(child: Column(children: [
          Row(children: [_title('Quận/ Huyện'), require]),
          Padding(child: TextFieldCustom(_ctrDistrict, _fcDistrict, null, 'Chọn quận/ Huyện', size: 42.sp,
              color: color, borderColor: color, readOnly: true, onPressIcon: _selectDistrict,
              type: TextInputType.multiline, inputAction: TextInputAction.newline, maxLine: 0,
              suffix: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 64.sp),
              padding: EdgeInsets.all(30.sp)), padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp))
        ], crossAxisAlignment: CrossAxisAlignment.start))
      ], crossAxisAlignment: CrossAxisAlignment.start),

      Row(children: [_title('Địa chỉ'),ShowInfo(bloc, "address")],),
      SizedBox(height: 16.sp),
      Row(children: [
        Expanded(child: TextFieldCustom(_ctrAddress, _fcAddress, null, 'Nhập địa chỉ', size: 42.sp,
            color: color, borderColor: color, readOnly: _isView, maxLine: 0, inputAction: TextInputAction.newline,
            type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),
        SizedBox(width: 20.sp),
        ButtonImageWidget(5, _openMap, Image.asset('assets/images/v5/ic_map_main2.png',
            width: 128.sp, height: 128.sp, fit: BoxFit.scaleDown))
      ]),
    ], crossAxisAlignment: CrossAxisAlignment.start), padding: EdgeInsets.all(40.sp));
  }

  Widget _item(int index) {
    double joined = (_list[index]['total_joined']??.0).toDouble(),
        total = (_list[index]['number_joins']??.0).toDouble();
    String startDate = _list[index]['start_date']??'',
        endDate = _list[index]['end_date']??'', date = '';
    if (startDate.isNotEmpty) {
      startDate = Util.strDateToString(startDate, pattern: 'dd/MM/yyyy');
      date = startDate;
    }
    if (endDate.isNotEmpty) {
      endDate = Util.strDateToString(endDate, pattern: 'dd/MM/yyyy');
      date += (date.isEmpty ? '' : '\n') + endDate;
    }
    return FarmManageItem([
      [_list[index]['title']??'', 3],
      [date, 3, TextAlign.center],
      [Util.doubleToString(joined) + '/' + Util.doubleToString(total), 2, TextAlign.center],
      [Util.doubleToString((_list[index]['point']??.0).toDouble()), 2, TextAlign.center]
    ], index, action: _gotoSubMissionDetail);
  }

  Widget _itemMember(int index) {
    bool normal = (_members[index]['regency']??'normal') != 'leader';
    return FarmManageItem([
      [_members[index]['user_name']??'', 2],
      [_members[index]['user_phone']??'', 3, TextAlign.center],
      [_members[index]['mission_detail_title']??'', 2],
      [Row(children: [
        ButtonImageWidget(0, () => _setLeader(index, normal), Icon(normal ? Icons.check_box_outline_blank : Icons.check_box,
            color: normal ? Colors.black26 : StyleCustom.primaryColor, size: 64.sp)),
        if (!normal) Flexible(child: Padding(child: ButtonImageWidget(5, () => _rate(index), Row(children: [
            Image.asset('assets/images/v5/ic_review_mission.png', width: 28.sp, height: 28.sp),
            Flexible(child: LabelCustom(' Đánh\ngiá', size: 42.sp, color: const Color(0xFFFFA800), weight: FontWeight.normal, align: TextAlign.center))
          ], mainAxisAlignment: MainAxisAlignment.center)), padding: EdgeInsets.only(left: 10.sp)))
      ], mainAxisAlignment: MainAxisAlignment.center), 3, TextAlign.center]
    ], index);
  }

  Widget _itemReview(int index) => FarmManageItem([
      [_reviews[index]['user_name']??'', 2],
      [_reviews[index]['user_phone']??'', 3, TextAlign.center],
      [_reviews[index]['mission_detail_title']??'', 3],
      [ButtonImageWidget(4, () => _review(index), Padding(padding: EdgeInsets.all(10.sp), child:
        LabelCustom('Duyệt', size: 36.sp, align: TextAlign.center)), color: StyleCustom.primaryColor), 2, TextAlign.center]
  ], index);

  Widget _title(String title, {FontStyle style = FontStyle.normal}) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal, style: style);

  void _initData() {
    final item = (widget as MissionMineDetailPage).item;
    if (item != null) {
      _id = item['id']??-1;
      _isView = (item['work_status']??'pending') == 'completed';
      _ctrName.text = item['title']??'';
      _ctrDes.text = item['content']??'';
      _ctrAddress.text = item['address']??'';
      String temp = item['start_date']??'';
      if (temp.isNotEmpty) {
        try {
          _ctrStart.text = Util.strDateToString(temp, pattern: 'dd/MM/yyyy');
        } catch (_) {}
      }
      temp = item['end_date']??'';
      if (temp.isNotEmpty) {
        try {
          _ctrEnd.text = Util.strDateToString(temp, pattern: 'dd/MM/yyyy');
        } catch (_) {}
      }
      _setCat(ItemModel(id: (item['mission_catalogue_id']??'').toString(), name: item['mission_catalogue_name']??''));
      _setProvince(ItemModel(id: (item['province_id']??'').toString(), name: item['province_name']??''), loadDistrict: false);
      _setDistrict(ItemModel(id: (item['district_id']??'').toString(), name: item['district_name']??''));
    }
  }

  void _selectCat() {
    if (_isView) return;
    UtilUI.showOptionDialog(context, 'Chọn danh mục nhiệm vụ', _cats, _cat.id).then((value) {
      if (value != null) _setCat(value);
    });
  }

  void _setCat(ItemModel value) {
    if (_cat.id != value.id) {
      _ctrCat.text = value.name;
      _cat.setValue(value.id, value.name);
    }
  }

  void _selectDate({bool isStart = true}) {
    if (_isView) return;
    clearFocus();
    String temp = isStart ? _ctrStart.text : _ctrEnd.text;
    if (temp.isEmpty) {
      final now = DateTime.now();
      temp = '${now.day}/${now.month}/${now.year}';
    }
    DatePicker.showDatePicker(context,
        minTime: DateTime.now().add(const Duration(days: -3650)),
        maxTime: DateTime.now().add(const Duration(days: 3650)),
        showTitleActions: true,
        onConfirm: (DateTime date) => _setDate(date, isStart),
        currentTime: Util.stringToDateTime(temp, pattern: 'dd/MM/yyyy'),
        locale: LocaleType.vi);
  }

  void _setDate(DateTime date, bool isStart) {
    if (isStart) {
      if (_ctrEnd.text.isNotEmpty) {
        DateTime end = Util.stringToDateTime(_ctrEnd.text, pattern: 'dd/MM/yyyy');
        if (date.compareTo(end) > 0) return;
      }
    } else {
      if (_ctrStart.text.isNotEmpty) {
        DateTime start = Util.stringToDateTime(_ctrStart.text, pattern: 'dd/MM/yyyy');
        if (date.compareTo(start) < 0) return;
      }
    }
    String temp = Util.dateToString(date, pattern: 'dd/MM/yyyy');
    isStart ? _ctrStart.text = temp : _ctrEnd.text = temp;
  }

  void _selectProvince() {
    if (_isView) return;
    UtilUI.showOptionDialog(context, 'Chọn tỉnh/ Thành phố', _provinces, _province.id).then((value) {
      if (value != null) _setProvince(value);
    });
  }

  void _setProvince(ItemModel value, {bool loadDistrict = true}) {
    if (_province.id != value.id) {
      _ctrProvince.text = value.name;
      _province.setValue(value.id, value.name);

      if (loadDistrict) {
        _districts.clear();
        _ctrDistrict.text = '';
        _district.setValue('', '');
        bloc!.add(LoadDistrictEvent(_province.id));
      }
    }
  }

  void _selectDistrict() {
    if (_isView) return;
    UtilUI.showOptionDialog(context, 'Chọn quận/ Huyện', _districts, _district.id).then((value) {
      if (value != null) _setDistrict(value);
    });
  }

  void _setDistrict(ItemModel value) {
    if (_district.id != value.id) {
      _ctrDistrict.text = value.name;
      _district.setValue(value.id, value.name);
    }
  }

  void _openMap() {
    if (_isView) return;
    UtilUI.goToNextPage(context, NutritionLocPage(current: _address), funCallback: (value) {
      if (value != null) _setAddress(value);
    });
  }

  void _setAddress(LatLng value) {
    _address = value;
    bloc!.add(GetAddressEvent(value));
  }

  void _loadData() {
    if (_id > 0) {
      _loadSubMissions();
      _loadMembers();
      _loadReviews();
    }
    bloc!.add(LoadCatalogueEvent());
    bloc!.add(LoadProvinceEvent());
    if (_ctrAddress.text.trim().isNotEmpty) bloc!.add(GetLocationEvent(_ctrAddress.text.trim()));
  }

  void _loadSubMissions({bool reload = false}) {
    if (reload) _list.clear();
    bloc!.add(LoadMissionsEvent(1, '', _id.toString(), reload));
  }

  void _gotoSubMissionDetail(int index) {
    final total = (_list[index]['total_joined']??.0).toDouble();
    final completed = (_list[index]['work_status']??'') == 'completed';
    UtilUI.goToNextPage(context, total > 0 || completed ? MissionSubDetailPage((widget as MissionMineDetailPage).item, _list[index], reload: () => _loadSubMissions(reload: true)) :
      MissionMineSubDetailPage((widget as MissionMineDetailPage).item, _list[index], reload: () => _loadSubMissions(reload: true),
        addressExtend: _ctrAddress.text, addressLocation: _address, province: _province, district: _district));
  }

  void _addSubMission() {
    final item = (widget as MissionMineDetailPage).item;
    if (_isView || item == null) return;
    UtilUI.goToNextPage(context, MissionMineSubDetailPage(item, null, reload: () => _loadSubMissions(reload: true),
      addressExtend: _ctrAddress.text, addressLocation: _address, province: _province, district: _district));
  }

  void _setLeader(int index, bool normal) {
    if (!_isView && normal) { bloc!.add(SetLeaderEvent((widget as MissionMineDetailPage).item['id'],
        _members[index]['mission_detail_id'] ?? -1, _members[index]['id'] ?? -1, index)); }
  }

  void _loadMembers({bool reload = false}) {
    if (reload) _members.clear();
    bloc!.add(LoadMembersEvent(_id));
  }

  void _rate(int index) {
    final item = (widget as MissionMineDetailPage).item;
    UtilUI.goToNextPage(context, MissionReviewPage(item['id']??-1, _members[index]['mission_detail_id']??-1, (_members[index]['total_joined']??0).toInt(), _isView));
  }

  void _review(int index) => UtilUI.showCustomDialog(context, 'Đồng ý hoặc từ chối duyệt ' + (_reviews[index]['user_name']??'') +
      ' tham gia vào nhiệm vụ ' + (_reviews[index]['mission_detail_title']??''), title: 'Thông báo', isActionCancel: true,
    lblCancel: 'Từ chối', lblOK: 'Đồng ý').then((value) {
      if (value != null && value) {
        final item = (widget as MissionMineDetailPage).item;
        bloc!.add(ReviewMissionEvent(item['id'], _reviews[index]['mission_detail_id']??-1, _reviews[index]['id']??-1, value ? 'accepted' : 'rejected'));
      }
  });

  void _loadReviews({bool reload = false}) {
    if (reload) setState(() { _reviews.clear(); });
    bloc!.add(LoadReviewsEvent(_id));
  }

  void _save() {
    clearFocus();
    if (_ctrName.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập tên nhiệm vụ').whenComplete(() => _fcName.requestFocus());
      return;
    }
    if (_cat.id.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn danh mục nhiệm vụ').whenComplete(() => _fcCat.requestFocus());
      return;
    }
    if (_ctrStart.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn ngày bắt đầu thực hiện nhiệm vụ').whenComplete(() => _fcStart.requestFocus());
      return;
    }
    if (_ctrEnd.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn ngày kết thúc thực hiện nhiệm vụ').whenComplete(() => _fcEnd.requestFocus());
      return;
    }
    if (_ctrProvince.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn tỉnh/ Thành phố').whenComplete(() => _fcProvince.requestFocus());
      return;
    }
    if (_ctrDistrict.text.trim().isEmpty) {
      UtilUI.showCustomDialog(context, 'Chọn quận/ Huyện').whenComplete(() => _fcDistrict.requestFocus());
      return;
    }
    final item = (widget as MissionMineDetailPage).item;
    bloc!.add(SaveMissionEvent(item != null ? (item['id']??-1) : -1, _ctrName.text, _cat.id, _ctrStart.text,
        _ctrEnd.text, _ctrDes.text, _province.id, _district.id, _ctrAddress.text));
  }

  void _complete() => UtilUI.showCustomDialog(context, 'Bạn có thật sự muốn kết thúc nhiệm vụ này không?',
    isActionCancel: true).then((value) {
      if (value != null && value) bloc!.add(SaveMissionEvent((widget as MissionMineDetailPage).item['id'], '', '', '', '', '', '', '', '', status: 'completed'));
    });

  void _remove() {
    if (_members.isEmpty) return;
    UtilUI.showCustomDialog(context, 'Bạn có thật sự muốn xoá nhiệm vụ này không?', isActionCancel: true).then((value) {
      if (value != null && value) bloc!.add(SaveMissionEvent((widget as MissionMineDetailPage).item['id'], '', '', '', '', '', '', '', '', status: 'delete'));
    });
  }
}