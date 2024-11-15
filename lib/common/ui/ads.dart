import 'package:carousel_slider/carousel_slider.dart';
import 'package:hainong/common/count_down_bloc.dart';
import 'package:hainong/features/main2/ui/main2_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'image_network_asset.dart';
import 'import_lib_ui.dart';

class Ads extends StatefulWidget {
  final String type;
  final Function? fnReload;
  const Ads(this.type, {Key? key, this.fnReload}) :super(key: key);
  @override
  _AdsState createState() => _AdsState();
}

class _AdsState extends State<Ads> with AutomaticKeepAliveClientMixin {
  final CountDownBloc _bloc = CountDownBloc(hasAds: true);
  final List _data = [];
  int _index = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _bloc.close();
    _data.clear();
    super.dispose();
  }

  @override
  void initState() {
    _bloc.stream.listen((state) {
      if (state is CheckMemPackageState && state.resp != null && state.resp.isNotEmpty) {
        _data.addAll(state.resp);
        final reload = widget.fnReload;
        if (reload != null) reload();
      }
    });
    super.initState();
    _bloc.add(CheckMemPackageEvent(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      BlocBuilder(bloc: _bloc,
        buildWhen: (oldS, newS) => newS is CheckMemPackageState && _data.isNotEmpty,
        builder: (context, state) => _data.isEmpty ? const SizedBox() :
          CarouselSlider.builder(itemCount: _data.length,
              itemBuilder: (context, index, realIndex) => GestureDetector(onTap: _open,
                  child: ImageNetworkAsset(path: _data[index]['image'], width: 1.sw)),
              options: CarouselOptions(aspectRatio: 810.sp/282.sp,
                  viewportFraction: 1, initialPage: 0,
                  reverse: true, autoPlay: _data.length > 1, autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    _index = index;
                    _bloc.add(CountDownEvent(value: index));
                  }))
      ),
      _pointsUI(),
    ], alignment: Alignment.bottomCenter);
  }

  Widget _pointsUI() => Container(child: BlocBuilder(bloc: _bloc,
      buildWhen: (oldS, newS) => (newS is CheckMemPackageState || newS is CountDownState) && _data.isNotEmpty,
      builder: (context, state) {
        if (_data.length < 2) return const SizedBox();
        final List<Widget> list = [];
        for(int index = 0; index < _data.length; index ++) {
          list.add(Container(height: 8, width: _index == index ? 30 : 8,
              decoration: BoxDecoration(color: const Color(0xFF1B5E20).withOpacity(_index == index ? 0.8 : 0.5),
                  borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.symmetric(horizontal: 4)));
        }
        return Row(children: list, mainAxisAlignment: MainAxisAlignment.center);
      }), height: 8, margin: const EdgeInsets.only(bottom: 5));

  void _open() {
    String link = _data[_index]['connect_link']??'';
    if (link.isEmpty) {
      link = _data[_index]['description']??'';
      if (link.isNotEmpty) {
        UtilUI.goToNextPage(context, PopupDetail(_data[_index]['name']??'', link, _data[_index]['image']??''));
      }
      return;
    }
    link = Util.getRealPath(link);
    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }
}