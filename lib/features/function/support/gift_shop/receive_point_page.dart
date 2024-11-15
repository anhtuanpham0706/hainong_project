import 'receive_point_model.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/ui_farm.dart';
import 'bloc/gift_bloc.dart';


class ReceivePointPage extends StatefulWidget {
  const ReceivePointPage({Key? key}) : super(key: key);

  @override
  State<ReceivePointPage> createState() => _ReceivePointPageState();
}

class _ReceivePointPageState extends State<ReceivePointPage> {
  List<ReceivePointModel> _list = [];
  final GiftBloc bloc = GiftBloc();

  @override
  void initState() {
    super.initState();
    bloc.stream.listen((state) {
      if(state is LoadReceivePointState){
        if(state.response.success) {
          _list.addAll(state.response.data.list);
        } else {
          UtilUI.showCustomDialog(context, 'Lỗi truyền tải dữ liệu');
        }
      }
    });
    bloc.add(LoadReceivePointEvent());
  }

  @override
  void dispose() {
    _list.clear();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleCustom.primaryColor,
        title: Text("Nhiệm vụ nhận điểm",style: TextStyle(color: Colors.white,fontSize: 50.sp),),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              FarmManageTitle( [["Tên nhiệm vụ", 4],  ['Số điểm thưởng', 2, TextAlign.center], ['Số lần áp dụng/ngày', 3, TextAlign.center],['Tiến độ', 2,TextAlign.center],],
                  size: 38.sp,
                  padding: 20.sp),
              Expanded(child: BlocBuilder(bloc: bloc,
                  buildWhen: (oldS, newS) => newS is LoadReceivePointState, builder: (context, state) =>
                      ListView.builder(padding: EdgeInsets.zero,
                          itemCount: _list.length,
                          itemBuilder: (context, index) => _item(index),
                          physics: const AlwaysScrollableScrollPhysics()))
              )
            ],
          ),
          Loading(bloc)
        ],
      ),
    );
  }

  Widget _item(int index) {
    return FarmManageItem([
      [_list[index].event_name.toString(), 4],
      [_list[index].point_give.toString(), 2, TextAlign.center],
      [_list[index].times_day.toString(), 3, TextAlign.center],
      [ _list[index].point_histories_count.toString() + '/' + _list[index].times_day.toString(), 2,TextAlign.center,  Colors.red],
    ], index, colorRow: (index % 2 != 0) ? Colors.transparent : const Color(0xFFF8F8F8), padding: 20.sp,size: 38.sp,);
  }
}
