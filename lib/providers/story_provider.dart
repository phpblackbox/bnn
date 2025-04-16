import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/story/create_story.dart';
import 'package:bnn/services/auth_service.dart';
import 'package:bnn/services/reel_service.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:image_picker/image_picker.dart';
import '../services/story_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:get_thumbnail_video/video_thumbnail.dart';

class StoryProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StoryService _storyService = StoryService();
  final ReelService _reelService = ReelService();
  List<Map<String, dynamic>> stories = [];
  Map<String, dynamic> story = {};
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedMediaList = [];

  bool _loading = false;
  bool get loading => _loading;
  List<XFile> get selectedImages => _selectedMediaList;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> getStories() async {
    _loading = true;
    notifyListeners();

    try {
      stories = await _storyService.getStories();
    } catch (e) {
      print('Error fetching stories: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createStoryContent(int storyId, String content) async {
    await _storyService.createStoryContent(storyId, content);
  }

  Future<void> getStoryById(int storyId) async {
    _loading = true;
    notifyListeners();

    try {
      story = await _storyService.getStoryById(storyId);
    } catch (e) {
      print('Error fetching stories: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> pickMedia() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultipleMedia();
      if (pickedFiles.isNotEmpty) {
        _selectedMediaList = pickedFiles;
        notifyListeners();
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> cameraImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        _selectedMediaList.add(image);
        notifyListeners();
      }
    } catch (e) {
      CustomToast.showToastDangerTop(
          context, 'No camera found. Please check your device settings.');
    }
  }

  Future<void> uploadStories(BuildContext context) async {
    if (_selectedMediaList.isNotEmpty) {
      loading = true;

      List<String> mediaUrls = [];
      try {
        final userId = _authService.getCurrentUser()?.id;

        for (var file in _selectedMediaList) {
          String publicUrl;
          if (getFileType(file.path) == 'image') {
            publicUrl = await _storyService.uploadStoryItem(userId!, file.path, 'png');
          } else if (getFileType(file.path) == 'video') {
            publicUrl = await _storyService.uploadStoryItem(userId!, file.path, 'mp4');
          } else {
            continue; // skip unsupported files
          }
          mediaUrls.add(publicUrl);
        }

        Map<String, dynamic> newStory =
            await _storyService.createStoryImage(userId!, mediaUrls);

        loading = false;
        Navigator.pop(context);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => CreateStory(storyId: newStory["id"])));
        Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => Home()));
      } catch (e) {
        loading = false;
        Navigator.pop(context);
        CustomToast.showToastDangerTop(
            context, 'Error uploading image: ${e.toString()}');
      }
    }
  }

  Future<File?> pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? videoFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (videoFile != null) {
        return File(videoFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  Future<void> uploadReel(
      BuildContext context, Function showLoadingModal) async {
    File? videoFile = await pickVideo();

    if (videoFile != null) {
      showLoadingModal();
      loading = true;

      try {
        String videoUrl = await _reelService.uploadVideo(videoFile.path);
        final userId = _authService.getCurrentUser()?.id;
        await _reelService.createReel(userId!, videoUrl);

        loading = false;
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        loading = false;
        Navigator.pop(context);
        CustomToast.showToastDangerTop(
            context, 'Error uploading video: ${e.toString()}');
      }
    }
  }

  String getFileType(String path) {
    final fileExtension = path.split('.').last.toLowerCase();
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff'];
    final videoExtensions = ['mp4', 'mov', 'avi', 'flv', 'wmv', 'mkv'];

    if (imageExtensions.contains(fileExtension)) {
      return 'image';
    } else if (videoExtensions.contains(fileExtension)) {
      return 'video';
    }
    return 'unknown';
  }

  Future<Uint8List?> generateThumbnail(String videoPath) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.PNG,
      maxWidth: 128,
      quality: 75,
    );
    return uint8list;
  }
}
