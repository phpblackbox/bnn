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

  bool loading = false;

  ReelModel? currentReel;
  ReelModel? nextReel;
  int currentReelId = 0;
  int nextReelId = 0;

  Future<void>? initializeVideoPlayerFuture;

  ReelProvider({int? initialReelId}) {
    initialize(initialReelId);
  }

  Future<void> initialize(int? initialReelId) async {
    loading = true;
    notifyListeners();

    int randomReelId1;
    if (initialReelId != null) {
      randomReelId1 = initialReelId;
    } else {
      randomReelId1 = await reelService.getRandomReelId();
    }

    final reel = await reelService.getReelById(randomReelId1);
    if (reel != null) {
      currentReelId = randomReelId1;
      currentReel = reel;
    }
    notifyListeners();

    await loadVideo(currentReel!);

    int randomReelId2 = await reelService.getRandomReelId();
    final temp2 = await reelService.getReelById(randomReelId2);
    if (temp2 != null) {
      nextReel = temp2;
      nextReelId = randomReelId2;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> increaseCountComment() async {
    currentReel!.comments += 1;
    print('count of comments ${currentReel!.comments}');
    notifyListeners();
  }

  Future<void> nextStep() async {
    currentReelId = nextReelId;
    currentReel = nextReel;
    await loadVideo(currentReel!);

    final randomReelId = await reelService.getRandomReelId();

    final temp = await reelService.getReelById(randomReelId);
    if (temp != null) {
      nextReel = temp;
      nextReelId = randomReelId;
    }
    notifyListeners();
  }

  Future<void> loadVideo(ReelModel currentReel) async {
    if (controller != null) {
      await controller?.dispose();
    }

    if (currentReel.videoUrl.isNotEmpty) {
      // if (controller != null) {
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
    bool status = await reelService.toggleLikeReel(currentReelId, currentReel!);
    currentReel!.likes += status ? 1 : -1;
    notifyListeners();
  }

  Future<void> toggleBookmarkReel() async {
    if (currentReel == null) return;
    bool status =
        await reelService.toggleBookmarkReel(currentReelId, currentReel!);
    currentReel!.bookmarks += status ? 1 : -1;
    notifyListeners();
  }
}
