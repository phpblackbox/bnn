import 'package:bnn/services/story_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';

class StoryViewProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();

  List<dynamic> _data = [];
  List<dynamic> get data => _data;
  dynamic _story = {
    "img_urls": [],
    "id": 0,
    "username": "",
    "avatar": "",
    "authour_id": "",
    "created_at": '',
    "comments": "",
  };
  dynamic get story => _story;
  set story(dynamic value) {
    _story = value;
    notifyListeners();
  }

  int _currentStoryIndex = 0;
  int get currentStoryIndex => _currentStoryIndex;
  set currentStoryIndex(int value) {
    _currentStoryIndex = value;
    notifyListeners();
  }

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> getStoriesByUserId(String userId) async {
    try {
      currentStoryIndex = 0;
      _story = {};
      loading = true;
      _data = await _storyService.getStoriesByUserId(userId);

      if (_data.isNotEmpty) {
        for (int i = 0; i < _data.length; i++) {
          final nowString = await _storyService.getServerTime();
          DateTime now = DateTime.parse(nowString);
          DateTime createdAt = DateTime.parse(_data[i]["created_at"]);
          Duration difference = now.difference(createdAt);
          _data[i]['timeDiff'] = Constants().formatDuration(difference);
        }

        _story = _data[currentStoryIndex];
      }
      loading = false;
    } catch (e) {
      loading = false;
      rethrow;
    } finally {
      loading = false;
    }
  }

  void nextStory() {
    if (_data.isNotEmpty) {
      _currentStoryIndex = (_currentStoryIndex + 1) % _data.length;
      _story = _data[_currentStoryIndex];
      _currentImageIndex = 0;
      notifyListeners();
    }
  }

  void previousStory() {
    if (_data.isNotEmpty) {
      _currentStoryIndex =
          (_currentStoryIndex - 1 + _data.length) % _data.length;
      _story = _data[_currentStoryIndex];
      _currentImageIndex = 0;
      notifyListeners();
    }
  }

  void nextImage() {
    if (_story['img_urls'].isNotEmpty &&
        _currentImageIndex < _story['img_urls'].length - 1) {
      _currentImageIndex++;
      notifyListeners();
    }
  }
}
