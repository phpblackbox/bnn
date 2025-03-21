import 'dart:io';
import 'package:bnn/models/reel_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bnn/services/profile_service.dart';

class ReelService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  Future<String> uploadVideo(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    String filename = '${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _supabase.storage.from('story').uploadBinary(filename, bytes);

    return _supabase.storage.from('story').getPublicUrl(filename);
  }

  Future<void> createReel(String userId, String videoUrl) async {
    await _supabase.from('stories').upsert({
      'author_id': userId,
      'video_url': videoUrl,
      'type': 'video',
    });
  }

  Future<int> getRandomReelId() async {
    final reelId = await _supabase.rpc('get_random_reel_id') ?? 0;
    return reelId;
  }

  Future<ReelModel?> getReelById(int reelId) async {
    final reelRecord = await _supabase
        .from('stories')
        .select()
        .eq("id", reelId)
        .eq('type', 'video')
        .single();

    if (reelRecord.isNotEmpty) {
      final reel = ReelModel.fromJson(reelRecord);
      reel.userInfo = await _profileService.getUserProfileById(reel.authorId);
      reel.likes = await getReelLikesCount(reelId);
      reel.bookmarks = await getReelBookmarksCount(reelId);
      reel.comments = await getReelCommentsCount(reelId);
      reel.share = 2;

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
}
