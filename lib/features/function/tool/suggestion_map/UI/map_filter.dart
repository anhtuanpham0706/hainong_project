import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/icon_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/function/info_news/market_price/ui/market_price_page.dart';
import '../mappage_block.dart';

class MapFilterPage extends StatefulWidget {
  final List<ItemModel> currentKinds;
  final ItemModel currentProvince;
  final String fromDate, toDate;

  const MapFilterPage(this.currentKinds, this.currentProvince, this.fromDate, this.toDate, {Key? key}) : super(key: key);

  @override
  _MapFilterState createState() => _MapFilterState();
}

class _MapFilterState extends State<MapFilterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ctrFromDate = TextEditingController();
  final TextEditingController _ctrToDate = TextEditingController();
  final FocusNode _fcFromDate = FocusNode();
  final FocusNode _fcToDate = FocusNode();
  final Map<String, ItemModel> _kinds = {'-1': ItemModel(id: '-1', name: 'Tất cả')};
  final Map<String, ItemModel> _provinces = {'': ItemModel(name: 'Vị trí hiện tại')};
  String _currentProvince = '', _fromDate = '', _toDate = '';
  final MapPageBloc _bloc = MapPageBloc(MapState());
  int _currentPage = 0;

  @override
  void initState() {
    _bloc.stream.listen((state) {
      if (state is LoadDiagnostics2State) {
        _kinds.addAll(state.map);
        if (widget.currentKinds.isNotEmpty) {
          widget.currentKinds.forEach((ele) {
            if (_kinds.containsKey(ele.id)) _kinds[ele.id]!.selected = true;
          });
        } else {
          _kinds.forEach((key, value) {
            value.selected = true;
          });
        }
        _bloc.add(ChangeDiagnosticEvent());
      } else if (state is LoadProvincesState) {
        _provinces.addAll(state.map);
        _changeProvince(widget.currentProvince.id, compare: false);
      }
    });
    _bloc.add(LoadDiagnostics2Event());
    _bloc.add(LoadProvincesEvent());
    super.initState();
    if (widget.fromDate.isNotEmpty) {
      _setFromDay(Util.stringToDateTime(widget.fromDate, pattern: 'dd/MM/yyyy', locale: Constants().localeVI));
    }
    if (widget.toDate.isNotEmpty) {
      _setToDay(Util.stringToDateTime(widget.toDate, pattern: 'dd/MM/yyyy', locale: Constants().localeVI));
    }
  }

  @override
  void dispose() {
    _ctrFromDate.dispose();
    _ctrToDate.dispose();
    _fcFromDate.dispose();
    _fcToDate.dispose();
    _kinds.clear();
    _provinces.clear();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true, title: UtilUI.createLabel('Lọc sâu bệnh')),
    backgroundColor: Colors.white,
    body: Column(children: [
      Container(color: StyleCustom.primaryColor, child: BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is ChangePageState,
          builder: (context, state) {
            return Row(children: [
              TabItem('Loại bệnh', 0, _currentPage == 0, _changeTabIndex),
              TabItem('Khu vực', 1, _currentPage == 1, _changeTabIndex),
              TabItem('Thời gian', 2, _currentPage == 2, _changeTabIndex)
            ]);
          })),
      Expanded(child: BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is ChangePageState,
          builder: (context, state) {
            if (_currentPage == 1) { return BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is ChangeProvinceState,
                builder: (context, state) => ListView.builder(itemBuilder: (context, index) {
                  final ItemModel item = _provinces.values.elementAt(index);
                  return RadioListTile(
                      activeColor: StyleCustom.primaryColor,
                      value: item.id,
                      groupValue: _currentProvince,
                      onChanged: (ind) {
                        if (ind != null) _changeProvince(ind.toString());
                      },
                      title: Text(item.name));
                }, itemCount: _provinces.length, padding: EdgeInsets.zero));}
            if (_currentPage == 2) return Padding(padding: EdgeInsets.all(40.sp), child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(child: UtilUI.createTextField(
                  context, _ctrFromDate, _fcFromDate, _fcToDate,
                  "Từ ngày", readOnly: true,
                  suffixIcon: const IconWidget(assetPath: 'assets/images/ic_calendar.png'),
                  onPressIcon: () => _selectFromDay())),
              SizedBox(width: 30.sp),
              Expanded(child: UtilUI.createTextField(
                  context, _ctrToDate, _fcToDate, _fcFromDate,
                  "Đến ngày", readOnly: true,
                  suffixIcon: const IconWidget(assetPath: 'assets/images/ic_calendar.png'),
                  onPressIcon: () => _selectToDay()))
            ]));
            return BlocBuilder(bloc: _bloc, buildWhen: (oldS, newS) => newS is ChangeDiagnosticState,
                builder: (context, state) => ListView.builder(itemBuilder: (context, index) {
                  final ItemModel item = _kinds.values.elementAt(index);
                  return CheckboxListTile(
                      activeColor: StyleCustom.primaryColor,
                      title: Text(item.name),
                      value: item.selected,
                      onChanged: (bool? value) => _changeKind(item.id)
                  );
                }, itemCount: _kinds.length)
            );
          }
      )),
      Container(padding: EdgeInsets.all(40.sp), child: Row(children: [
        Expanded(child: OutlinedButton(onPressed: () {
            _applyFilter(context);
            Util.trackActivities('', path: 'Map Filter Screen -> Apply Filter select');
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.transparent),
            backgroundColor: StyleCustom.primaryColor),
          child: const Text('Áp dụng', style: TextStyle(fontSize: 16, color: Colors.white)))),
        Expanded(child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.transparent)),
                      onPressed: () {
                        _resetValues();
                        Util.trackActivities('', path: 'Map Filter Screen -> Clear Filter select');
                      },
                      child: const Text('Thiết lập lại', style: TextStyle(fontSize: 16))))
      ]), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF5F5F5)))))
  ]));

  void _changeTabIndex(int index) {
    _changePage(index);
    String type = 'for kind of pest';
    switch(index) {
      case 1: type = 'by region'; break;
      case 2: type = 'by time';
    }
    Util.trackActivities('', path: 'Map filter Screen -> Open Filter $type');
  }

  void _selectFromDay() {
    try {
      DatePicker.showDatePicker(context,
          minTime: DateTime.now().add(const Duration(days: -365)),
          maxTime: _toDate.isEmpty ? DateTime.now() : Util.stringToDateTime(_toDate, pattern: 'dd/MM/yyyy'),
          showTitleActions: true,
          onConfirm: (DateTime date) => _setFromDay(date),
          currentTime: _fromDate.isEmpty ? DateTime.now() : Util.stringToDateTime(_fromDate, pattern: 'dd/MM/yyyy'),
          locale: LocaleType.vi);
    } catch (_) {}
  }

  void _selectToDay() {
    try {
      DatePicker.showDatePicker(context,
          minTime: _fromDate.isEmpty ? DateTime.now().add(const Duration(days: -365)) : Util.stringToDateTime(_fromDate, pattern: 'dd/MM/yyyy'),
          maxTime: DateTime.now(),
          showTitleActions: true,
          onConfirm: (DateTime date) => _setToDay(date),
          currentTime: _toDate.isEmpty ? DateTime.now() : Util.stringToDateTime(_toDate, pattern: 'dd/MM/yyyy'),
          locale: LocaleType.vi);
    } catch (_) {}
  }

  void _setFromDay(DateTime date) {
    _ctrFromDate.text = Util.dateToString(date, pattern: "dd/MM/yyyy");
    _fromDate = _ctrFromDate.text;
  }

  void _setToDay(DateTime date) {
    _ctrToDate.text = Util.dateToString(date, pattern: "dd/MM/yyyy");
    _toDate = _ctrToDate.text;
  }

  void _changeKind(String kind) {
    if (!_kinds.containsKey(kind)) return;
    _kinds[kind]!.selected = !_kinds[kind]!.selected;
    int count = 0;
    _kinds.forEach((key, value) {
      if (kind == '-1') _kinds[key]!.selected = _kinds['-1']!.selected;
      if (_kinds[key]!.selected) count++;
    });
    if (_kinds['-1']!.selected) count--;
    if (count == _kinds.length - 1) _kinds['-1']!.selected = true;
    else if (kind != '-1') _kinds['-1']!.selected = false;
    _bloc.add(ChangeDiagnosticEvent());
  }

  void _changeProvince(String province, {bool compare = true}) {
    if (compare && _currentProvince == province) return;
    if (_provinces.containsKey(_currentProvince)) _provinces[_currentProvince]!.selected = false;
    if (_provinces.containsKey(province)) _provinces[province]!.selected = true;
    _currentProvince = province;
    _bloc.add(ChangeProvinceEvent());
  }

  void _applyFilter(BuildContext context) {
    final List<ItemModel> keys = [];
    if (!_kinds['-1']!.selected) { _kinds.forEach((key, value) {
      if (value.selected) keys.add(value);
    });}
    Navigator.pop(context, {
      'kinds': keys,
      'province': _provinces[_currentProvince],
      'from_date': _fromDate,
      'to_date': _toDate,
    });
  }

  void _resetValues() {
    setState(() {
      _kinds.forEach((key, ele) {
        _kinds[key]!.selected = true;
      });
      _bloc.add(ChangeDiagnosticEvent());
      _changeProvince('');
      _fromDate = '';
      _toDate = '';
      _ctrFromDate.text = '';
      _ctrToDate.text = '';
    });
  }

  void _changePage(int page) {
    if (_currentPage != page) {
      _currentPage = page;
      _bloc.add(ChangePageEvent());
    }
  }
}
