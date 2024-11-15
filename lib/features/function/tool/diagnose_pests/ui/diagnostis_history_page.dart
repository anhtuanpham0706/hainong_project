import 'package:geolocator/geolocator.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/core_button_custom.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/features/function/tool/suggestion_map/UI/map_page.dart';
import '../model/diagnostic_history_model.dart';
import '../diagnose_pests_bloc.dart';
import 'diagnostic_history_item.dart';

class DiagnosisHistoryPage extends BasePage {
  DiagnosisHistoryPage({Key? key}) : super(key: key, pageState: _DiagnosisHistoryPageState());
}

class _DiagnosisHistoryPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List<DiagnosticHistoryModel> _list = [];
  final List<ItemModel> _diagnostics = [];
  final List<ItemModel> _listPlant = [];

  ItemModel _plantSelected = ItemModel();
  ItemModel _diagnosticSelected = ItemModel();
  int _page = 1;

  @override
  void dispose() {
    _list.clear();
    _diagnostics.clear();
    _listPlant.clear();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = DiagnosePestsBloc(const DiagnosePestsState());

    bloc!.stream.listen((state) {
      if(state is LoadListPlantState){
        _listPlant.clear();
        _listPlant.add(ItemModel(id: '', name: MultiLanguage.get('lbl_all_diagnostic')));
        _listPlant.addAll(state.list);
      }
      else if(state is LoadDiagnosticState){
        //make new list dianostics
        _diagnostics.clear();
        _diagnostics.add(ItemModel(id: '', name: MultiLanguage.get('lbl_all_diagnostic')));
        _diagnostics.addAll(state.list);
      }
      else if(state is FillTerByPlantState){
      //make new _diagnosticSelected
      _diagnosticSelected  = ItemModel();
      bloc!.add(LoadDiagnosticEvent(_plantSelected.id));
      _resetList();
      }
      else if(state is FillTerByPestState){
      _resetList();
      }
      });
    super.initState();
    bloc!.add(LoadDiagnosticEvent(''));
    bloc!.add(LoadListPlantEvent());
    _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget createUI() => Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
          titleSpacing: 0,
          /*actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.map,
                color: Colors.white,
              ),
              onPressed: () => _pushToMap(),
            )
          ],*/
          title: UtilUI.createLabel('Lịch sử chẩn đoán'),
          elevation: 0,
          centerTitle: true),
      body: Column(children: [
        Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: CoreButtonCustom(
                      () {_selectPlant();},
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                    child: Row(
                      children: [
                        Expanded(
                          child: BlocBuilder(
                              bloc: bloc,
                              buildWhen: (olds, news)=> news is FillTerByPlantState,
                              builder: (context, state){
                                return Padding(
                                  child: LabelCustom(
                                      _plantSelected.name.isNotEmpty?_plantSelected.name:
                                      'Loại cây',
                                      size: 40.sp,
                                      color: const Color(0xFF494747),
                                      weight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                      line: 1),
                                  padding: EdgeInsets.symmetric(vertical: 4.sp),
                                );
                              },),
                        ),
                        SizedBox(
                          width: 16.sp,
                        ),
                        Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 2.sp),
                height: 60.sp,
                width: 4.sp,
                color: Colors.grey,
              ),
              Expanded(
                child:
                BlocBuilder(
                    bloc: bloc,
                    buildWhen: (oldS, newS) => newS is LoadDiagnosticState || newS is FillTerByPlantState || newS is FillTerByPestState ,
                    builder: (context, state) => _plantSelected.id =='' || _plantSelected.id =='-1'?    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                            Padding(
                              child: LabelCustom(
                                  'Loại sâu bệnh',
                                  size: 40.sp,
                                  color:  Colors.grey.withOpacity(0.3),
                                  weight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                  line: 1),
                              padding: EdgeInsets.symmetric(vertical: 4.sp),
                            ),
                          ),
                          SizedBox(
                            width: 16.sp,
                          ),
                          Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                        ],
                      ),
                    ):  CoreButtonCustom(
                          () {_selectDiagnostic();},
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                              Padding(
                                child: LabelCustom(
                                    _diagnosticSelected.name.isNotEmpty?_diagnosticSelected.name :'Loại sâu bệnh',
                                    size: 40.sp,
                                    color: const Color(0xFF494747),
                                    weight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    line: 1),
                                padding: EdgeInsets.symmetric(vertical: 4.sp),
                              ),

                            ),
                            SizedBox(
                              width: 16.sp,
                            ),
                            Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                          ],
                        ),
                      ),
                    ),
                ),

              ),
            ],
          ),
        ),
        Expanded(
            child: BlocConsumer(
                bloc: bloc,
                listener: (context, state) {
                  if (state is LoadDiagnosticHistoryState && isResponseNotError(state.response))
                    _handleLoadHistory(state.response.data.list);
                },
                buildWhen: (oldState, newState) => newState is LoadDiagnosticHistoryState,
                builder: (context, state) => ListView.builder(
                    controller: _scroller,
                    itemCount: _list.length,
                    itemBuilder: (context, index) => DiagnosticHistoryItem(_list[index]))))
      ]));

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _resetList() {
    _page = 1;
    _list.clear();
    _loadMore();
  }

  void _loadMore() => bloc!.add(LoadDiagnosticHistoryEvent(_page,plantId: _plantSelected.id, diagnosticId: _diagnosticSelected.id));

  void _handleLoadHistory(List<DiagnosticHistoryModel> list) {
    if (list.isNotEmpty) {
      _list.addAll(list);
      if (list.length == constants.limitPage)
        _page++;
      else
        _page = 0;
    } else
      _page = 0;
  }

  void _selectPlant(){
    UtilUI.showOptionDialog(context, 'Loại cây', _listPlant, _plantSelected.id)
        .then((value) {
      if (value != null && (value as ItemModel).id != _plantSelected.id) {
        _plantSelected = value;
       bloc!.add(FillTerByPlantEvent());
        Util.trackActivities('pest_diagnosis_history', path: 'DiagnosisHistoryPage -> Choose List ${_plantSelected.name}');
      }
    });

  }

  void _selectDiagnostic(){
    if(_diagnostics.isEmpty) return;
    UtilUI.showOptionDialog(context, 'Loại sâu bệnh', _diagnostics, _diagnosticSelected.id)
        .then((value) {
      if (value != null && (value as ItemModel).id != _diagnosticSelected.id) {
        _diagnosticSelected = value;
        bloc!.add(FillTerByPestEvent());
        Util.trackActivities('pest_diagnosis_history', path: 'DiagnosisHistoryPage -> Choose List ${_diagnosticSelected.name}');
      }
    });
  }

  Widget _lineInfo(String title, Widget widget) => Container(
      padding: EdgeInsets.only(bottom: 16.sp),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF787878),
                fontSize: 40.sp,
              ),
            ),
          ),
          SizedBox(
            height: 8.sp,
          ),
          widget,
        ],
      ));

  Future<void> _pushToMap() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return Future.error(MultiLanguage.get('msg_gps_deny_forever'));
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always)
        return Future.error(MultiLanguage.get('msg_gps_denied'));
    }
    UtilUI.goToNextPage(context, const MapPage());
    Util.trackActivities('pest_diagnosis_history', path: 'Open Pests Map');
  }
}
