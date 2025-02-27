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
}
