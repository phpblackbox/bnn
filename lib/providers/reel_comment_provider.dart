import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/services/notification_service.dart';
import 'package:bnn/services/reel_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReelCommentProvider extends ChangeNotifier {
  final ReelService _reelService = ReelService();
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

  bool _isDeleteMsg = false;
  bool get isDeleteMsg => _isDeleteMsg;
  set isDeleteMsg(bool value) {
    _isDeleteMsg = value;
  }

  int _reelId = 0;
  int get reelId => _reelId;
  set reelId(int value) {
    _reelId = value;
  }

  List<dynamic> _parentComments = Constants.fakeParentComments;
  List<dynamic> get parentComments => _parentComments;

  Map<String, List<dynamic>> _childCommentsMap = {};
  Map<String, List<dynamic>> get childCommentsMap => _childCommentsMap;

  List<String> _expandedComments = [];
  List<String> get expandedComments => _expandedComments;

  late int parentId = 0;

  Future<void> getParentComments(int reelId) async {
    loading = true;
    try {
      _parentComments = await _reelService.getParentComments(reelId);
      loading = false;
    } catch (e) {
      print('Error fetching comments in provider: $e');
    } finally {
      loading = false;
    }
  }

  Future<List<dynamic>> getChildComments(int reelId, String parentId) async {
    try {
      final data = await _reelService.getChildComments(reelId, parentId);
      return data;
    } catch (e) {
      print('Error fetching comments in provider: $e');
      rethrow;
    }
  }

  Future<void> toggleChildComments(int reelId, String parentId) async {
    if (_expandedComments.contains(parentId)) {
      _expandedComments.remove(parentId);
    } else {
      final childComments = await getChildComments(reelId, parentId);
      _childCommentsMap[parentId] = childComments;
      _expandedComments.add(parentId);
    }
    notifyListeners();
  }

  Future<bool> toggleReelLike(int reelCommentId) async {
    final bool status = await _reelService.toggleCommentLike(reelCommentId);
    notifyListeners();
    return status;
  }

  Future<void> sendReelComment(
      int reelId, String value, ProfilesModel me) async {
    final res = await _reelService.sendReelComment(reelId, parentId, value);

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
      "reel_id": reelId,
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
      final childComments = await getChildComments(reelId, parentId.toString());

      _childCommentsMap[parentId.toString()] = childComments;
      _expandedComments.add(parentId.toString());
    }
    notifyListeners();

    final reel = await _reelService.getReelById(reelId);

    if (reel != null && meId != reel.authorId) {
      await notificationService.upsertCommentNotification(
          reel.authorId, 'comment reel', reelId, value);
    }

    parentId = 0;
    isSentMsg = true;
    this.reelId = reelId;
    notifyListeners();
  }

  Future<void> deleteComment(int commentId, int reelId) async {
    await _reelService.deleteComment(commentId);

    _parentComments.removeWhere((comment) => comment['id'] == commentId);

    for (var key in _childCommentsMap.keys) {
      final value = _childCommentsMap[key];
      final updatedChildComments =
          value!.where((comment) => comment['id'] != commentId).toList();
      if (updatedChildComments.isEmpty) {
        _childCommentsMap.remove(key);
        _expandedComments.removeWhere((element) => element == key);

        break;
      } else {
        _childCommentsMap[key] = updatedChildComments;
      }
    }

    this.reelId = reelId;
    isDeleteMsg = true;

    notifyListeners();
  }
}
