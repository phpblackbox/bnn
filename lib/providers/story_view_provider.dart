import 'package:bnn/services/story_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryViewProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();

  dynamic currentStory = {
    "media_urls": [],
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
      // Get all stories
      stories = await _storyService.getLatestStories();
      final nowString = await _storyService.getServerTime();
      for (var story in stories) {
        DateTime now = DateTime.parse(nowString);
        DateTime createdAt = DateTime.parse(story["created_at"]);
        Duration difference = now.difference(createdAt);
        story['timeDiff'] = Constants().formatDuration(difference);
      }
      print("PROVIDER: Loaded ${stories.length} stories");

      // Find the index of the current story ID in the stories list
      int initialIndex = -1;
      for (int i = 0; i < stories.length; i++) {
        if (stories[i]['id'] == storyId) {
          initialIndex = i;
          break;
        }
      }

      // If the story is not in the list, add it
      if (initialIndex == -1) {
        final story = await getStoryById(storyId);
        if (story != null) {
          stories.add(story);
          initialIndex = stories.length - 1;
        }
      }

      // Set the current story
      if (initialIndex != -1) {
        currentStory = stories[initialIndex];
        currentStoryIndex = initialIndex;

        // If the first media is a video, load it
        if (currentStory['media_urls'].isNotEmpty && _isVideo(currentStory['media_urls'][0])) {
          await loadVideo(currentStory['media_urls'][0]);
        }

        // Start preloading adjacent stories
        preloadNextStory();
        preloadPreviousStory();
      } else {
        print("PROVIDER: Failed to find story with ID: $storyId");
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
      if (stories.isEmpty) return;

      // Get the next story index
      int nextIndex;
      if (currentStoryIndex >= stories.length - 1) {
        // If we're at the last story, wrap around to the first
        nextIndex = 0;
      } else {
        // Otherwise, get the next story
        nextIndex = currentStoryIndex + 1;
      }

      // Set the next story
      _nextStory = stories[nextIndex];

      // Preload first video if any
      if (_nextStory != null && _nextStory['media_urls'].isNotEmpty) {
        for (var mediaUrl in _nextStory['media_urls']) {
          if (_isVideo(mediaUrl)) {
            final tempController = VideoPlayerController.networkUrl(
              Uri.parse(mediaUrl),
            );
            await tempController.initialize();
            await tempController.dispose();
            break;
          }
        }
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
      if (stories.isEmpty) return;

      int prevIndex;
      if (currentStoryIndex <= 0) {
        prevIndex = stories.length - 1;
      } else {
        prevIndex = currentStoryIndex - 1;
      }

      _prevStory = stories[prevIndex];

      if (_prevStory != null && _prevStory['media_urls'].isNotEmpty) {
        for (var mediaUrl in _prevStory['media_urls']) {
          if (_isVideo(mediaUrl)) {
            final tempController = VideoPlayerController.networkUrl(
              Uri.parse(mediaUrl),
            );
            await tempController.initialize();
            await tempController.dispose();
            break;
          }
        }
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
      _nextStory = null;

      currentImageIndex = 0;
      // If first media is video, load it
      if (currentStory['media_urls'].isNotEmpty && _isVideo(currentStory['media_urls'][0])) {
        await loadVideo(currentStory['media_urls'][0]);
      }

      if (currentStoryIndex >= stories.length - 1) {
        currentStoryIndex = 0;
      } else {
        currentStoryIndex++;
      }

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
      _prevStory = null;

      currentImageIndex = 0;
      if (currentStory['media_urls'].isNotEmpty && _isVideo(currentStory['media_urls'][0])) {
        await loadVideo(currentStory['media_urls'][0]);
      }

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
    if (currentStory['media_urls'].length > 1) {
      if (currentImageIndex == currentStory['media_urls'].length - 1) {
        currentImageIndex = 0;
      } else {
        currentImageIndex = currentImageIndex + 1;
      }
      // If next media is video, load it
      if (_isVideo(currentStory['media_urls'][currentImageIndex])) {
        loadVideo(currentStory['media_urls'][currentImageIndex]);
      } else {
        if (controller != null) {
          controller!.dispose();
          controller = null;
        }
      }
      notifyListeners();
    }
  }

  void prevImage() {
    if (currentStory['media_urls'].length > 1) {
      if (currentImageIndex == 0) {
        currentImageIndex = currentStory['media_urls'].length - 1;
      } else {
        currentImageIndex = currentImageIndex - 1;
      }
      // If prev media is video, load it
      if (_isVideo(currentStory['media_urls'][currentImageIndex])) {
        loadVideo(currentStory['media_urls'][currentImageIndex]);
      } else {
        if (controller != null) {
          controller!.dispose();
          controller = null;
        }
      }
      notifyListeners();
    }
  }

  Future<void> close() async {
    
    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }

    _nextStory = null;
    _prevStory = null;
    _isPreloadingNext = false;
    _isPreloadingPrev = false;
    _preloadNextAttempts = 0;
    _preloadPrevAttempts = 0;
    initializeVideoPlayerFuture = null;
  }

  Future<void> deleteStory() async {
    if (currentStory == null) return;
    
    try {
      await _storyService.deleteStory(currentStory['id']);
      // Remove the current story from the stories list
      stories.removeAt(currentStoryIndex);
      
      // If there are no more stories, set currentStory to null
      if (stories.isEmpty) {
        currentStory = null;
      } else {
        // Otherwise, move to the next story or previous story
        if (currentStoryIndex >= stories.length) {
          currentStoryIndex = stories.length - 1;
        }
        currentStory = stories[currentStoryIndex];
        currentImageIndex = 0;
        
        // If first media is video, load it
        if (currentStory['media_urls'].isNotEmpty && _isVideo(currentStory['media_urls'][0])) {
          await loadVideo(currentStory['media_urls'][0]);
        }
      }
      
      notifyListeners();
    } catch (e) {
      print("Error disposing controllers: $e");
    } finally {
      initializeVideoPlayerFuture = null;
    }
  }

  Future<void> loadVideo(String videoUrl) async {
    try {
      if (controller != null) {
        await controller!.dispose();
        controller = null;
        initializeVideoPlayerFuture = null;
        print("PROVIDER: Disposed existing video controller");
      }

      if (videoUrl.isNotEmpty) {
        print("PROVIDER: Creating video controller for $videoUrl");
        controller = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );

        initializeVideoPlayerFuture = controller!.initialize().then((_) {
          controller!.setLooping(true);
          controller!.play();
          print("PROVIDER: Video initialized and playing");
          notifyListeners();
        }).catchError((error) {
          print("PROVIDER: Error initializing video: $error");
        });
      } else {
        print("PROVIDER: Video URL is empty");
        initializeVideoPlayerFuture = Future.value();
      }
    } catch (e) {
      print("PROVIDER: Error creating video controller: $e");
      initializeVideoPlayerFuture = Future.error(e);
    }
  }

  bool _isVideo(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.mkv'];
    return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }
}
