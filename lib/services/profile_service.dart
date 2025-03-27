import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profiles_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfilesModel?> getUserProfileById(String userId) async {
    try {
      final data =
          await _supabase.from('profiles').select().eq("id", userId).single();

      if (data.isNotEmpty) {
        return ProfilesModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<int> getCountFollowers(String userId) async {
    int count = await _supabase.rpc('get_count_follower', params: {
          'param_followed_id': userId,
        }) ??
        0;
    return count;
  }

  Future<int> getCountFollowing(String userId) async {
    int count = await _supabase.rpc('get_count_following', params: {
          'user_id': userId,
        }) ??
        0;
    return count;
  }

  Future<int> getCountViews(String userId) async {
    final temp = await _supabase
        .from('profiles')
        .select('views')
        .eq('id', userId)
        .single();
    return temp['views'];
  }

  Future<void> updateUserProfile(ProfilesModel profile) async {
    try {
      await _supabase.from('profiles').upsert(profile.toJson());
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<bool> isFriend(String userId1, String userId2) async {
    return await _supabase
        .rpc('is_friend', params: {'me_id': userId1, 'user_id': userId2});
  }

  Future<Map<String, dynamic>?> getFriendInfo(
      String meId, String userId) async {
    final res = await _supabase
        .from('relationships')
        .select()
        .eq('status', 'friend')
        .or('and(follower_id.eq.${meId},followed_id.eq.${userId}),and(follower_id.eq.${userId},followed_id.eq.${meId})')
        .maybeSingle();
    return res;
  }

  Future<int> getCountMutalFriends(String userA, String userB) async {
    return await _supabase.rpc('get_count_mutual_friends',
        params: {'usera': userA, 'userb': userB});
  }

  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    final meId = _supabase.auth.currentUser!.id;
    final res =
        await _supabase.rpc('get_followers', params: {'user_id': userId});

    List<Map<String, dynamic>> followers = [];

    if (res.isNotEmpty) {
      for (int i = 0; i < res.length; i++) {
        final mutal = await getCountMutalFriends(meId, res[i]["id"]);

        res[i]["mutal"] = '$mutal mutal friend';
        res[i]["name"] = '${res[i]["first_name"]}  ${res[i]["last_name"]}';

        followers.add(res[i]);
      }
    }
    return followers;
  }

  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    final meId = _supabase.auth.currentUser!.id;
    final res =
        await _supabase.rpc('get_following', params: {'user_id': userId});

    List<Map<String, dynamic>> following = [];

    if (res.isNotEmpty) {
      for (int i = 0; i < res.length; i++) {
        final mutal = await getCountMutalFriends(meId, res[i]["id"]);

        res[i]["mutal"] = '$mutal mutal friend';
        res[i]["name"] = '${res[i]["first_name"]}  ${res[i]["last_name"]}';

        following.add(res[i]);
      }
    }
    return following;
  }

  Future<void> followUser(String userId) async {
    final meId = _supabase.auth.currentUser!.id;

    await _supabase
        .from('relationships')
        .update({
          'status': 'friend',
        })
        .eq("follower_id", userId)
        .eq("followed_id", meId);

    await _supabase
        .from('notifications')
        .insert({'actor_id': meId, 'user_id': userId, 'action_type': 'follow'});
  }

  Future<void> unfollow(int relationshipId) async {
    await _supabase.from('relationships').update({
      'status': 'block',
    }).eq("id", relationshipId);
  }

  Future<void> increaseUserView(String userId) async {
    await _supabase.rpc('increment_profile_view_count', params: {
      'user_id': userId,
    });
  }
}
