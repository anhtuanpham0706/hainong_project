import 'dart:async';
import 'package:hainong/common/ui/image_network_asset.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advn_video/advn_video.dart';
import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'video_bloc.dart';
import 'video_list_page.dart';

class Button extends StatelessWidget {
  final String asset, title;
  final Function funAction;
  final int num;
  final IconData? icon;
  final Color color;
  const Button(this.asset, this.funAction, this.num, this.title, {this.icon, this.color = Colors.white, Key? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    String title = Util().formatNum2(num.toDouble(), digit: 1);
    if (title.isEmpty) title = this.title;
    return GestureDetector(onTap: () => funAction(), child: Column(children: [
      icon == null ? Image.asset(asset, height: 80.sp, width: 80.sp, color: color) :
      Icon(icon, color: color, size: 80.sp),
      SizedBox(height: 10.sp),
      LabelCustom(title, size: 30.sp, weight: FontWeight.w400)
    ]));
  }
}

class Item extends StatefulWidget {
  final dynamic item;
  final int index;
  final VideoBloc bloc;
  const Item(this.item, this.index, this.bloc, {Key? key}) : super(key: key);
  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> with AutomaticKeepAliveClientMixin {
  String _type = '';
  final BaseBloc _bloc = BaseBloc(init: const BaseState(isShowLoading: true));

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.item['media_type'] != 'youtube') {
      _type = 'video';
    } else {
      final String? id = YoutubePlayer.convertUrlToId(widget.item['video_url']);
      if (id != null) _type = id;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(height: 1.sh, width: 1.sw, child: Stack(children: [
      _Video(widget.item['id'], widget.index, widget.item['video_url'], _type, widget.bloc, _bloc),
      Padding(padding: EdgeInsets.fromLTRB(40.sp, 100, 240.sp, WidgetsBinding.instance.window.padding.bottom.sp + 40.sp),
          child: Column(children: [
            Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(200),
                  child: Image.asset('assets/images/bg_splash.png', width: 100.sp, height: 100.sp, fit: BoxFit.cover)),
              LabelCustom(' 2Nông', size: 40.sp)
            ]),
            SizedBox(height: 20.sp),
            if ((widget.item['title']??'').isNotEmpty) LabelCustom(widget.item['title'], size: 40.sp, weight: FontWeight.w500),
            SizedBox(height: 20.sp),
            if ((widget.item['description']??'').isNotEmpty) LabelCustom(widget.item['description'], size: 34.sp, weight: FontWeight.w400),
            SizedBox(height: 20.sp),
            _hashTagUI(widget.item['tags'])
          ], crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end))
    ], alignment: Alignment.center));
  }

  Widget _hashTagUI(dynamic tags) {
    if (tags == null || tags.isEmpty) return const SizedBox();
    final List<Widget> list = [];
    for (var item in tags) {
      list.add(GestureDetector(onTap: () {
        if (widget.bloc.tag.isEmpty) {
          widget.bloc.play(id: 0);
          UtilUI.goToNextPage(context, VideoListPage(tag: item), funCallback: (value) => widget.bloc.play());
        } else UtilUI.goToPage(context, VideoListPage(tag: item), null);
      }, child: LabelCustom('#' + item, size: 36.sp, weight: FontWeight.bold)));
    }
    return Wrap(children: list, spacing: 20.sp, runSpacing: 20.sp);
  }
}

class _Video extends StatefulWidget {
  final int id, index;
  final String url, type;
  final VideoBloc bloc;
  final BaseBloc subBloc;
  const _Video(this.id, this.index, this.url, this.type, this.bloc, this.subBloc, {Key? key}):super(key: key);
  @override
  _VideoState createState() => _VideoState();
}
class _VideoState extends State<_Video> {
  dynamic ctrVideo, ctrYTB, ctrYTBCmt, firstImage;
  Widget? _ytb, _ytbCmt, _thumbnail;
  bool _isShort = false, _isPlay = false, _isInitVideo = true;
  late StreamSubscription _stream;

  @override
  void dispose() {
    if (ctrVideo != null) {
      ctrVideo.pause();
      ctrVideo.dispose();
    }
    if (ctrYTB != null) {
      _timeYTB?.cancel();
      _timeYTB = null;
      ctrYTB.pause();
      ctrYTB.removeListener(_listenerYTB);
      ctrYTB.dispose();
      ctrYTBCmt.removeListener(_listenerYTB);
      ctrYTBCmt.dispose();
    }
    _stream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _stream = widget.bloc.stream.listen((state) {
      if (state is SetHeightState) {
        final value = state.height.toInt() == widget.id;
        play(value, setValue: value, playStart: state.ext['reset']);
      } else if (state is ChangeStatusManageState && ctrYTB != null && _isPlay) {
        if (widget.bloc.isComment != null) {
          ctrYTB.pause();
          ctrYTBCmt.seekTo(ctrYTB.value.position);
          ctrYTBCmt.play();
        } else {
          ctrYTBCmt.pause();
          ctrYTB.seekTo(ctrYTBCmt.value.position);
          ctrYTB.play();
        }
      }
    });
    super.initState();
    _getThumbnail();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: _onTap, child:
  BlocBuilder(bloc: widget.subBloc, builder: (context, state) {
    return Stack(children: [
      if (ctrYTB != null) Scaffold(backgroundColor: Colors.transparent,
          appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, automaticallyImplyLeading: false),
          body: GestureDetector(onTap: _onTap, child: _isShort ? _ytb : Container(height: 1.sh, width: 1.sw,
              alignment: Alignment.center, color: Colors.black, child: _ytb,
              padding: EdgeInsets.only(bottom: WidgetsBinding.instance.window.padding.top.sp + kToolbarHeight)))),
      BlocBuilder(bloc: widget.bloc, buildWhen: (oldS, newS) => newS is ChangeStatusManageState,
        builder: (context, state) {
          if (ctrVideo != null) {
            final temp = BetterVideoPlayer(
                controller: ctrVideo, bgColor: Colors.transparent, isScale: true, isCalculateScale: false,
                configuration: BetterVideoPlayerConfiguration(autoPlay: false, placeholder: _thumbnail??const SizedBox(),
                    controls: const BetterVideoPlayerControls(hideTime: true, isFullScreen: false, showControl: false)),
                dataSource: BetterVideoPlayerDataSource(BetterVideoPlayerDataSourceType.network, widget.url));
            return GestureDetector(onTap: _onTap, child: widget.bloc.isComment == null ? Stack(children: [
              _thumbnail??const SizedBox(),
              Container(width: 1.sw, height: 1.sh, color: Colors.black26),
              temp
            ]) :
              Align(alignment: Alignment.topCenter, child: Container(width: 1.sw, height: 0.4.sh, child: temp,
                  padding: EdgeInsets.only(top: WidgetsBinding.instance.window.padding.top.sp))));
          }
          if (ctrYTB != null) {
            return Align(alignment: Alignment.topCenter, child: Container(width: 1.sw, height: 0.4.sh,
              child: AnimatedOpacity(opacity: widget.bloc.isComment == null ? 0 : 1, duration: const Duration(milliseconds: 300),
                child: _ytbCmt), padding: EdgeInsets.only(top: WidgetsBinding.instance.window.padding.top.sp)));
          }
          return const SizedBox();
        }),
      BlocBuilder(bloc: widget.bloc, buildWhen: (oldS, newS) => newS is ChangeStatusManageState,
        builder: (context, state) {
          return AnimatedOpacity(opacity: _hideShowThumbnail(), duration: const Duration(milliseconds: 300),
            child: _isShort ? Scaffold(backgroundColor: Colors.transparent,
              appBar: AppBar(elevation: 0, backgroundColor: Colors.black, automaticallyImplyLeading: false),
              body: Transform.scale(scale: 2.68, child: SizedBox(width: 1.sw, height: 1.sh, child: _thumbnail))) : _thumbnail
          );
        }),
      if (!_isPlay && (ctrYTB != null || ctrVideo != null)) Container(width: 150.sp, height: 150.sp,
          child: Icon(Icons.play_arrow, color: Colors.white, size: 100.sp),
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(200)))
    ], alignment: Alignment.center);
  }));

  void _getThumbnail() async {
    if (widget.type == 'video') {
      final data = await VideoThumbnail.thumbnailData(video: widget.url, quality: 75);
      if (data != null) {
        setState(() {
          _thumbnail = Image.memory(data, width: 1.sw, height: 1.sh, fit: BoxFit.fitHeight);
        });
      }
      return;
    }

    setState(() {
      _thumbnail = ImageNetworkAsset(path: 'https://i3.ytimg.com/vi/${widget.type}/sddefault.jpg', cache: true, rateCache: 2,
          asset: 'assets/images/v8/ic_transparent.png', error: 'assets/images/v8/ic_transparent.png', width: 1.sw, fit: BoxFit.fitWidth);
    });
  }

  void _onTap() => play(!_isPlay, setValue: true);

  double _hideShowThumbnail() {
    if (widget.bloc.isComment != null) return 0;

    if (ctrVideo == null && ctrYTB == null) return 1;

    if (_isPlay && _isInitVideo && (ctrVideo != null || ctrYTB != null)) return 1;

    if (_isPlay && !_isInitVideo && (ctrVideo != null || ctrYTB != null)) return 0;

    if (!_isPlay && !_isInitVideo) return _isShort ? 1 : 0;

    return 1;
  }

  void _initVideo() {
    if (ctrVideo != null) return;
    _isInitVideo = true;
    ctrVideo = BetterVideoPlayerController();
    ctrVideo.playerEventStream.listen(_listenerPlayer);
  }

  void _listenerPlayer(event) async {
    if (!_isPlay && event.type == BetterVideoPlayerEventType.onPlay) ctrVideo.pause();
    else if (event.type == BetterVideoPlayerEventType.onPlayEnd) {
      if (widget.bloc.isComment == null) widget.bloc.playNext();
      else {
        ctrVideo.seekTo(const Duration(milliseconds: 0)).then((value) => ctrVideo.play());
      }
    }
  }

  void _setPlayVideo(bool value, bool setValue, {bool playStart = false}) async {
    _isPlay = value;
    if (value) {
      _initVideo();
      Timer(const Duration(milliseconds: 500), () => ctrVideo.play().whenComplete(() {
        bool play = false;
        if (ctrVideo.videoPlayerValue != null) play = ctrVideo.videoPlayerValue!.isPlaying;
        if (play) {
          _isInitVideo = false;
          widget.subBloc.add(LoadingEvent(true));
        } else Timer(const Duration(milliseconds: 500), () => _setPlayVideo(_isPlay, false));
      }));
    } else {
      await ctrVideo?.pause();
      if (playStart) {
        ctrVideo?.dispose();
        ctrVideo = null;
        widget.subBloc.add(LoadingEvent(false));
      }
    }
    if (setValue) widget.subBloc.add(LoadingEvent(value));
  }

  Timer? _timeYTB;
  void _forcePlayYTB() {
    _timeYTB ??= Timer(const Duration(milliseconds: 1000), () {
      if (_isPlay && ctrYTB.value.isReady && !ctrYTB.value.isPlaying) {
        ctrYTB.pause();
        Timer(const Duration(milliseconds: 500), () => _setPlayYTB(_isPlay, false));
      }
    });
  }

  void _initYTB() {
    if (ctrYTB != null) return;
    _isInitVideo = true;
    ctrYTB = YoutubePlayerController(initialVideoId: widget.type, flags: const YoutubePlayerFlags(loop: true,
        autoPlay: false, enableCaption: false, hideThumbnail: true, hideControls: true));
    ctrYTB.addListener(_listenerYTB);

    _isShort = widget.url.contains('shorts');
    _ytb = YoutubePlayer(controller: ctrYTB, width: 1.sw, onEnded: (data) => widget.bloc.playNext(), onReady: () {
      if (_isPlay && !ctrYTB.value.isPlaying) ctrYTB.pause();
    }, aspectRatio: _isShort ? 0.5 : 16/9);

    ctrYTBCmt = YoutubePlayerController(initialVideoId: widget.type, flags: const YoutubePlayerFlags(loop: true,
        autoPlay: false, enableCaption: false, hideThumbnail: false, hideControls: true));
    ctrYTBCmt.addListener(_listenerYTBCmt);

    _ytbCmt = YoutubePlayer(controller: ctrYTBCmt, width: 1.sw, onEnded: (data) {
      ctrYTBCmt.seekTo(const Duration(milliseconds: 0));
      ctrYTBCmt.play();
    });
  }

  void _listenerYTB() {
    if (_timeYTB != null && _isPlay && ctrYTB.value.isPlaying) {
      _timeYTB!.cancel();
      _timeYTB = null;
      _isInitVideo = false;
      widget.subBloc.add(LoadingEvent(true));
      return;
    }
    if (!_isPlay && ctrYTB.value.isPlaying) ctrYTB.pause();
  }

  void _listenerYTBCmt() {
    if (widget.bloc.isComment == null && ctrYTBCmt.value.isPlaying) {
      ctrYTBCmt.pause();
    }
  }

  void _setPlayYTB(bool value, bool setValue, {bool playStart = false}) {
    _isPlay = value;
    if (value) {
      _initYTB();
      if (!ctrYTB.value.isPlaying) {
        if (ctrYTB.value.isReady) ctrYTB.play();
        _forcePlayYTB();
      }
    } else {
      ctrYTB?.pause();
      if (playStart) {
        ctrYTB?.removeListener(_listenerYTB);
        ctrYTB?.dispose();
        ctrYTB = null;
        _ytb = null;

        ctrYTBCmt?.removeListener(_listenerYTBCmt);
        ctrYTBCmt?.dispose();
        ctrYTBCmt = null;
        _ytbCmt = null;

        widget.subBloc.add(LoadingEvent(false));
      }
    }
    if (setValue) widget.subBloc.add(LoadingEvent(value));
  }

  void play(bool play, {bool setValue = true, bool playStart = false}) {
    if (widget.type == 'video') _setPlayVideo(play, setValue, playStart: playStart);
    else if (widget.type.isNotEmpty) _setPlayYTB(play, setValue, playStart: playStart);
  }
}