import 'package:bnn/services/story_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryViewProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();

  dynamic currentStory = {
    "img_urls": [],
    "video_url": "",
    "id": 0,
    "username": "",
    "avatar": "",
    "authour_id": "",
    "created_at": '',
    "comments": "",
    "timeDiff": "0",
  };

  List<dynamic> stories = [];
  int _currentStoryIndex = 0;
  int get currentStoryIndex => _currentStoryIndex;
  set currentStoryIndex(int value) {
    _currentStoryIndex = value;
    notifyListeners();
  }

  VideoPlayerController? controller;
  dynamic _nextStory;
  dynamic _prevStory;
  bool _isPreloadingNext = false;
  bool _isPreloadingPrev = false;
  bool _isNoMoreStories = false;
  static const int _maxPreloadAttempts = 4;
  int _preloadNextAttempts = 0;
  int _preloadPrevAttempts = 0;

  Future<void>? initializeVideoPlayerFuture;

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;
  set currentImageIndex(int value) {
    _currentImageIndex = value;
    notifyListeners();
  }

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  int latestId = 0;

  Future<void> initialize(int storyId) async {
    loading = true;

    stories = [];
    currentStoryIndex = 0;
    currentImageIndex = 0;
    _isNoMoreStories = false;
    _nextStory = null;
    _prevStory = null;
    currentStory = null;
    await close();

    try {
      final story = await getStoryById(storyId);
      if (story != null) {
        currentStory = story;
        stories.add(story);
        print("PROVIDER: Initialized story ${story['id']}");

        if (story['type'] == 'video') {
          print("PROVIDER: Initial story is video, calling loadVideo");
          await loadVideo(story);
        }

        // Start preloading adjacent stories
        // Don't await these, let them run in the background
        latestId = await _storyService.getStoryLatestId();
        preloadNextStory();
        preloadPreviousStory();
      } else {
        print("PROVIDER: Failed to get story by ID: $storyId");
      }
    } catch (e) {
      print("PROVIDER: Error initializing story: $e");
    } finally {
      loading = false;
      print("PROVIDER: Setting loading = false and notifying listeners");
      notifyListeners();
    }
  }

  Future<dynamic> getStoryById(int storyId) async {
    try {
      final tempStory = await _storyService.getStoryById(storyId);
      final nowString = await _storyService.getServerTime();
      DateTime now = DateTime.parse(nowString);
      DateTime createdAt = DateTime.parse(tempStory["created_at"]);
      Duration difference = now.difference(createdAt);
      tempStory['timeDiff'] = Constants().formatDuration(difference);
      return tempStory;
    } catch (e) {
      print("Error getting story by ID: $e");
      return null;
    }
  }

  Future<void> preloadNextStory() async {
    if (_nextStory != null ||
        _isPreloadingNext ||
        _preloadNextAttempts >= _maxPreloadAttempts) return;

    _isPreloadingNext = true;
    _preloadNextAttempts++;

    try {
      if (_isNoMoreStories) {
        if (stories.isNotEmpty) {
          if (currentStoryIndex >= stories.length - 1) {
            _nextStory = stories[0];
          } else {
            _nextStory = stories[currentStoryIndex + 1];
          }
        }
      } else {
        int? nextId;
        int count = 0;
        do {
          nextId = stories.last['id'] != latestId
              ? await _storyService.getNextStoryId(null)
              : await _storyService.getNextStoryId(stories.last['id']);

          if (nextId == null) {
            print("No more stories to load");
            _isNoMoreStories = true;
            if (stories.isNotEmpty) {
              if (currentStoryIndex >= stories.length - 1) {
                _nextStory = stories[0];
              } else {
                _nextStory = stories[currentStoryIndex + 1];
              }
            }
            return;
          }
          count++;
          if (count > 10) {
            break;
          }
        } while (stories.any((story) => story['id'] == nextId));

        if (count > 10) {
          print("there are no more stories to load");
          _isNoMoreStories = true;
          if (stories.isNotEmpty) {
            if (currentStoryIndex >= stories.length - 1) {
              _nextStory = stories[0];
            } else {
              _nextStory = stories[currentStoryIndex + 1];
            }
          }
        } else {
          _nextStory = await getStoryById(nextId!);
        }
      }

      if (_nextStory != null && _nextStory['type'] == 'video') {
        final tempController = VideoPlayerController.networkUrl(
          Uri.parse(_nextStory['video_url']),
        );
        await tempController.initialize();
        await tempController.dispose();
      }
      _preloadNextAttempts = 0;
    } catch (e) {
      print("Error preloading next story: $e");
      _nextStory = null;
    } finally {
      _isPreloadingNext = false;
      notifyListeners();
    }
  }

  Future<void> preloadPreviousStory() async {
    if (_prevStory != null ||
        _isPreloadingPrev ||
        _preloadPrevAttempts >= _maxPreloadAttempts) return;

    _isPreloadingPrev = true;
    _preloadPrevAttempts++;

    try {
      if (currentStoryIndex > 0) {
        _prevStory = stories[currentStoryIndex - 1];
      } else {
        _prevStory = stories.last;
      }

      if (_prevStory != null && _prevStory['type'] == 'video') {
        final tempController = VideoPlayerController.networkUrl(
          Uri.parse(_prevStory['video_url']),
        );
        await tempController.initialize();
        await tempController.dispose();
      }
      _preloadPrevAttempts = 0;
    } catch (e) {
      print("Error preloading previous story: $e");
      _prevStory = null;
    } finally {
      _isPreloadingPrev = false;
      notifyListeners();
    }
  }

  Future<void> nextStory() async {
    if (_nextStory == null) {
      await preloadNextStory();
      return;
    }

    try {
      if (controller != null) {
        await controller!.dispose();
        controller = null;
      }

      _prevStory = currentStory;
      currentStory = _nextStory;

      if (currentStory['type'] == 'video') {
        await loadVideo(currentStory);
      }

      if (!stories.contains(_nextStory)) {
        stories.add(_nextStory);
      }

      _nextStory = null;

      if (currentStoryIndex >= stories.length - 1) {
        currentStoryIndex = 0;
      } else {
        currentStoryIndex++;
      }

      currentImageIndex = 0;
      preloadNextStory();
    } catch (e) {
      print("Error in nextStory: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> previousStory() async {
    if (_prevStory == null) {
      await preloadPreviousStory();
      return;
    }

    try {
      if (controller != null) {
        await controller!.dispose();
        controller = null;
      }

      _nextStory = currentStory;
      currentStory = _prevStory;

      if (currentStory['type'] == 'video') {
        await loadVideo(currentStory);
      }

      _prevStory = null;

      currentImageIndex = 0;

      if (currentStoryIndex <= 0) {
        currentStoryIndex = stories.length - 1;
      } else {
        currentStoryIndex--;
      }

      preloadPreviousStory();
    } catch (e) {
      print("Error in previousStory: $e");
    } finally {
      notifyListeners();
    }
  }

  void nextImage() {
    if (currentStory['img_urls'].length > 1) {
      if (currentImageIndex == currentStory['img_urls'].length - 1) {
        currentImageIndex = 0;
      } else {
        currentImageIndex = currentImageIndex + 1;
      }
      notifyListeners();
    }
  }

  void prevImage() {
    if (currentStory['img_urls'].length > 1) {
      if (currentImageIndex == 0) {
        currentImageIndex = currentStory['img_urls'].length - 1;
      } else {
        currentImageIndex = currentImageIndex - 1;
      }
      notifyListeners();
    }
  }

  Future<void> close() async {
    try {
      if (controller != null && controller!.value.isInitialized) {
        await controller?.dispose();
      }
    } catch (e) {
      print("Error disposing controllers: $e");
    } finally {
      controller = null;
      _nextStory = null;
      _prevStory = null;
      _isPreloadingNext = false;
      _isPreloadingPrev = false;
      _preloadNextAttempts = 0;
      _preloadPrevAttempts = 0;
      initializeVideoPlayerFuture = null;
    }
  }

  Future<void> loadVideo(dynamic story) async {
    try {
      if (controller != null) {
        await controller!.dispose();
        controller = null;
        initializeVideoPlayerFuture = null;
        print("PROVIDER: Disposed existing video controller");
      }

      if (story['video_url'] != null && story['video_url'].isNotEmpty) {
        print("PROVIDER: Creating video controller for ${story['video_url']}");
        controller = VideoPlayerController.networkUrl(
          Uri.parse(story['video_url']),
        );

        initializeVideoPlayerFuture = controller!.initialize().then((_) {
          controller!.setLooping(true);
          controller!.play();
          print("PROVIDER: Video initialized and playing: ${story['id']}");
          notifyListeners();
        }).catchError((error) {
          print("PROVIDER: Error initializing video: $error");
        });
      } else {
        print("PROVIDER: Video URL is null or empty for story ${story['id']}");
        initializeVideoPlayerFuture = Future.value();
      }
    } catch (e) {
      print("PROVIDER: Error creating video controller: $e");
      initializeVideoPlayerFuture = Future.error(e);
    }
  }
}
