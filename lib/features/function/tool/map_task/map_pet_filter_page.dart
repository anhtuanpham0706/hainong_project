import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/function/tool/map_task/components/tree_view_widget.dart';
import 'package:hainong/features/function/tool/map_task/map_task_bloc.dart';
import 'package:hainong/features/function/tool/map_task/utils/dialog_utils.dart';
import 'package:hainong/features/function/tool/map_task/utils/map_utils.dart';
import 'models/map_item_model.dart';

class MapPetFilterPage extends StatefulWidget {
  final List<String> petIds;
  final ItemModel province;
  final DateTime? fromDate, toDate;

  const MapPetFilterPage(this.petIds, this.province, this.fromDate, this.toDate, {Key? key}) : super(key: key);

  @override
  _MapPetFilterState createState() => _MapPetFilterState();
}

class _MapPetFilterState extends State<MapPetFilterPage> with SingleTickerProviderStateMixin {
  final TextEditingController _ctrFromDate = TextEditingController();
  final TextEditingController _ctrToDate = TextEditingController();
  final FocusNode _fcFromDate = FocusNode();
  final FocusNode _fcToDate = FocusNode();
  // final Map<String, ItemModel> _kinds = {'-1': ItemModel(id: '-1', name: 'Tất cả')};
  // final Map<String, ItemModel> _provinces = {'': ItemModel(name: 'Vị trí hiện tại')};
  final MapTaskBloc _bloc = MapTaskBloc();
  List<TreePetModel> treeCategorys = [];
  List<String> petIdsSelect = [];
  ItemModel? _currentProvince;
  DateTime? _fromDate;
  DateTime? _toDate;
  final ValueNotifier<List<ItemModel>> _provincesNotifier = ValueNotifier([]);
  List<DateTime?> dialogCalendarPickerValue = [];

  @override
  void initState() {
    petIdsSelect = widget.petIds;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    _currentProvince = widget.province;
    dialogCalendarPickerValue.add(widget.fromDate);
    dialogCalendarPickerValue.add(widget.toDate);
    _bloc.stream.listen((state) {
      if (state is LoadCategorysFilterState) {
        setState(() => treeCategorys.add(TreePetModel("Tất cả", state.list)));
      } else if (state is LoadProvincesState) {
        final data = state.data;
        final item = ItemModel(id: "-1", name: "Tất cả", selected: _currentProvince?.id.isNotEmpty == true ? false : true);
        data.insert(0, item);
        _provincesNotifier.value = List.from(data);
      }
    });
    _bloc.add(LoadCategorysEvent());
    _bloc.add(LoadProvincesEvent());
    super.initState();
  }

  @override
  void dispose() {
    _ctrFromDate.dispose();
    _ctrToDate.dispose();
    _fcFromDate.dispose();
    _fcToDate.dispose();
    // _kinds.clear();
    // _provinces.clear();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => closeFilterPage(),
        ),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: UtilUI.createLabel('Lọc sâu bệnh'),
        actions: [
          GestureDetector(
            onTap: () => closeFilterPage(),
            child: Container(
                height: 62.h,
                margin: EdgeInsets.symmetric(vertical: 32.sp, horizontal: 20.sp),
                padding: EdgeInsets.symmetric(vertical: 6.sp, horizontal: 20.sp),
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.sp), color: Colors.white),
                child: const Text("Áp dụng", textAlign: TextAlign.end, style: TextStyle(color: Color(0xFFFFAC26), fontSize: 14, fontWeight: FontWeight.bold))),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(children: [
        Container(
            margin: EdgeInsets.symmetric(horizontal: 26.sp, vertical: 12.sp),
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 32.sp),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.sp),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))]),
            child: Row(children: [
              GestureDetector(
                onTap: () => DialogUtils.showDialogPopup(context, provinceListWidget(), isDismiss: true),
                child: Row(children: [
                  const Icon(Icons.location_on_outlined, color: Colors.green, size: 32),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.sp),
                      child: Text((_currentProvince != null && _currentProvince?.name != "") ? _currentProvince?.name ?? "" : "Tất cả vị trí",
                          style: const TextStyle(color: Colors.black87, fontSize: 15))),
                ]),
              ),
              const SizedBox(height: 32, child: VerticalDivider(color: Colors.grey, width: 20, thickness: 1)),
              GestureDetector(
                onTap: () => calendarRangerSelect(),
                child: Row(children: [
                  const Icon(Icons.calendar_month, color: Colors.green, size: 32),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 6.sp), child: Text(showDateSelect(), style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)))
                ]),
              )
            ])),
        Expanded(
            child: TreeView(
          onChanged: (newNodes) {
            petIdsSelect.clear();
            for (TreeNode root in newNodes) {
              for (TreeNode children in root.children) {
                for (TreeNode item in children.children) {
                  if (item.isSelected) {
                    petIdsSelect.add(item.item.id);
                  }
                }
              }
            }
            logDebug("=====>${petIdsSelect.join(",")}");
          },
          nodes: treeAllWidget(treeCategorys),
        ))
      ]));

  void closeFilterPage() {
    Navigator.pop(context, {
      'petIds': petIdsSelect,
      'province': _currentProvince,
      'from_date': _fromDate,
      'to_date': _toDate,
    });
  }

  Widget provinceListWidget() {
    return ValueListenableBuilder<List<ItemModel>>(
        valueListenable: _provincesNotifier,
        builder: (context, provinceList, child) {
          if (provinceList.isNotEmpty) {
            return SizedBox(
              height: 1.sh / 1.2,
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF0D986F),
                    height: 120.h,
                    width: 1.sw,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(12.sp), topRight: Radius.circular(12.sp))),
                            child: const Text(
                              "Thiết lập vị trí",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            )),
                        const SizedBox()
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return RadioListTile(
                              activeColor: StyleCustom.primaryColor,
                              value: provinceList[index].id,
                              groupValue: _currentProvince?.id,
                              onChanged: (value) {
                                if (value != null) _changeProvince(provinceList[index]);
                              },
                              title: Text(provinceList[index].name));
                        },
                        itemCount: provinceList.length,
                        padding: EdgeInsets.zero),
                  ),
                ],
              ),
            );
          }
          return Container();
        });
  }

  Future<void> calendarRangerSelect() async {
    const dayTextStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarViewScrollPhysics: const NeverScrollableScrollPhysics(),
      dayTextStyle: dayTextStyle,
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: Colors.green[800],
      closeDialogOnCancelTapped: true,
      weekdayLabelTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      controlsTextStyle: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
      allowSameValueSelection: true,
      selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white),
      buttonPadding: EdgeInsets.symmetric(horizontal: 120.sp),
      closeDialogOnOkTapped: true,
      cancelButton: const Text("Cancel", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
      okButton: const Text("Accept", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFAC26), fontWeight: FontWeight.bold, fontSize: 16)),
    );
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 420),
      borderRadius: BorderRadius.circular(15),
      value: dialogCalendarPickerValue,
      dialogBackgroundColor: Colors.white,
    );
    if (values != null) {
      setState(() {
        dialogCalendarPickerValue = values;
        _fromDate = dialogCalendarPickerValue.first;
        _toDate = dialogCalendarPickerValue.last;
      });
    }
  }

  String showDateSelect() => _fromDate != null && _toDate != null ? MapUtils.getFormattedDateRange(_fromDate, _toDate) : "Chọn thời gian";

  void _changeProvince(ItemModel province) {
    if (_currentProvince?.id == province.id) return;
    setState(() => _currentProvince = province);
    List<ItemModel> updatedList = _provincesNotifier.value.map((item) {
      item.selected = item.id == province.id;
      return item;
    }).toList();
    _provincesNotifier.value = updatedList;
    Navigator.of(context).pop();
  }

  List<TreeNode> treeAllWidget(List<TreePetModel> items) {
    List<TreeNode> currentItemList = [];
    for (TreePetModel item in items) {
      currentItemList.add(TreeNode(
        item: PetModel(id: item.name, name: item.name),
        children: treeItemsWidget(item.children),
      ));
    }
    return currentItemList;
  }

  List<TreeNode> treeItemsWidget(List<TreeModel> items) {
    List<TreeNode> currentItemList = [];
    for (TreeModel item in items) {
      currentItemList.add(TreeNode(
        item: PetModel(id: item.id, name: item.name, image: item.icon),
        children: petItemsWidget(item.diagnostics),
      ));
    }
    return currentItemList;
  }

  List<TreeNode> petItemsWidget(List<PetModel> items) {
    List<TreeNode> currentItemList = [];
    for (PetModel item in items) {
      bool isSelect = petIdsSelect.contains(item.id) ? true : false;
      currentItemList.add(TreeNode(item: PetModel(id: item.id, name: item.name, image: "assets/images/v9/map/ic_line_circle.png"), isSelected: isSelect));
    }
    return currentItemList;
  }
}
