import 'dart:io';
import 'package:bnn/models/reel_model.dart';
import 'package:bnn/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bnn/services/profile_service.dart';

class ReelService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  Future<String> uploadVideo(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    String filename = '${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _supabase.storage.from('reels').uploadBinary(filename, bytes);

    return _supabase.storage.from('reels').getPublicUrl(filename);
  }

  Future<void> createReel(String userId, String videoUrl) async {
    await _supabase.from('reels').upsert({
      'author_id': userId,
      'video_url': videoUrl,
    });
  }

  Future<int> getRandomReelId() async {
    final reelId = await _supabase.rpc('get_random_reel_id') ?? 0;
    return reelId;
  }

  Future<int> getLatestReelId(int currentReelId) async {
    if (currentReelId == 0) {
      final reelRecord = await _supabase
          .from('reels')
          .select()
          .order('id', ascending: false)
          .limit(1)
          .single();
      final reelId = reelRecord['id'];
      return reelId;
    } else {
      final reelRecord = await _supabase
          .from('reels')
          .select()
          .lt('id', currentReelId)
          .order('id', ascending: false)
          .limit(1)
          .single();
      final reelId = reelRecord['id'];
      return reelId;
    }
  }

  Future<List<dynamic>> getParentComments(int reelId) async {
    try {
      final data = await _supabase
          .from('reel_comments')
          .select('*, profiles(username, avatar, first_name, last_name)')
          .eq('parent_id', 0)
          .eq('reel_id', reelId)
          .order('created_at', ascending: false);

      for (int i = 0; i < data.length; i++) {
        final nowString = await _supabase.rpc('get_server_time');
        DateTime now = DateTime.parse(nowString);
        DateTime createdAt = DateTime.parse(data[i]["created_at"]);

        Duration difference = now.difference(createdAt);

        data[i]['name'] =
            '${data[i]["profiles"]["first_name"]} ${data[i]["profiles"]["last_name"]}';

        data[i]["time"] = Constants().formatDuration(difference);

        dynamic likes = await _supabase
                .rpc('get_count_reel_comment_likes_by_reelid', params: {
              'param_reel_comment_id': data[i]["id"],
            }) ??
            0;

        data[i]['likes'] = likes;
      }

      return data;
    } catch (e) {
      print('Caught error in CommentService: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getChildComments(int reelId, String parentId) async {
    try {
      final data = await _supabase
          .from('reel_comments')
          .select('*, profiles(username, avatar, first_name, last_name)')
          .eq('parent_id', parentId)
          .eq('reel_id', reelId)
          .order('created_at', ascending: false);

      for (int i = 0; i < data.length; i++) {
        final nowString = await _supabase.rpc('get_server_time');
        DateTime now = DateTime.parse(nowString);
        DateTime createdAt = DateTime.parse(data[i]["created_at"]);

        Duration difference = now.difference(createdAt);

        data[i]['name'] =
            '${data[i]["profiles"]["first_name"]} ${data[i]["profiles"]["last_name"]}';

        data[i]["time"] = Constants().formatDuration(difference);

        dynamic likes = await _supabase
                .rpc('get_count_reel_comment_likes_by_reelid', params: {
              'param_reel_comment_id': data[i]["id"],
            }) ??
            0;

        data[i]['likes'] = likes;
      }

      return data;
    } catch (e) {
      print('Caught error in CommentService: $e');
      rethrow;
    }
  }

  Future<dynamic> sendReelComment(
      int reelId, int parentId, String value) async {
    final meId = _supabase.auth.currentUser?.id;

    final data = await _supabase
        .from('reel_comments')
        .upsert({
          'author_id': meId,
          'reel_id': reelId,
          'parent_id': parentId,
          'content': value,
        })
        .select()
        .single();

    return data;
  }

  Future<ReelModel?> getReelById(int reelId) async {
    final reelRecord = await _supabase
        .from('reels')
        .select()
        .eq("id", reelId)
        .single();

    if (reelRecord.isNotEmpty) {
      final reel = ReelModel.fromJson(reelRecord);
      reel.userInfo = await _profileService.getUserProfileById(reel.authorId);
      reel.likes = await getReelLikesCount(reelId);
      reel.bookmarks = await getReelBookmarksCount(reelId);
      reel.comments = await getReelCommentsCount(reelId);
      reel.share = await _supabase.rpc('get_count_share', params: {
        'p_post_id': reelId,
        'p_type': 'reel',
      });
      ;

      final meId = _supabase.auth.currentUser?.id;
      if (meId == reel.authorId) {
        reel.isFriend = true;
      } else {
        reel.isFriend = await _profileService.isFriend(meId!, reel.authorId);
      }

      return reel;
    }
    return null;
  }

  Future<int> getReelLikesCount(int reelId) async {
    final count = await _supabase.rpc('get_count_reel_likes_by_reelid',
            params: {'param_reel_id': reelId}) ??
        0;
    return count;
  }

  Future<int> getReelBookmarksCount(int reelId) async {
    final count = await _supabase.rpc('get_count_reel_bookmarks_by_reelid',
            params: {'param_reel_id': reelId}) ??
        0;
    return count;
  }

  Future<int> getReelCommentsCount(int reelId) async {
    final count = await _supabase.rpc('get_count_reel_comments_by_reelid',
            params: {'param_reel_id': reelId}) ??
        0;
    return count;
  }

  Future<bool> toggleLikeReel(ReelModel reelData) async {
    final meId = _supabase.auth.currentUser!.id;
    final reelId = reelData.id;
    final response = await _supabase
        .from('reel_likes')
        .select()
        .eq('author_id', meId)
        .eq('reel_id', reelId)
        .maybeSingle();

    bool currentLikeStatus = true;
    if (response != null) {
      currentLikeStatus = response['is_like'];
      currentLikeStatus = !currentLikeStatus;
      await _supabase
          .from('reel_likes')
          .update({
            'is_like': currentLikeStatus,
          })
          .eq('author_id', meId)
          .eq('reel_id', reelId);
    } else {
      await _supabase.from('reel_likes').upsert({
        'author_id': meId,
        'reel_id': reelId,
        'is_like': currentLikeStatus,
      });
    }

    final noti = await _supabase
        .from('notifications')
        .select()
        .eq('actor_id', meId)
        .eq('user_id', reelData.authorId)
        .eq('action_type', 'like reel')
        .eq('target_id', reelData.id);

    if (meId != reelData.authorId && noti.isEmpty) {
      await _supabase.from('notifications').upsert({
        'actor_id': meId,
        'user_id': reelData.authorId,
        'action_type': 'like reel',
        'target_id': reelData.id,
      });
    }

    return currentLikeStatus;
  }

  Future<bool> toggleBookmarkReel(ReelModel reelData) async {
    final meId = _supabase.auth.currentUser!.id;
    final reelId = reelData.id;
    final response = await _supabase
        .from('reel_bookmarks')
        .select()
        .eq('author_id', meId)
        .eq('reel_id', reelId)
        .maybeSingle();

    bool currentBookmarksStatus = true;
    if (response != null) {
      currentBookmarksStatus = response['is_bookmark'];
      currentBookmarksStatus = !currentBookmarksStatus;
      await _supabase
          .from('reel_bookmarks')
          .update({
            'is_bookmark': currentBookmarksStatus,
          })
          .eq('author_id', meId)
          .eq('reel_id', reelId);
    } else {
      await _supabase.from('reel_bookmarks').upsert({
        'author_id': meId,
        'reel_id': reelId,
        'is_bookmark': currentBookmarksStatus,
      });
    }
    return currentBookmarksStatus;
  }

  Future<bool> toggleCommentLike(int reelCommentId) async {
    final meId = _supabase.auth.currentUser?.id;
    final response = await _supabase
        .from('reel_comment_likes')
        .select()
        .eq('author_id', meId!)
        .eq('reel_comment_id', reelCommentId)
        .maybeSingle();

    bool status = true;

    if (response != null) {
      status = response['is_like'] ?? false;
      await _supabase
          .from('reel_comment_likes')
          .update({'is_like': !status})
          .eq('author_id', meId)
          .eq('reel_comment_id', reelCommentId);
    } else {
      await _supabase.from('reel_comment_likes').upsert({
        'author_id': meId,
        'reel_comment_id': reelCommentId,
        'is_like': status,
      });

      status = false;
    }

    return status; // return like or dislike
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _supabase.from('reel_comments').delete().eq('id', commentId);
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
    } catch (e) {
      print('Error deleting post: $e');
    }
  }
}
