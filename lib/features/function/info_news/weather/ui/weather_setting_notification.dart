import 'package:hainong/common/ui/box_dec_custom.dart';
import 'package:hainong/common/ui/empty_search.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import '../weather_bloc.dart';

class WeatherSettingPage extends BasePage {
  WeatherSettingPage() : super(key: null, pageState: _WeatherSettingPageState());
}

class _WeatherSettingPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final List<dynamic> _list = [];
  int _page = 1;

  @override
  void dispose() {
    _list.clear();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = WeatherBloc(type: 'setting');
    bloc!.stream.listen((state) {
      if (state is LoadListWeatherState) {
        if (isResponseNotError(state.response, showError: false)) {
          _list.addAll(state.response.data);
          state.response.data.length == 20 ? _page++ : _page = 0;
        } else _page = 0;
        if (_list.isEmpty) UtilUI.showCustomDialog(context, 'Dữ liệu không có hoặc bạn cần gia hạn/đăng ký gói cước để sử dụng tiếp tính năng này');
      } else if (state is LoadAudioWeatherState) {
        UtilUI.showCustomDialog(context, state.data);
      } else if (state is GetLatLonAddressState) {
        _list[int.parse(state.lon)]['status'] = state.response.data['status'];
      }
    });
    super.initState();
    _loadMore();
    _scroller.addListener(_listenScroller);
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(
      backgroundColor: color,
      appBar: AppBar(elevation: 5, centerTitle: true,
          title: UtilUI.createLabel('Cài đặt thông báo thời tiết', textAlign: TextAlign.center)),
      body: Stack(children: [
        BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadListWeatherState,
          builder: (context, state) {
            if (state is LoadListWeatherState && _list.isEmpty) {
              return SizedBox(width: 1.sw, child: const EmptySearch('', title: 'Không có dữ liệu'));
            }
            return Column(children: [
              Padding(padding: EdgeInsets.fromLTRB(40.sp, 40.sp, 40.sp, 0),
                child: LabelCustom('* Ấn chọn để nhận thông báo thời tiết theo loại mà bạn mong muốn', color: Colors.black54, size: 40.sp, weight: FontWeight.w400)),
              Expanded(child: RefreshIndicator(child:
              ListView.separated(controller: _scroller, itemCount: _list.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (_,__) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return Container(padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 20.sp),
                        decoration: BoxDecCustom(radius: 5),
                        child: Row(children: [
                          Expanded(child: LabelCustom(_list[index]['title']??'', color: Colors.black87, size: 42.sp, weight: FontWeight.w400)),
                          BlocBuilder(bloc: bloc,
                              buildWhen: (oldStt, newStt) => newStt is GetLatLonAddressState,
                              builder: (context, state) => Switch(
                                  activeColor: Colors.green,
                                  value: _list[index]['status'] == 'sent',
                                  onChanged: (value) => _changeStatus(value, index)))
                        ])
                    );
                  }, padding: EdgeInsets.all(40.sp)),
                  onRefresh: () async => _loadMore(reload: true)))
            ]);
          }),
        Loading(bloc)
      ], alignment: Alignment.center));

  void _listenScroller() {
    if (_scroller.position.maxScrollExtent == _scroller.position.pixels && _page > 0) _loadMore();
  }

  void _loadMore({bool reload = false}) {
    if (reload) {
      _page = 1;
      _list.clear();
    }
    bloc!.add(LoadListWeatherEvent(page: _page));
  }

  void _changeStatus(bool value, int index) => bloc!.add(LoadAudioWeatherEvent(_list[index]['id'].toString(), index.toString(), isRequest: value));
}