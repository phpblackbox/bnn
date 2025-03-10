import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/services/notification_service.dart';
import 'package:bnn/services/post_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCommentProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final NotificationService notificationService = NotificationService();

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _isSentMsg = false;
  bool get isSentMsg => _isSentMsg;
  set isSentMsg(bool value) {
    _isSentMsg = value;
  }

  int _postId = 0;
  int get postId => _postId;
  set postId(int value) {
    _postId = value;
  }

  List<dynamic> _parentComments = Constants.fakeParentComments;
  List<dynamic> get parentComments => _parentComments;

  Map<String, List<dynamic>> _childCommentsMap = {};
  Map<String, List<dynamic>> get childCommentsMap => _childCommentsMap;

  List<String> _expandedComments = [];
  List<String> get expandedComments => _expandedComments;

  late int parentId = 0;

  Future<void> getParentComments(int postId) async {
    loading = true;
    try {
      _parentComments = await _postService.getParentComments(postId);
      loading = false;
    } catch (e) {
      print('Error fetching comments in provider: $e');
    } finally {
      loading = false;
    }
  }

  Future<List<dynamic>> getChildComments(int postId, String parentId) async {
    try {
      final data = await _postService.getChildComments(postId, parentId);
      return data;
    } catch (e) {
      print('Error fetching comments in provider: $e');
      rethrow;
    }
  }

  Future<void> toggleChildComments(int postId, String parentId) async {
    if (_expandedComments.contains(parentId)) {
      _expandedComments.remove(parentId);
    } else {
      final childComments = await getChildComments(postId, parentId);
      _childCommentsMap[parentId] = childComments;
      _expandedComments.add(parentId);
    }
    notifyListeners();
  }

  Future<bool> togglePostLike(int postCommentId) async {
    final bool status = await _postService.togglePostLike(postCommentId);
    notifyListeners();
    return status;
  }

  Future<void> sendPostComment(
      int postId, String value, ProfilesModel me) async {
    final res = await _postService.sendPostComment(postId, parentId, value);

    final _supabase = Supabase.instance.client;
    final nowString = await _supabase.rpc('get_server_time');
    DateTime now = DateTime.parse(nowString);
    DateTime createdAt = DateTime.parse(res["created_at"]);
    Duration difference = now.difference(createdAt);
    final meId = _supabase.auth.currentUser?.id;

    dynamic temp = {
      "id": res["id"],
      "author_id": meId,
      "name": '${me.firstName} ${me.lastName}',
      "post_id": postId,
      "parent_id": parentId,
      "content": value,
      "likes": res["likes"],
      "created_at": res["created_at"],
      "time": Constants().formatDuration(difference),
      "profiles": {
        "avatar": me.avatar,
        "first_name": me.firstName,
        "last_name": me.lastName,
      }
    };

    if (parentId == 0) {
      parentComments.insert(0, temp);
    } else {
      final childComments = await getChildComments(postId, parentId.toString());

      _childCommentsMap[parentId.toString()] = childComments;
      _expandedComments.add(parentId.toString());
    }
    notifyListeners();

    final post = await _postService.getPostById(postId);

    if (post.isNotEmpty && meId != post['author_id']) {
      await notificationService.upsertCommentNotification(
          post['author_id'], 'comment post', postId, value);
    }

    parentId = 0;
    isSentMsg = true;
    this.postId = postId;
    notifyListeners();
  }
}
