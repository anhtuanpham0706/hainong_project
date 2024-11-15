import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/function/support/mission/mission_bloc.dart';
import '../ba_bloc.dart';

class BAEmployeeListPage extends BasePage {
  BAEmployeeListPage(int idBusiness, {Key? key}) : super(pageState: _BAEmployeeListPageState(idBusiness), key: key);
}

class _BAEmployeeListPageState extends BasePageState {
  final TextEditingController _ctrSearch = TextEditingController(), _ctrPhone = TextEditingController();
  final ScrollController _scroller = ScrollController();
  final FocusNode _fcPhone = FocusNode();
  final List _list = [];
  final Map<String, dynamic> _employee = {};
  int _page = 1, idBusiness;
  bool _lock = false;

  _BAEmployeeListPageState(this.idBusiness);

  @override
  void dispose() {
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _ctrSearch.dispose();
    _ctrPhone.dispose();
    _fcPhone.dispose();
    _employee.clear();
    _list.clear();
    super.dispose();
  }

  @override
  void initState() {
    bloc = BABloc('employee');
    super.initState();
    bloc!.stream.listen((state) {
      if (state is LoadListState) {
        if (isResponseNotError(state.response)) {
          final list = state.response.data;
          if (list.isNotEmpty) {
            _list.addAll(list);
            list.length == 20 ? _page++ : _page = 0;
          } else _page = 0;
        }
        _lock = false;
      } else if (state is EditState && isResponseNotError(state.response, passString: true)) {
        _reset();
      } else if (state is DeleteEmpState && isResponseNotError(state.resp, passString: true)) {
        _reset();
      }
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    GestureDetector(onTap: clearFocus, onHorizontalDragDown: (_) => clearFocus(), onVerticalDragDown: (_) => clearFocus(),
      child: Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true,
          title: UtilUI.createLabel('Danh sách nhân viên'),
          bottom: PreferredSize(preferredSize: Size(0.5.sw, 140.sp), child: Container(decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10.sp)),
              padding: EdgeInsets.all(30.sp), margin: EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is ShowClearSearchState,
                    builder: (context, state) {
                      bool show = false;
                      if (state is ShowClearSearchState) show = state.value;
                      return show ? Padding(padding: EdgeInsets.only(right: 20.sp),
                          child: ButtonImageWidget(100, _clear, Icon(Icons.clear,
                              size: 48.sp, color: const Color(0xFF676767)))) : const SizedBox();
                    }),
                Expanded(child: TextField(controller: _ctrSearch,
                    onChanged: (value) {
                      if (value.length == 1) bloc!.add(ShowClearSearchEvent(true));
                      if (value.isEmpty) bloc!.add(ShowClearSearchEvent(false));
                    },
                    onSubmitted: (value) => _search(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                        hintText: 'Tìm kiếm ...',
                        contentPadding: EdgeInsets.zero, isDense: true,
                        border: const UnderlineInputBorder(borderSide: BorderSide.none)
                    )
                )),
                ButtonImageWidget(100, _search, Icon(Icons.search, size: 48.sp, color: const Color(0xFF676767)))
              ])))),
        floatingActionButton: FloatingActionButton.small(backgroundColor: StyleCustom.primaryColor,
          onPressed: () {
            _employee.clear();
            _dialogInfoEmployee();
          }, child: Icon(Icons.add, color: Colors.white, size: 64.sp)),
        body: RefreshIndicator(child: BlocBuilder(bloc: bloc,
              buildWhen: (oldState, newState) => newState is LoadListState,
              builder: (context, state) => ListView.separated(padding: EdgeInsets.all(40.sp), controller: _scroller,
                  physics: const AlwaysScrollableScrollPhysics(), itemCount: _list.length,
                  separatorBuilder: (context, state) => SizedBox(height: 40.sp),
                  itemBuilder: (context, index) {
                    final name = _list[index]['user_name']??'';
                    final phone = _list[index]['user_phone']??'';
                    final notice = (_list[index]['notification']??0).toInt();
                    return ButtonImageWidget(10, () => _selectEmployee(index),
                        Container(padding: EdgeInsets.all(40.sp),decoration: BoxDecCustom(radius: 10, bgColor: const Color(0xAFFFFFFF)),
                          child: Column(children: [
                            if (name.isNotEmpty) Padding(padding: EdgeInsets.only(bottom: 20.sp),
                                child: LabelCustom('Họ tên: ' + name, color: Colors.black87, size: 48.sp, weight: FontWeight.normal)),
                            if (phone.isNotEmpty) Padding(padding: EdgeInsets.only(bottom: 20.sp),
                                child: LabelCustom('Số ĐT: ' + phone, color: Colors.black87, size: 48.sp, weight: FontWeight.normal)),
                            Row(children: [
                              LabelCustom('Nhận thông báo ', color: Colors.black87, size: 48.sp, weight: FontWeight.normal),
                              Icon(notice == 1 ? Icons.check_box : Icons.check_box_outline_blank, color: notice == 1 ? StyleCustom.primaryColor : Colors.grey, size: 64.sp)
                            ]),
                            SizedBox(height: 20.sp),
                            Row(children: [
                              LabelCustom('Truy cập: ', color: Colors.black87, size: 48.sp, weight: FontWeight.normal),
                              _permissionList(index, 'Sản phẩm '),
                              _permissionList(index, 'Đơn hàng ', type: 'invoice_users', align: MainAxisAlignment.end)
                            ])
                          ], crossAxisAlignment: CrossAxisAlignment.start)), color: (_list[index]['regency']??'normal') == 'normal' ? Colors.white : Colors.green.withOpacity(0.25));
                  })), onRefresh: () async => _reset()))),
    Loading(bloc)
  ]);

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  Widget _permissionList(int index, String title, {String type = 'products', MainAxisAlignment align = MainAxisAlignment.start}) {
    bool value = _isCheck((_list[index]['permission'])??[], type);
    return Expanded(child: Row(children: [
      LabelCustom(title, color: Colors.black87, size: 48.sp, weight: FontWeight.normal),
      Icon(value ? Icons.check_box : Icons.check_box_outline_blank, color: value ? StyleCustom.primaryColor : Colors.grey, size: 64.sp)
    ], mainAxisAlignment: align));
  }

  Widget _permissionEdit(String title, {String type = 'products', MainAxisAlignment align = MainAxisAlignment.start}) =>
    Expanded(child: Row(children: [
      LabelCustom(title, color: Colors.black87, size: 48.sp, weight: FontWeight.normal),
      ButtonImageWidget(0, () {
        final List per = [];
        per.addAll((_employee['permission'])??[]);
        if (per.isEmpty) { per.add(type); }
        else {
          if (per.length == 1) {
            per[0] == type ? per.clear() : per.add(type);
          } else {
            if (per[0] == type) per.removeAt(0);
            else if (per[1] == type) per.removeAt(1);
          }
        }
        _employee.update('permission', (value) => per, ifAbsent: () => per);
        bloc!.add(CheckPerEvent(per));
      }, BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is CheckPerState, builder: (context, state) {
        bool value = _isCheck((_employee['permission'])??[], type);
        return Icon(value ? Icons.check_box : Icons.check_box_outline_blank, color: value ? StyleCustom.primaryColor : Colors.grey, size: 64.sp);
      }))
    ], mainAxisAlignment: align));

  bool _isCheck(dynamic per, String type) {
    bool value = false;
    if (per.length == 1) value = per[0] == type;
    else if (per.length == 2) {
      value = per[0] == type;
      if (!value) value = per[1] == type;
    }
    return value;
  }

  void _dialogInfoEmployee({String title = 'Thêm nhân viên'}) {
    _ctrPhone.text = _employee['user_phone']??'';
    showDialog(context: context, builder: (_) {
      final color = const Color(0XFFF5F6F8);
      final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);
      return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.sp))),
          child: Column(children: [
            Container(width: 1.sw, decoration: BoxDecoration(color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.sp), topRight: Radius.circular(30.sp))),
                child: Padding(padding: EdgeInsets.all(40.sp), child: Stack(children: [
                  Align(alignment: Alignment.topRight, child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: const Icon(Icons.close, color: Color(0xFF626262)))),
                  Center(child: LabelCustom(title, color: const Color(0xFF191919), size: 60.sp))
                ]))),

            Padding(padding: EdgeInsets.all(40.sp), child: Column(children: [
              Row(children: [_title('Số ĐT'), require]),
              Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                  child: TextFieldCustom(_ctrPhone, _fcPhone, null, 'Nhập số ĐT của nhân viên',
                      readOnly: _employee.containsKey('user_phone'),
                      size: 42.sp, color: color, borderColor: color, type: TextInputType.phone)),

              Row(children: [
                _title('Nhận thông báo '),
                ButtonImageWidget(0, () {
                  int value = (_employee['notification']??0).toInt();
                  value == 0 ? value++ : value = 0;
                  _employee.update('notification', (v) => value, ifAbsent: () => value);
                  bloc!.add(CheckNoticeEvent(value));
                }, BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is CheckNoticeState, builder: (context, state) {
                  int value = (_employee['notification']??0).toInt();
                  return Icon(value == 1 ? Icons.check_box : Icons.check_box_outline_blank, color: value == 1 ? StyleCustom.primaryColor : Colors.grey, size: 64.sp);
                }))
              ]),

              Padding(padding: EdgeInsets.symmetric(vertical: 40.sp), child: Row(children: [
                _title('Truy cập: '),
                _permissionEdit('Sản phẩm '),
                _permissionEdit('Đơn hàng ', type: 'invoice_users', align: MainAxisAlignment.end)
              ])),

              Row(children: [
                if (title != 'Thêm nhân viên') Expanded(child: ButtonImageWidget(16.sp, _removeEmployee,
                  Container(padding: EdgeInsets.all(20.sp), child: LabelCustom('Xoá NV', color: Colors.white, size: 48.sp,
                    weight: FontWeight.normal, align: TextAlign.center)), color: Colors.black26)),
                if (title != 'Thêm nhân viên') SizedBox(width: 20.sp),
                Expanded(child: ButtonImageWidget(16.sp, _saveEmployee,
                  Container(padding: EdgeInsets.all(20.sp), child: LabelCustom('Lưu', color: Colors.white, size: 48.sp,
                    weight: FontWeight.normal, align: TextAlign.center)), color: StyleCustom.primaryColor))
              ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
            ], crossAxisAlignment: CrossAxisAlignment.start))
          ], mainAxisSize: MainAxisSize.min)
      );
    });
  }

  void _selectEmployee(int index) {
    if ((_list[index]['regency']??'') == 'owner') return;
    _employee.clear();
    _employee.addAll(_list[index]);
    _dialogInfoEmployee(title: 'Cập nhật thông tin');
  }

  void _saveEmployee() {
    clearFocus();
    if (_ctrPhone.text.isEmpty) {
      UtilUI.showCustomDialog(context, 'Nhập số ĐT của nhân viên').whenComplete(() => _fcPhone.requestFocus());
      return;
    }
    _employee.update('phone', (value) => _ctrPhone.text, ifAbsent: () => _ctrPhone.text);
    bloc!.add(EditEvent(_employee, idBusiness));
    UtilUI.goBack(context, true);
  }

  void _removeEmployee() {
    clearFocus();
    UtilUI.showCustomDialog(context, 'Bạn có chắc muốn gỡ bỏ nhân viên này ra khỏi doanh nghiệp không?',
      isActionCancel: true).then((value) {
        if (value != null && value) {
          bloc!.add(DeleteEmpEvent(idBusiness, _employee['id']));
          UtilUI.goBack(context, true);
        }
      });
  }

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _search() {
    clearFocus();
    _reset();
  }

  void _clear() {
    clearFocus();
    _ctrSearch.text = '';
    bloc!.add(ShowClearSearchEvent(false));
    _reset();
  }

  void _loadMore() {
    if (_lock) return;
    _lock = true;
    bloc!.add(LoadListEvent(_page, keyword: _ctrSearch.text, idBA: idBusiness));
  }

  void _reset() {
    setState(() {_list.clear();});
    _page = 1;
    _loadMore();
  }
}