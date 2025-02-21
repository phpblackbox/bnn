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
      print('Error fetching profile: $e');
      rethrow;
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
}
