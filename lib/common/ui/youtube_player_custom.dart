import 'import_lib_base_ui.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

abstract class YoutubeCallback {
  void playPause(bool isPlay);
}

class YoutubePlayerCustom extends StatefulWidget implements YoutubeCallback {
  final String id, image, url;
  final bool isShop;
  final _YoutubePlayerCustomState _state = _YoutubePlayerCustomState();
  final Function? stopVideo;
  YoutubePlayerCustom(this.id, this.image, this.url, {this.stopVideo, this.isShop = false, Key? key}):super(key:key);
  @override
  _YoutubePlayerCustomState createState() => _state;

  @override
  void playPause(bool isPlay) => _state.playPause(isPlay);
}

class _YoutubePlayerCustomState extends State<YoutubePlayerCustom> {
  late YoutubePlayerController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = YoutubePlayerController(initialVideoId: widget.id, flags: const YoutubePlayerFlags(hideControls: true,
        loop: false, autoPlay: false, hideThumbnail: false, showLiveFullscreenButton: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: () {
    if (widget.isShop) return;
    _controller.value.isPlaying ? _controller.pause() : _play();
  }, child: SizedBox(width: 1.sw, height: 0.5.sw, child: YoutubePlayer(controller: _controller, width: 1.sw)));

  void playPause(bool isPlay) {
    if (isPlay) {
      if (!_controller.value.isPlaying) _play();
    } else {
      if (_controller.value.isPlaying) _controller.pause();
    }
  }

  void _play() {
    if (widget.stopVideo != null) widget.stopVideo!();
    _controller.play();
  }
}