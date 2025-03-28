import 'package:bnn/models/reel_model.dart';
import 'package:bnn/services/reel_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

class ReelProvider extends ChangeNotifier {
  final ReelService reelService = ReelService();
  VideoPlayerController? controller;
  VideoPlayerController? _nextController;
  VideoPlayerController? _prevController;
  ReelModel? _nextReel;
  ReelModel? _prevReel;
  bool _isPreloadingNext = false;
  bool _isPreloadingPrev = false;
  bool _isNoMoreReels = false;
  static const int _maxPreloadAttempts = 4;
  int _preloadNextAttempts = 0;
  int _preloadPrevAttempts = 0;

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
    _isNoMoreReels = false;

    try {
      // Load initial reel
      // int latestReelId = await reelService.getRandomReelId();
      int latestReelId = await reelService.getLatestReelId(0);
      final reel = await reelService.getReelById(latestReelId);
      if (reel != null) {
        currentReel = reel;
        reels.add(reel);
        await loadVideo(currentReel!);

        // Preload next reel and previous reel
        await preloadNextReel();
        await preloadPreviousReel();
      }
    } catch (e) {
      print("Error initializing reel: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<ReelModel?> getReelById(int reelId) async {
    return await reelService.getReelById(reelId);
  }

  Future<void> preloadNextReel() async {
    if (_nextReel != null ||
        _isPreloadingNext ||
        _preloadNextAttempts >= _maxPreloadAttempts) return;

    _isPreloadingNext = true;
    _preloadNextAttempts++;

    try {
      if (_isNoMoreReels) {
        if (reels.isNotEmpty) {
          if (currentIndex >= reels.length - 1) {
            _nextReel = reels[0];
          } else {
            _nextReel = reels[currentIndex + 1];
          }
        }
      } else {
        int nextReelId;
        int count = 0;
        do {
          nextReelId = await reelService.getLatestReelId(currentReel!.id);
          count++;
          if (count > 10) {
            break;
          }
        } while (reels.any((reel) => reel.id == nextReelId));

        if (count > 10) {
          print("there are no more reels to load");
          _isNoMoreReels = true;
          if (reels.isNotEmpty) {
            if (currentIndex >= reels.length - 1) {
              _nextReel = reels[0];
            } else {
              _nextReel = reels[currentIndex + 1];
            }
          }
        } else {
          if (currentIndex != reels.length - 1) {
            _nextReel = reels[currentIndex + 1];
          } else {
            _nextReel = await reelService.getReelById(nextReelId);
          }
        }
      }

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

  Future<void> preloadPreviousReel() async {
    if (_prevReel != null ||
        _isPreloadingPrev ||
        _preloadPrevAttempts >= _maxPreloadAttempts) return;

    _isPreloadingPrev = true;
    _preloadPrevAttempts++;

    try {
      // Get the reel before current reel
      if (currentIndex > 0) {
        _prevReel = reels[currentIndex - 1];
      } else {
        _prevReel = reels.last;
      }

      if (_prevReel != null && _prevReel!.videoUrl.isNotEmpty) {
        _prevController = VideoPlayerController.networkUrl(
          Uri.parse(_prevReel!.videoUrl),
        );

        await _prevController?.initialize();
        _preloadPrevAttempts = 0;
      }
    } catch (e) {
      print("Error preloading previous video: $e");
      _prevReel = null;
      _prevController = null;
    } finally {
      _isPreloadingPrev = false;
      notifyListeners();
    }
  }

  Future<void> nextStep() async {
    if (_nextReel == null || _nextController == null) {
      await preloadNextReel();
      return;
    }

    try {
      final oldController = controller;

      _prevReel = currentReel;
      _prevController = controller;

      controller = _nextController;
      currentReel = _nextReel;

      if (!reels.contains(_nextReel)) {
        reels.add(_nextReel!);
      }

      currentIndex++;

      _nextReel = null;
      _nextController = null;
      preloadNextReel();

      controller?.setLooping(true);
      controller?.play();

      // Dispose old controller after switching
      // if (oldController != null && oldController.value.isInitialized) {
      //   await oldController.dispose();
      // }
    } catch (e) {
      print("Error in nextStep: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> previousStep() async {
    if (_prevReel == null || _prevController == null) {
      await preloadPreviousReel();
      return;
    }

    try {
      final oldController = controller;

      _nextReel = currentReel;
      _nextController = controller;

      controller = _prevController;
      currentReel = _prevReel;
      currentIndex--;

      _prevReel = null;
      _prevController = null;
      preloadPreviousReel();

      // Play current video
      controller?.setLooping(true);
      controller?.play();

      // Dispose old controller after switching
      // if (oldController != null && oldController.value.isInitialized) {
      //   await oldController.dispose();
      // }
    } catch (e) {
      print("Error in previousStep: $e");
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
      if (_prevController != null && _prevController!.value.isInitialized) {
        await _prevController?.dispose();
      }
    } catch (e) {
      print("Error disposing controllers: $e");
    } finally {
      controller = null;
      _nextController = null;
      _prevController = null;
      _nextReel = null;
      _prevReel = null;
      _isPreloadingNext = false;
      _isPreloadingPrev = false;
      _preloadNextAttempts = 0;
      _preloadPrevAttempts = 0;
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
        // if (oldController != null && oldController.value.isInitialized) {
        //   oldController.dispose();
        // }
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
