import 'package:bnn/services/notification_service.dart';
import 'package:bnn/services/post_service.dart';
import 'package:flutter/material.dart';

class PostProvider extends ChangeNotifier {
  final PostService postService = PostService();
  final NotificationService notificationService = NotificationService();
  List<dynamic>? posts = [];
  List<dynamic>? comments = [];
  bool _loading = false;
  String? errorMessage;

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> loadPosts(
      {String? userId, bool? bookmark, String? currentUserId}) async {
    loading = true;
    errorMessage = null;
    try {
      posts = await postService.getCustomePosts(
          userId: userId, bookmark: bookmark, currentUserId: currentUserId);
      loading = false;
    } catch (e) {
      errorMessage = e.toString();
      loading = false;
    } finally {
      loading = false;
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
}
