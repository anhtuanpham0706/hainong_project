import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advn_video/advn_video.dart';
import 'package:hainong/common/count_down_bloc.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

abstract class ControlVideoListener {
  void play(int index);
  void stop(int index);
}

class VideoPage extends StatefulWidget {
  final String url;
  final bool firstStop, autoPlay, isPage, enableFullscreen, enablePlayPause, notPlay, hideTime, showControl, isOne;
  final double volume;
  final Function? listener, stopYtb;
  final int index;
  final _VideoPageState _state = _VideoPageState();
  final double? width, height;
  final ControlVideoListener? controlListener;

  VideoPage(this.url, this.index,
      {Key? key, this.autoPlay = true,
        this.volume = 1.0,
        this.listener, this.stopYtb,
        this.isPage = true,
        this.isOne = true,
        this.firstStop = false,
        this.enableFullscreen = true,
        this.enablePlayPause = true,
        this.hideTime = true,
        this.showControl = true,
        this.width, this.notPlay = false,
        this.height, this.controlListener}) : super(key: key);

  @override
  _VideoPageState createState() => _state;

  void stopPlay() => _state.stopPlay();

  void stopScroll() => _state.stopScroll();
}

class _VideoPageState extends State<VideoPage> {
  final BetterVideoPlayerController _controller = BetterVideoPlayerController();
  final CountDownBloc _bloc = CountDownBloc();
  GlobalKey keyVideo = GlobalKey();
  double height = 1.0, width = 1.0, heightV = 1.0, widthV = 1.0;
  double? scale, scaleX, scaleY;
  bool isPlay = false, isVertical = true;

  @override
  dispose() {
    _bloc.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  initState() {
    height = heightV = widget.height??1.sh;
    width = widthV = widget.width??1.sw;
    super.initState();
    _bloc.stream.listen((state) {
      if (state is CountDownState) {
        isPlay = state.value == 1;
        if (isPlay && widget.stopYtb != null) widget.stopYtb!();
      }
    });
    _controller.playerEventStream.listen((event) async {
      bool state = event.type == BetterVideoPlayerEventType.onPlay;
      if (state != isPlay) _bloc.add(CountDownEvent(value: state ? 1 : 0));
      if (!widget.isPage && state) {
        if (widget.notPlay) _controller.pause();
        if (widget.controlListener != null) widget.controlListener!.play(widget.index);
      }
    });
    if (!widget.isPage) _controller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    double h = (widget.isOne && !widget.isPage) ? heightV : height;
    double w = width;
    dynamic temp, video = BetterVideoPlayer(controller: _controller, isScale: widget.isOne || widget.isPage,
        bgColor: widget.isPage ? Colors.black : Colors.transparent,
        configuration: BetterVideoPlayerConfiguration(autoPlay: widget.autoPlay,
            controls: BetterVideoPlayerControls(hideTime: !widget.isPage, isFullScreen: false, showControl: widget.showControl)),
        dataSource: BetterVideoPlayerDataSource(BetterVideoPlayerDataSourceType.network, widget.url));
    if ((widget.isOne && !isVertical) || widget.isPage) {
      temp = video;
    } else {
      temp = SizedBox(height: h, width: w, child:
        ClipRect(child: scale == null && scaleX == null && scaleY == null ? video :
          Transform. scale(child: video, scaleY: scale != null ? null : scaleY,
            scaleX: scale != null ? null : scaleX, scale: scale)));
    }
    return Container(color: widget.isPage ? Colors.black : Colors.transparent, height: h, child: Stack(children: [
      temp,
      BlocBuilder(bloc: _bloc, buildWhen: (olsS, newS) => newS is CountDownState,
        builder: (context, state) => isPlay ? const SizedBox() : GestureDetector(onTap: _play,
          child: Container(width: 150.sp, height: 150.sp, child: Icon(Icons.play_arrow, color: Colors.white, size: 100.sp),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(200))))),
      if (!widget.isPage) Container(width: w, height: h,
          margin: widget.showControl ? const EdgeInsets.only(bottom: 60.0) : null,
          child: GestureDetector(onTap: () {
            if (widget.listener != null) {
              _controller.pause();
              widget.listener!();
            } else if (!isPlay) _play();
          })),
      if (!widget.isPage && !widget.notPlay)
        BlocBuilder(bloc: _bloc, buildWhen: (olsS, newS) => newS is CountDownState,
          builder: (context, state) => Align(alignment: Alignment.bottomLeft, child: Container(alignment: Alignment.centerLeft,
            width: 1.sw, height: 140.sp, decoration: const BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black26])),
            child: GestureDetector(onTap: () {
                if (_controller.videoPlayerValue != null) {
                  isPlay ? _controller.pause() : _play();
                }
              }, child: Padding(padding: EdgeInsets.all(40.sp),
                child: Icon(isPlay ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 80.sp))))))
    ], alignment: Alignment.center), key: keyVideo);
  }

  void _listener() {
    if (_controller.videoPlayerValue != null) {
      _controller.removeListener(_listener);
      setState(() {
        isVertical = _controller.videoPlayerValue!.size.width < _controller.videoPlayerValue!.size.height;
        heightV = _controller.videoPlayerValue!.size.height;
        widthV = _controller.videoPlayerValue!.size.width;
        if (widget.isOne && !widget.isPage) {
          heightV = (widget.width??1.sw)/_controller.videoPlayerValue!.aspectRatio;
          if (widget.height != null && heightV > widget.height!) heightV = widget.height!;

          if (isVertical) widthV = (widget.height ?? 1.sh) * _controller.videoPlayerValue!.aspectRatio;

          scaleX = width/widthV;
          scaleY = height/heightV;
          scale = scaleX! > scaleY! ? scaleX : scaleY;
        } else {
          if (width < widthV) scaleX = widthV / width;
          if (height < heightV) scaleY = heightV / height;
        }
      });
    }
  }

  void stopPlay() {
    if (_controller.videoPlayerValue != null && _controller.videoPlayerValue!.isPlaying && !widget.notPlay) _controller.pause();
  }

  void stopScroll() {
    if (_controller.videoPlayerValue != null && !_controller.videoPlayerValue!.isPlaying && !widget.notPlay && !_isPause()) _play();
  }

  bool _isPause() {
    try {
      if (keyVideo.currentContext != null) {
        final RenderBox renderObj = keyVideo.currentContext!.findRenderObject() as RenderBox;
        final position = renderObj.localToGlobal(Offset.zero);
        if (position.dy < 1.sh/8) return true;
        if (position.dy > 1.sh * 5/8) return true;
      }
    } catch(e) {
      return true;
    }
    return false;
  }

  void _play() {
    if (widget.stopYtb != null) widget.stopYtb!();
    _controller.play();
  }
}
