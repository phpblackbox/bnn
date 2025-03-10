import 'dart:io';

import 'package:bnn/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getPostById(int postId) async {
    final data =
        await _supabase.from('posts').select().eq('id', postId).single();
    return data;
  }

  Future<List<dynamic>> getPosts() async {
    return await _supabase.from('view_posts').select();
  }

  Future<List<dynamic>> getPostsBookmarkByUserId(String? userId) async {
    return await _supabase.rpc('get_post_bookmarks_by_author', params: {
      'param_user_id': userId,
    });
  }

  Future<List<dynamic>> getPostsByUserId({String? userId}) async {
    return await _supabase.rpc('get_posts_by_userid', params: {
      'param_user_id': userId,
    });
  }

  Future<List<dynamic>> getCustomePosts(
      {String? userId, bool? bookmark, String? currentUserId}) async {
    try {
      List<dynamic> posts = [];
      List<Map<String, dynamic>> data = [];

      if (bookmark == true) {
        data = await _supabase.rpc('get_post_bookmarks_by_author', params: {
          'param_user_id': currentUserId,
        });

        await _supabase.rpc('get_post_bookmarks_by_author', params: {
          'param_user_id': currentUserId,
        });
      } else {
        if (userId != null) {
          data = await _supabase.rpc('get_posts_by_userid', params: {
            'param_user_id': userId,
          });
        } else {
          data = await _supabase.from('view_posts').select();
        }
      }

      if (data.isNotEmpty) {
        posts = data;
        for (int i = 0; i < posts.length; i++) {
          dynamic res =
              await _supabase.rpc('get_count_post_likes_by_postid', params: {
                    'param_post_id': posts[i]["id"],
                  }) ??
                  0;

          posts[i]["likes"] = res;

          res = await _supabase
              .rpc('get_count_post_bookmarks_by_postid', params: {
            'param_post_id': posts[i]["id"],
          });

          posts[i]["bookmarks"] = res;

          res =
              await _supabase.rpc('get_count_post_comments_by_postid', params: {
            'param_post_id': posts[i]["id"],
          });

          posts[i]["comments"] = res;
          posts[i]["share"] = 2;
          posts[i]['name'] =
              '${posts[i]["first_name"]} ${posts[i]["last_name"]}';

          final nowString = await _supabase.rpc('get_server_time');
          DateTime now = DateTime.parse(nowString);
          DateTime createdAt = DateTime.parse(posts[i]["created_at"]);
          Duration difference = now.difference(createdAt);
          posts[i]["time"] = Constants().formatDuration(difference);
        }
      }
      return posts;
    } catch (e) {
      print('Caught error: $e');
      if (e.toString().contains("JWT expired")) {
        // Handle JWT expiration (e.g., sign out, navigate to login)
        return Future.error(e); // Re-throw the error for the provider to handle
      }
      return Future.error(e); // Re-throw other errors
    }
  }

  Future<List<dynamic>> getParentComments(int postId) async {
    try {
      final data = await _supabase
          .from('post_comments')
          .select('*, profiles(username, avatar, first_name, last_name)')
          .eq('parent_id', 0)
          .eq('post_id', postId)
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
                .rpc('get_count_post_comment_likes_by_postid', params: {
              'param_post_comment_id': data[i]["id"],
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

  Future<List<dynamic>> getChildComments(int postId, String parentId) async {
    try {
      final data = await _supabase
          .from('post_comments')
          .select('*, profiles(username, avatar, first_name, last_name)')
          .eq('parent_id', parentId)
          .eq('post_id', postId)
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
                .rpc('get_count_post_comment_likes_by_postid', params: {
              'param_post_comment_id': data[i]["id"],
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

  Future<bool> toggleLike(int postId) async {
    final meId = _supabase.auth.currentUser?.id;
    final response = await _supabase
        .from('post_likes')
        .select()
        .eq('author_id', meId!)
        .eq('post_id', postId)
        .maybeSingle();

    bool status = true;

    if (response != null) {
      status = response['is_like'] ?? false;
      await _supabase
          .from('post_likes')
          .update({'is_like': !status})
          .eq('author_id', meId)
          .eq('post_id', postId);
    } else {
      await _supabase.from('post_likes').upsert({
        'author_id': meId,
        'post_id': postId,
        'is_like': status,
      });
      status = false;
    }

    return status; // return like or dislike
  }

  Future<bool> toggleBookmark(int postId) async {
    final meId = _supabase.auth.currentUser?.id;
    final response = await _supabase
        .from('post_bookmarks')
        .select()
        .eq('author_id', meId!)
        .eq('post_id', postId)
        .maybeSingle();

    bool status = true;

    if (response != null) {
      status = response['is_bookmark'] ?? false;
      await _supabase
          .from('post_bookmarks')
          .update({'is_bookmark': !status})
          .eq('author_id', meId)
          .eq('post_id', postId);
    } else {
      await _supabase.from('post_bookmarks').upsert({
        'author_id': meId,
        'post_id': postId,
        'is_bookmark': status,
      });
      status = false;
    }

    return status; // return bookmark or not
  }

  Future<bool> togglePostLike(int postCommentId) async {
    final meId = _supabase.auth.currentUser?.id;
    final response = await _supabase
        .from('post_comment_likes')
        .select()
        .eq('author_id', meId!)
        .eq('post_comment_id', postCommentId)
        .maybeSingle();

    bool status = true;

    if (response != null) {
      status = response['is_like'] ?? false;
      await _supabase
          .from('post_comment_likes')
          .update({'is_like': !status})
          .eq('author_id', meId)
          .eq('post_id', postCommentId);
    } else {
      await _supabase.from('post_comment_likes').upsert({
        'author_id': meId,
        'post_id': postCommentId,
        'is_like': status,
      });
    }

    return status; // return like or dislike
  }

  Future<dynamic> sendPostComment(
      int postId, int parentId, String value) async {
    final meId = _supabase.auth.currentUser?.id;

    final data = await _supabase
        .from('post_comments')
        .upsert({
          'author_id': meId,
          'post_id': postId,
          'parent_id': parentId,
          'content': value,
        })
        .select()
        .single();

    return data;
  }

  Future<String> uploadImage(String userId, String imagePath) async {
    String randomNumStr = Constants().generateRandomNumberString(8);
    final filename = '${userId}_$randomNumStr.png';
    final fileBytes = await File(imagePath).readAsBytes();

    await _supabase.storage.from('story').uploadBinary(
          filename,
          fileBytes,
        );

    return _supabase.storage.from('story').getPublicUrl(filename);
  }

  Future<void> newPost(
      String userId, String content, List<String> imgUrls) async {
    await _supabase.from('posts').upsert({
      'author_id': userId,
      'content': content,
      'img_urls': imgUrls,
    });
  }
}
