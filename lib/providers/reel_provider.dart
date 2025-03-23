import 'package:bnn/models/reel_model.dart';
import 'package:bnn/services/reel_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

class ReelProvider extends ChangeNotifier {
  final ReelService reelService = ReelService();
  VideoPlayerController? controller;
  VideoPlayerController? _nextController;
  ReelModel? _nextReel;
  bool _isPreloadingNext = false;
  static const int _maxPreloadAttempts = 3;
  int _preloadNextAttempts = 0;

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ReelModel? currentReel;
  int currentIndex = 0;
  List<ReelModel> reels = [];
  Future<void>? initializeVideoPlayerFuture;

  Future<void> initialize() async {
    reels = [];
    currentReel = null;
    currentIndex = 0;
    loading = true;

    try {
      int randomReelId = await reelService.getRandomReelId();
      final reel = await reelService.getReelById(randomReelId);
      if (reel != null) {
        currentReel = reel;
        reels.add(reel);
        await loadVideo(currentReel!);
        await _preloadNextVideo();
      }
    } catch (e) {
      print("Error initializing reel: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _preloadNextVideo() async {
    if (_nextReel != null ||
        _isPreloadingNext ||
        _preloadNextAttempts >= _maxPreloadAttempts) return;

    _isPreloadingNext = true;
    _preloadNextAttempts++;

    int count = 0;
    try {
      int randomReelId;
      do {
        randomReelId = await reelService.getRandomReelId();
        count++;
        if (count > 10) {
          print("there are no more reels to load");
          currentIndex = 0;
          return;
        }
      } while (reels.any((reel) => reel.id == randomReelId));

      if (count > 10) {
        print("there are no more reels to load");
        return;
      }

      _nextReel = await reelService.getReelById(randomReelId);

      if (_nextReel != null && _nextReel!.videoUrl.isNotEmpty) {
        _nextController = VideoPlayerController.networkUrl(
          Uri.parse(_nextReel!.videoUrl),
        );
        await _nextController?.initialize();
        _preloadNextAttempts = 0; // Reset attempts on success
      }
    } catch (e) {
      print("Error preloading next video: $e");
      _nextReel = null;
      _nextController = null;
    } finally {
      _isPreloadingNext = false;
      notifyListeners();
    }
  }

  Future<void> nextStep() async {
    if (_nextReel == null || _nextController == null) {
      await _preloadNextVideo();
      return;
    }

    try {
      // Store current controller before disposing
      final oldController = controller;

      // Switch to preloaded content first
      controller = _nextController;
      currentReel = _nextReel;
      reels.add(_nextReel!);
      currentIndex++;

      // Start preloading next video
      _nextReel = null;
      _nextController = null;
      _preloadNextVideo();

      // Play current video
      controller?.setLooping(true);
      controller?.play();

      // Dispose old controller after switching
      if (oldController != null && oldController.value.isInitialized) {
        await oldController.dispose();
      }
    } catch (e) {
      print("Error in nextStep: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> close() async {
    try {
      if (controller != null && controller!.value.isInitialized) {
        await controller?.dispose();
      }
      if (_nextController != null && _nextController!.value.isInitialized) {
        await _nextController?.dispose();
      }
    } catch (e) {
      print("Error disposing controllers: $e");
    } finally {
      controller = null;
      _nextController = null;
      _nextReel = null;
      _isPreloadingNext = false;
      _preloadNextAttempts = 0;
      initializeVideoPlayerFuture = null;
    }
  }

  Future<void> loadVideo(ReelModel currentReel) async {
    try {
      // Store old controller
      final oldController = controller;

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

        // Dispose old controller after new one is initialized
        if (oldController != null && oldController.value.isInitialized) {
          oldController.dispose();
        }
      } else {
        print("Video URL is not available");
      }
    } catch (e) {
      print("Error creating video controller: $e");
    }
  }

  Future<void> increaseCountComment() async {
    currentReel!.comments += 1;
    notifyListeners();
  }

  Future<void> decreaseCountComment() async {
    currentReel!.comments -= 1;
    notifyListeners();
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
