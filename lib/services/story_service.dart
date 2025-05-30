import 'dart:io';
import 'package:bnn/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStories() async {
    try {
      final data = await _supabase.from('view_stories').select();
      return data.isNotEmpty ? List<Map<String, dynamic>>.from(data) : [];
    } catch (e) {
      print('Caught error: $e');
      if (e.toString().contains("JWT expired")) {
        await _supabase.auth.signOut();
        throw Exception("JWT expired");
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStoryById(int storyId) async {
    try {
      final data = await _supabase
          .from('stories')
          .select('*, profiles(id, avatar, username, first_name, last_name)')
          .eq('id', storyId)
          .eq('is_published', true)
          .single();
      return data;
    } catch (e) {
      print('Caught error: $e');
      if (e.toString().contains("JWT expired")) {
        await _supabase.auth.signOut();
        throw Exception("JWT expired");
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLatestStories() async {
    try {
      final data = await _supabase
          .from('stories')
          .select('*, profiles(id, avatar, username, first_name, last_name)')
          .eq('is_published', true)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(Duration(hours: Constants.storyDuration))
                  .toIso8601String())
          .order('id', ascending: false);
      return data;
    } catch (e) {
      print('Caught error: $e');
      if (e.toString().contains("JWT expired")) {
        await _supabase.auth.signOut();
        throw Exception("JWT expired");
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getStoriesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('stories')
          .select('*, profiles(id, avatar, username, first_name, last_name)')
          .eq('author_id', userId)
          .eq('is_published', true)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(Duration(hours: Constants.storyDuration))
                  .toIso8601String())
          .order('id', ascending: false);

      return response;
    } catch (e) {
      print('Caught error: $e');
      if (e.toString().contains("JWT expired")) {
        await _supabase.auth.signOut();
      }
      rethrow;
    }
  }

  Future<String> getServerTime() async {
    return await _supabase.rpc('get_server_time');
  }

  Future<void> sendNotification(
      String actorId, String userId, String content) async {
    await _supabase.from('notifications').insert({
      'actor_id': actorId,
      'user_id': userId,
      'action_type': 'comment story',
      'content': content,
    });
  }

  Future<Map<String, dynamic>> createStoryImage(
      String userId, List<String> mediaUrls) async {
    final newStory = await _supabase.from('stories').upsert(
        {'author_id': userId, 'media_urls': mediaUrls}).select();

    return newStory[0];
  }

  Future<void> createStoryContent(int storyId, String content) async {
    await _supabase.from('stories').upsert({
      'id': storyId,
      'content': content,
    }).select();
    return;
  }

  Future<String> uploadStoryItem(String userId, String imagePath, String type) async {
    String randomNumStr = Constants().generateRandomNumberString(8);
    final filename = '${userId}_$randomNumStr.$type';
    final fileBytes = await File(imagePath).readAsBytes();

    await _supabase.storage.from('story').uploadBinary(
          filename,
          fileBytes,
        );

    return _supabase.storage.from('story').getPublicUrl(filename);
  }

  Future<int> getRandomStoryId() async {
    final storyId = await _supabase.rpc('get_random_story_id') ?? 0;
    return storyId;
  }

  Future<int?> getNextStoryId(int? currentStoryId) async {
    try {
      if (currentStoryId == null) {
        // get the latest story id
        final storyRecord = await _supabase
            .from('stories')
            .select()
            .order('id', ascending: false)
            .limit(1)
            .single();
        return storyRecord['id'];
      }
      final storyRecord = await _supabase
          .from('stories')
          .select()
          .lt('id', currentStoryId)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(Duration(hours: Constants.storyDuration))
                  .toIso8601String())
          .order('id', ascending: false)
          .limit(1)
          .single();
      return storyRecord['id'];
    } catch (e) {
      // If no story is found or other error occurs, return null
      return null;
    }
  }

  Future<int> getStoryLatestId() async {
    final storyRecord = await _supabase
        .from('stories')
        .select()
        .gte(
            'created_at',
            DateTime.now()
                .subtract(Duration(hours: Constants.storyDuration))
                .toIso8601String())
        .order('id', ascending: false)
        .limit(1)
        .single();
    return storyRecord['id'];
  }

  Future<void> deleteStory(int storyId) async {
    try {
      await _supabase.from('stories').delete().eq('id', storyId);
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }
}
