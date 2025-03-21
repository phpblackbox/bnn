import 'package:bnn/models/reel_model.dart';
import 'package:bnn/services/reel_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

class ReelProvider extends ChangeNotifier {
  final ReelService reelService = ReelService();
  VideoPlayerController? controller;
  // late VlcPlayerController controller;
  // VlcPlayerController? controller;

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ReelModel? currentReel;

  List<ReelModel> reels = [];

  Future<void>? initializeVideoPlayerFuture;

  Future<void> initialize() async {
    reels = [];
    currentReel = null;
    loading = true;

    int randomReelId;
    randomReelId = await reelService.getRandomReelId();
    final reel = await reelService.getReelById(randomReelId);
    if (reel != null) {
      currentReel = reel;
      reels.add(reel);
    }
    notifyListeners();
    await loadVideo(currentReel!);

    await nextStep();
    loading = false;
  }

  Future<void> increaseCountComment() async {
    currentReel!.comments += 1;
    notifyListeners();
  }

  Future<void> decreaseCountComment() async {
    currentReel!.comments -= 1;
    notifyListeners();
  }

  Future<void> nextStep() async {
    currentReel = reels.last;
    notifyListeners();
    await loadVideo(currentReel!);

    int randomReelId;
    do {
      randomReelId = await reelService.getRandomReelId();
    } while (reels.any((reel) => reel.id == randomReelId));

    final reel = await reelService.getReelById(randomReelId);
    if (reel != null) {
      reels.add(reel);
    }
    notifyListeners();
  }

  Future<void> close() async {
    if (controller != null && controller!.value.isInitialized) {
      await controller?.dispose();
    }
    controller = null;
    initializeVideoPlayerFuture = null;
  }

  Future<void> loadVideo(ReelModel currentReel) async {
    if (controller != null) {
      await controller?.dispose();
    }

    if (currentReel.videoUrl.isNotEmpty) {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(currentReel.videoUrl),
      );

      initializeVideoPlayerFuture = controller!.initialize().then((_) {
        controller!.setLooping(true);
        controller!.play();
        notifyListeners();
      }).catchError((error) {
        print("Error initializing video: $error");
      });
    } else {
      print("Video URL is not available");
    }
  }

  Future<void> toggleLikeReel() async {
    if (currentReel == null) return;
    bool status = await reelService.toggleLikeReel(currentReel!);
    currentReel!.likes += status ? 1 : -1;
    notifyListeners();
  }

  Future<void> toggleBookmarkReel() async {
    if (currentReel == null) return;
    bool status = await reelService.toggleBookmarkReel(currentReel!);
    currentReel!.bookmarks += status ? 1 : -1;
    notifyListeners();
  }
}
