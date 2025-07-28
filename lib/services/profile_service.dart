import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profiles_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfilesModel?> getUserProfileById(String userId) async {
    try {
      print('Fetching profile for user: $userId');
      
      // Use maybeSingle() to handle the case where no profile exists
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      // If no data was found, return null instead of throwing an error
      if (data == null) {
        print('No profile found for user: $userId');
        return null;
      }
      
      return ProfilesModel.fromJson(data);
    } catch (e) {
      print('Error fetching profile: $e');
      // For PostgrestException about rows, return null instead of throwing
      if (e.toString().contains('PGRST116')) {
        return null;
      }
      // Rethrow other errors
      rethrow;
    }
  }

  Future<ProfilesModel?> getUserProfileByIdDirect(String userId) async {
    try {
      print('Attempting direct profile lookup for user: $userId');
      
      // Run a raw query to ensure we're getting all profiles for this user
      final response = await _supabase
          .rpc('get_user_profile_by_id', params: {'user_id': userId});
      
      print('Direct profile query response: $response');
      
      if (response != null && response is List && response.isNotEmpty) {
        return ProfilesModel.fromJson(response[0]);
      }
      
      // If RPC doesn't work, try a direct table query
      final result = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId);
          
      print('Fallback query response: $result');
        
      if (result != null && result is List && result.isNotEmpty) {
        return ProfilesModel.fromJson(result[0]);
      }
      
      return null;
    } catch (e) {
      print('Error in direct profile query: $e');
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
    if (profile.id == null) {
      throw Exception('Cannot update profile: Profile ID is null');
    }
    
    try {
      await _supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id!);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<bool> isFriend(String userId1, String userId2) async {
    return await _supabase
        .rpc('is_friend', params: {'me_id': userId1, 'user_id': userId2});
  }

  Future<Map<String, dynamic>?> getFriendInfo(String meId, String userId) async {
    try {
      // Don't try to get friend info with self
      if (meId == userId) {
        return null;
      }
      
      final data = await _supabase
          .from('relationships')
          .select()
          .or('follower_id.eq.$meId,followed_id.eq.$meId')
          .or('follower_id.eq.$userId,followed_id.eq.$userId')
          .maybeSingle();
      
      if (data == null) {
        return null;
      }
      
      return data;
    } catch (e) {
      print('Error in getFriendInfo: $e');
      // Return null instead of throwing
      return null;
    }
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

  Future<List<dynamic>> getFriends(String userId) async {
    try {
      final response = await _supabase
          .from('relationships')
          .select('*, profiles!relationships_followed_id_fkey(*)')
          .eq('status', 'friend')
          .or('follower_id.eq.${userId},followed_id.eq.${userId}');

      return response.map((friend) => friend['profiles']).toList();
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }
}
