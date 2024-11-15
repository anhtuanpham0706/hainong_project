import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hainong/common/count_down_bloc.dart';
import 'package:hainong/features/main2/ui/main2_item.dart';
import '../base_bloc.dart';
import '../database_helper.dart';
import '../util/util_ui.dart';
import 'image_network_asset.dart';
import 'import_lib_base_ui.dart';

class Banner2Nong extends StatefulWidget {
  final String pos, loc;
  const Banner2Nong(this.pos, {this.loc = '', Key? key}) : super(key: key);
  @override
  _BannerState createState() => _BannerState();
}

class _BannerState extends State<Banner2Nong> {
  final CountDownBloc _bloc = CountDownBloc(hasBanner: true);
  dynamic _banner;
  bool? _isClose;

  @override
  void dispose() {
    _stopView();
    _bloc.close();
    _banner = null;
    super.dispose();
  }

  @override
  void initState() {
    _bloc.stream.listen((state) {
      if (state is GetBannerState && _isClose == null) {
        _stopView();
        _banner = state.resp;
      }
    });
    super.initState();
    _bloc.add(GetBannerEvent(widget.pos, widget.loc));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder(bloc: _bloc,
      buildWhen: (oldS, newS) => newS is GetBannerState || newS is CountDownState,
      builder: (context, state) {
        if (_banner == null) return const SizedBox();
        return Stack(children: [
          GestureDetector(onTap: _openDetail,
              child: ImageNetworkAsset(path: _banner['image']??'', width: 1.sw, height: widget.loc != 'top' ? 142.sp : 200.sp)),
          GestureDetector(onTap: _close,
              child: Container(padding: const EdgeInsets.all(5), margin: EdgeInsets.only(right: 5, bottom: widget.loc != 'top' ? 142.sp - 46.sp + 2.5 : 0, top: widget.loc == 'top' ? 200.sp - 46.sp + 2.5 : 0),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(50)),
                child: Icon(Icons.close, color: Colors.white, size: 46.sp),
              ))
        ], alignment: widget.loc == 'top' ? Alignment.topRight : Alignment.bottomRight);
      }
  );

  void _close() {
    _isClose = true;
    _stopView();
    _banner = null;
    _bloc.add(CountDownEvent());
  }

  void _openDetail() {
    if ((_banner['description']??'').isNotEmpty) {
      UtilUI.goToNextPage(context, PopupDetail(_banner['name']??'', _banner['description']??'', _banner['image']??''));
    }
  }

  void _stopView() async {
    if (_banner != null) await DBHelper().updateHelper('id', _banner['id'], values: {'is_view': 1}, tblName: 'banner');
  }
}