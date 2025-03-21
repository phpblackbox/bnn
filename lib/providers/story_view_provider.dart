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
    "timeDiff": "1",
  };

  List<dynamic> stories = [];

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
    final temp = await getStoryById(storyId);
    stories.add(temp);
    loadStory(0);
    await nextStory();
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

  // Future<void> getStoriesByUserId(String userId) async {
  //   try {
  //     currentStoryIndex = 0;
  //     story = {};
  //     loading = true;
  //     _data = await _storyService.getStoriesByUserId(userId);
  //     if (_data.isNotEmpty) {
  //       for (int i = 0; i < _data.length; i++) {
  //         final nowString = await _storyService.getServerTime();
  //         DateTime now = DateTime.parse(nowString);
  //         DateTime createdAt = DateTime.parse(_data[i]["created_at"]);
  //         Duration difference = now.difference(createdAt);
  //         _data[i]['timeDiff'] = Constants().formatDuration(difference);
  //       }
  //       story = _data[currentStoryIndex];
  //     }
  //     loading = false;
  //   } catch (e) {
  //     loading = false;
  //     rethrow;
  //   } finally {
  //     loading = false;
  //   }
  // }

  Future<void> nextStory() async {
    int randomId;
    do {
      randomId = await _storyService.getRandomStoryId();
    } while (stories.any((story) => story['id'] == randomId));
    final temp = await getStoryById(randomId);
    stories.add(temp);
    notifyListeners();
  }

  void loadStory(int index) {
    story = stories[index];
    print(story);
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
