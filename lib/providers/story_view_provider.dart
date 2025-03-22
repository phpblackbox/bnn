import 'package:bnn/services/story_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryViewProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();

  dynamic story = {
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

  Future<void>? initializeVideoPlayerFuture;
  VideoPlayerController? controller;

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

    // Load initial story
    final initialStory = await getStoryById(storyId);
    stories.add(initialStory);
    await preloadNextStory();
    await preloadPreviousStory();

    loadStory(0);
    loading = false;
  }

  Future<dynamic> getStoryById(int storyId) async {
    final tempStory = await _storyService.getStoryById(storyId);
    final nowString = await _storyService.getServerTime();
    DateTime now = DateTime.parse(nowString);
    DateTime createdAt = DateTime.parse(tempStory["created_at"]);
    Duration difference = now.difference(createdAt);
    tempStory['timeDiff'] = Constants().formatDuration(difference);
    return tempStory;
  }

  Future<void> preloadNextStory() async {
    int count = 0;
    int randomId;
    do {
      randomId = await _storyService.getRandomStoryId();
      count++;
      if (count > 10) {
        break;
      }
    } while (stories.any((story) => story['id'] == randomId));

    if (count > 10) {
      print("there are no more stories to load");
      currentStoryIndex = 0;
      return;
    }

    final nextStory = await getStoryById(randomId);
    stories.add(nextStory);
    notifyListeners();
  }

  Future<void> preloadPreviousStory() async {
    int count = 0;
    int randomId;
    do {
      randomId = await _storyService.getRandomStoryId();
      count++;
      if (count > 10) {
        break;
      }
    } while (stories.any((story) => story['id'] == randomId));

    if (count > 10) {
      print("there are no more stories to load");
      currentStoryIndex = 0;
      return;
    }

    final prevStory = await getStoryById(randomId);
    stories.insert(0, prevStory);
    currentStoryIndex++; // Adjust current index since we inserted at beginning
    notifyListeners();
  }

  Future<void> nextStory() async {
    if (currentStoryIndex < stories.length - 1) {
      currentStoryIndex++;
      loadStory(currentStoryIndex);
      // Preload next story if we're near the end
      if (currentStoryIndex >= stories.length - 2) {
        await preloadNextStory();
      }
    }
  }

  Future<void> previousStory() async {
    if (currentStoryIndex > 0) {
      currentStoryIndex--;
      loadStory(currentStoryIndex);
      // Preload previous story if we're near the beginning
      if (currentStoryIndex <= 1) {
        await preloadPreviousStory();
      }
    }
  }

  void loadStory(int index) {
    story = stories[index];
    currentImageIndex = 0;
    if (story['type'] == "video") {
      loadVideo();
    }
    notifyListeners();
  }

  void nextImage() {
    if (story['img_urls'].length > 1) {
      if (currentImageIndex == story['img_urls'].length - 1) {
        currentImageIndex = 0;
      } else {
        currentImageIndex = currentImageIndex + 1;
      }
      notifyListeners();
    }
  }

  void prevImage() {
    if (story['img_urls'].length > 1) {
      if (currentImageIndex == 0) {
        currentImageIndex = story['img_urls'].length - 1;
      } else {
        currentImageIndex = currentImageIndex - 1;
      }
      notifyListeners();
    }
  }

  Future<void> close() async {
    if (controller != null && controller!.value.isInitialized) {
      await controller?.dispose();
    }
    controller = null;
    initializeVideoPlayerFuture = null;
  }

  Future<void> loadVideo() async {
    if (controller != null) {
      await controller?.dispose();
    }

    if (story['video_url'].isNotEmpty) {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(story['video_url']),
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
}
