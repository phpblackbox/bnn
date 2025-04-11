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

    final size = controller!.value.size;
    final isLandscape = size.width > size.height;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: isLandscape
              ? FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: VideoPlayer(controller!),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: VideoPlayer(controller!),
                  ),
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
