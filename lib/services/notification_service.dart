import 'package:bnn/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<dynamic>> getNotificationsByUserId(String userId) async {
    final data = await _supabase
        .from('notifications')
        .select('*, profiles(username, avatar, first_name, last_name)')
        .eq('is_read', false)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (data.isNotEmpty) {
      try {
        for (int i = 0; i < data.length; i++) {
          final nowString = await _supabase.rpc('get_server_time');
          DateTime now = DateTime.parse(nowString);
          DateTime createdAt = DateTime.parse(data[i]["created_at"]);
          Duration difference = now.difference(createdAt);
          data[i]['timeDiff'] = Constants().formatDuration(difference);

          data[i]['action'] = "";
          switch (data[i]['action_type']) {
            case "follow":
              data[i]['action'] = "Followed you";
              break;

            case "like post":
              data[i]['action'] = "Liked your post";
              break;

            case "like story":
              data[i]['action'] = "Liked your story";
              break;

            case "like reel":
              data[i]['action'] = "Liked your reel";
              break;

            case "comment post":
              data[i]['action'] = "Commented on your post";
              break;

            case "comment story":
              data[i]['action'] = "Message on your story";
              break;

            case "comment reel":
              data[i]['action'] = "Commented on your reel";
              break;
          }
        }
      } catch (e) {
        print('Caught error: $e');
      }
    }

    return data;
  }

  Future<void> upsert(String authorId, String action, int postId) async {
    final meId = _supabase.auth.currentUser?.id;
    if (meId != authorId) {
      final noti = await _supabase
          .from('notifications')
          .select()
          .eq('actor_id', meId!)
          .eq('user_id', authorId)
          .eq('action_type', action)
          .eq('target_id', postId);

      if (noti.isEmpty) {
        await _supabase.from('notifications').upsert({
          'actor_id': meId,
          'user_id': authorId,
          'action_type': action,
          'target_id': postId,
        });
      }
    }
  }

  Future<void> upsertCommentNotification(
      String userId, String action, int postId, String content) async {
    final meId = _supabase.auth.currentUser?.id;
    if (meId != userId) {
      await _supabase.from('notifications').upsert({
        'actor_id': meId,
        'user_id': userId,
        'action_type': action,
        'target_id': postId,
        'content': content,
      });
    }
  }
}
