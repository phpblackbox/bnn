import 'dart:typed_data';

import 'package:bnn/services/auth_service.dart';
import 'package:bnn/services/notification_service.dart';
import 'package:bnn/services/post_service.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PostProvider extends ChangeNotifier {
  final PostService postService = PostService();
  final NotificationService notificationService = NotificationService();
  final AuthService _authService = AuthService();
  List<dynamic>? posts = [];
  List<dynamic>? comments = [];
  bool _loading = false;
  String? errorMessage;
  String? _currentContext; // Track current context (home, profile, etc.)
  String? get currentContext => _currentContext;

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _loadingMore = true;
  bool get loadingMore => _loadingMore;

  set loadingMore(bool value) {
    _loadingMore = value;
    notifyListeners();
  }

  int offset = 0;
  final int _limit = 5;

  // Add reset method to clear state
  void reset() {
    posts = [];
    comments = [];
    offset = 0;
    _loading = false;
    _loadingMore = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getPostInfo(int postId) async {
    final post = await postService.getPostById(postId);
    return post;
  }

  Future<void> loadPosts(
      {String? userId, bool? bookmark, String? currentUserId}) async {
    // Reset if context changed
    String newContext = userId != null
        ? 'profile_$userId'
        : (bookmark == true ? 'bookmarks' : 'home');
    if (_currentContext != newContext) {
      reset();
      _currentContext = newContext;
    }

    errorMessage = null;
    loadingMore = true;

    try {
      List<dynamic> newItem = await postService.getPosts(
          offset: offset,
          limit: _limit,
          userId: userId,
          bookmark: bookmark,
          currentUserId: currentUserId);

      if (posts == null) {
        posts = [];
      }

      // Clear existing posts if this is a new context
      if (offset == 0) {
        posts!.clear();
      }

      for (var element in newItem) {
        final existingPostIndex =
            posts!.indexWhere((post) => post['id'] == element['id']);
        if (existingPostIndex == -1) {
          posts!.add(element);
        }
      }

      offset = offset + _limit;
      loading = false;
      newItem = await postService.getPostsInfo(newItem);

      for (var newPost in newItem) {
        final existingPostIndex =
            posts!.indexWhere((post) => post['id'] == newPost['id']);
        if (existingPostIndex != -1) {
          posts![existingPostIndex] = newPost;
        }
      }

      loading = false;
      loadingMore = false;
    } catch (e) {
      errorMessage = e.toString();
      loading = false;
      loadingMore = false;
    } finally {
      loading = false;
      loadingMore = false;
    }
  }

  Future<void> toggleLike(int postId, String authorId, int index) async {
    final bool status = await postService.toggleLike(postId);
    posts?[index]['likes'] += status ? -1 : 1;
    notifyListeners();
    await notificationService.upsert(authorId, 'like post', postId);
  }

  Future<void> toggleBookmark(int postId, int index) async {
    final bool status = await postService.toggleBookmark(postId);
    posts?[index]['bookmarks'] += status ? -1 : 1;
    notifyListeners();
  }

  Future<void> increaseCountComment(int postId) async {
    posts?.forEach((post) {
      if (post['id'] == postId) {
        post['comments'] += 1;
      }
    });
    notifyListeners();
  }

  Future<void> deleteCountComment(int postId) async {
    posts?.forEach((post) {
      if (post['id'] == postId) {
        post['comments'] -= 1;
      }
    });
    notifyListeners();
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
    return 'Unknown';
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

  Future<void> newPost(
      BuildContext context, List<XFile> _selected, String content) async {
    if (_selected.isNotEmpty) {
      loading = true;

      List<String> imgUrls = [];
      try {
        final userId = _authService.getCurrentUser()?.id;
        String publicUrl = "";
        for (var image in _selected) {
          if (getFileType(image.path) == "image") {
            publicUrl = await postService.uploadImage(userId!, image.path);
          } else {
            publicUrl = await postService.uploadVideo(image.path);
          }
          imgUrls.add(publicUrl);
        }
        await postService.newPost(userId!, content, imgUrls);
      } catch (e) {
        CustomToast.showToastDangerTop(
            context, 'Error uploading image: ${e.toString()}');
      }
    }
    loading = false;
  }

  Future<void> deletePost(int postId) async {
    await postService.deletePost(postId);
    posts!.removeWhere((post) => post["id"] == postId);
    notifyListeners();
  }

  Future<bool> hasSharedPost(int postId, String authorId, String userId) async {
    return await postService.hasSharedPost(postId, authorId, userId);
  }

  Future<Map<String, dynamic>?> addShare(
      int postId, String authorId, String userId, String type) async {
    return await postService.addShare(postId, authorId, userId, type);
  }

  Future<dynamic> getPostById(int postId) async {
    try {
      final response = await postService.getPostById(postId);
      final postInfo = await postService.getPostsInfo([response]);
      return postInfo[0];
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }
}
