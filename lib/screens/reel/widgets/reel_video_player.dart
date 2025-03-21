import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPlayer extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool isTransitioning;

  const ReelVideoPlayer({
    Key? key,
    required this.controller,
    required this.isTransitioning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: VideoPlayer(controller!),
          ),
        ),
        if (isTransitioning)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }
}
