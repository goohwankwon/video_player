import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vid_player/component/custom_icon.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class CustomVideoPlayer extends StatefulWidget {
  final XFile? video;
  final GestureTapCallback onNewVideoPressed;

  const CustomVideoPlayer({
    super.key,
    required this.video,
    required this.onNewVideoPressed,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayer();
}

class _CustomVideoPlayer extends State<CustomVideoPlayer> {
  VideoPlayerController? _videoController;
  Timer? _hideControlTimer;
  bool showControl = true;

  @override
  void initState() {
    super.initState();

    initializeController();
  }

  @override
  void dispose() {
    disposeController();
    _hideControlTimer?.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video!.path != widget.video!.path) {
      initializeController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          showControl = !showControl;
        });
      },
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_videoController!),
            if (showControl) Container(color: Colors.black.withOpacity(0.5)),
            if (showControl)
              Align(
                alignment: Alignment.topRight,
                child: CustomIcon(
                  onPressed: () {
                    widget.onNewVideoPressed();
                  },
                  iconData: Icons.photo_camera_back,
                ),
              ),
            if (showControl)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      renderTimeFromDuration(_videoController!.value.position),
                      Expanded(
                        child: Slider(
                          min: 0,
                          max:
                              _videoController!.value.duration.inSeconds
                                  .toDouble(),
                          value:
                              _videoController!.value.position.inSeconds
                                  .toDouble(),
                          onChanged: (double val) {
                            _hideControlTimer?.cancel();
                            _videoController!.seekTo(
                              Duration(seconds: val.toInt()),
                            );
                            hideControl();
                          },
                        ),
                      ),
                      renderTimeFromDuration(_videoController!.value.duration),
                    ],
                  ),
                ),
              ),
            if (showControl)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomIcon(
                      onPressed: () {
                        seekBy('backward');
                        if(_videoController!.value.isPlaying){
                          hideControl();
                        }
                      },
                      iconData: Icons.rotate_left,
                    ),
                    _videoController!.value.isPlaying
                        ? CustomIcon(
                          onPressed: () {
                            _videoController?.pause();
                          },
                          iconData: Icons.pause,
                        )
                        : CustomIcon(
                          onPressed: () {
                            _videoController?.play();
                            hideControl();
                          },
                          iconData: Icons.play_arrow,
                        ),
                    CustomIcon(
                      onPressed: () {
                        seekBy('forward');
                        if(_videoController!.value.isPlaying){
                          hideControl();
                        }
                      },
                      iconData: Icons.rotate_right,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget renderTimeFromDuration(Duration duration) {
    return Text(
      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
      style: TextStyle(color: Colors.white),
    );
  }

  Future<void> initializeController() async {
    await disposeController();

    final videoController = VideoPlayerController.file(
      File(widget.video!.path),
    );

    await videoController.initialize();
    videoController.addListener(videoControllerListener);

    setState(() {
      _videoController = videoController;
      showControl = true;
    });
  }

  Future<void> disposeController() async {
    _videoController?.removeListener(videoControllerListener);
    await _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;
  }

  void videoControllerListener() {
    if (!mounted) return;

    setState(() {});
  }

  void hideControl() {
    _hideControlTimer?.cancel();
    _hideControlTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showControl = false;
        });
      }
    });
  }

  void seekBy(String direction) {
    final current = _videoController!.value.position;

    switch (direction) {
      case 'forward':
        if (current.inSeconds + 3 <=
            _videoController!.value.duration.inSeconds) {
          _videoController!.seekTo(current + Duration(seconds: 3));
        } else if (current.inSeconds + 3 >
            _videoController!.value.duration.inSeconds) {
          _videoController!.seekTo(_videoController!.value.duration);
        }
        break;
      case 'backward':
        if (current.inSeconds >= 3) {
          _videoController!.seekTo(current - Duration(seconds: 3));
        } else if (current.inSeconds < 3) {
          _videoController!.seekTo(Duration(seconds: 0));
        }
        break;
    }
  }
}
