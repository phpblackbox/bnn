import 'package:bnn/screens/home/create_story.dart';
import 'package:bnn/services/auth_service.dart';
import 'package:bnn/services/reel_service.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/story_service.dart';

class StoryProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StoryService _storyService = StoryService();
  final ReelService _reelService = ReelService();
  List<Map<String, dynamic>> stories = [];
  Map<String, dynamic> story = {};
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  bool _loading = false;
  bool get loading => _loading;
  List<XFile> get selectedImages => _selectedImages;

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

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        _selectedImages = pickedFiles;
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
        _selectedImages.add(image);
        notifyListeners();
      }
    } catch (e) {
      CustomToast.showToastDangerTop(
          context, 'No camera found. Please check your device settings.');
    }
  }

  Future<void> uploadImages(BuildContext context) async {
    if (_selectedImages.isNotEmpty) {
      loading = true;

      List<String> imgUrls = [];
      try {
        final userId = _authService.getCurrentUser()?.id;

        for (var image in _selectedImages) {
          String publicUrl =
              await _storyService.uploadImage(userId!, image.path);
          imgUrls.add(publicUrl);
        }

        Map<String, dynamic> newStory =
            await _storyService.createStoryImage(userId!, imgUrls);

        loading = false;
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateStory(storyId: newStory["id"])));
      } catch (e) {
        CustomToast.showToastDangerTop(
            context, 'Error uploading image: ${e.toString()}');
      }
    }
  }

  Future<void> uploadVideo(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      String filePath = result.files.single.path!;

      loading = true;
      String videoUrl = await _reelService.uploadVideo(filePath);

      final userId = _authService.getCurrentUser()?.id;
      await _reelService.createReel(userId!, videoUrl);

      loading = false;
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
