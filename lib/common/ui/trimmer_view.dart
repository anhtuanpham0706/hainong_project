import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import '../util/util_ui.dart';

class TrimmerView extends StatefulWidget {
  final File file;
  final int index;
  const TrimmerView(this.file, this.index, {Key? key}) : super(key: key);
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0, _endValue = 0.0;
  bool _isPlaying = false, _progressVisibility = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() => _trimmer.loadVideo(videoFile: widget.file);

  _saveVideo() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedVideo(
      startValue: _startValue, endValue: _endValue,
      videoFolderName: 'images',
      storageDir: StorageDir.applicationDocumentsDirectory,
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        if (outputPath != null && outputPath.isNotEmpty) UtilUI.goBack(context, [File(outputPath), widget.index]);
      },
    ).catchError((e) {
      setState(() {
        _progressVisibility = false;
      });
    }).onError((e, s) {
      setState(() {
        _progressVisibility = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(backgroundColor: Colors.black,
        appBar: AppBar(title: const Text("Cắt Video"), centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.save), tooltip: 'Lưu',
              onPressed: _progressVisibility ? null : () => _saveVideo()
            )
          ]),
        body: Builder(builder: (context) => Center(
            child: Container(padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Visibility(
                    visible: _progressVisibility,
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.red
                    )
                  ),
                  Expanded(child: VideoViewer(trimmer: _trimmer)),
                  Center(
                    child: TrimEditor(
                      trimmer: _trimmer,
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      maxVideoLength: const Duration(seconds: 1000000),
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onChangePlaybackState: (value) {
                        setState(() {
                          _isPlaying = value;
                        });
                      }
                    )
                  ),
                  TextButton(
                    child: _isPlaying
                        ? const Icon(Icons.pause, size: 80.0, color: Colors.white)
                        : const Icon(Icons.play_arrow, size: 80.0, color: Colors.white),
                    onPressed: () async {
                      bool playbackState = await _trimmer.videPlaybackControl(
                        startValue: _startValue,
                        endValue: _endValue
                      );
                      setState(() {
                        _isPlaying = playbackState;
                      });
                    }
                  )
                ]))))
      ));
  }
}
