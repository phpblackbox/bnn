import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPlayer extends StatelessWidget {
  // final VideoPlayerController controller;
  final VlcPlayerController controller;

  const ReelVideoPlayer({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return VideoPlayer(controller);
    return VlcPlayer(
      controller: controller,
      aspectRatio: 9 / 16,
    );
  }
}
