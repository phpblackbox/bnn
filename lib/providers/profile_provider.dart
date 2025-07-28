import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/services/auth_service.dart';
import 'package:bnn/services/profile_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  int countFollowers = 0;
  int countFollowing = 0;
  int countViews = 0;

  List<Map<String, dynamic>> _followers = Constants.fakeFollwers;
  List<Map<String, dynamic>> get followers => _followers;

  List<Map<String, dynamic>> _following = Constants.fakeFollwers;
  List<Map<String, dynamic>> get following => _following;

  Future<ProfilesModel?> getUserProfileById(String userId) async {
    ProfilesModel? user = await _profileService.getUserProfileById(userId);
    return user;
  }

  Future<void> getCountsOfProfileInfo() async {
    loading = true;
    try {
      String? userId;
      
      try {
        userId = _authService.getCurrentUser()?.id;
      } catch (e) {
        print('Error getting current user: $e');
        userId = null;
      }
      
      if (userId == null) {
        print('Cannot get profile counts: userId is null');
        countFollowers = 0;
        countFollowing = 0;
        countViews = 0;
        loading = false;
        return;
      }
      
      try {
        countFollowers = await _profileService.getCountFollowers(userId);
      } catch (e) {
        print('Error getting followers count: $e');
        countFollowers = 0;
      }
      
      try {
        countFollowing = await _profileService.getCountFollowing(userId);
      } catch (e) {
        print('Error getting following count: $e');
        countFollowing = 0;
      }
      
      try {
        countViews = await _profileService.getCountViews(userId);
      } catch (e) {
        print('Error getting views count: $e');
        countViews = 0;
      }
    } catch (e) {
      print('Error getting profile counts: $e');
      // Set default values
      countFollowers = 0;
      countFollowing = 0;
      countViews = 0;
    } finally {
      loading = false;
    }
  }

  Future<Map<String, dynamic>?> getFriendInfo(String userId) async {
    try {
      // Safely get the current user ID
      final currentUser = _authService.getCurrentUser();
      final meId = currentUser?.id;
      
      // Handle null meId gracefully
      if (meId == null) {
        print('Cannot get friend info: current user ID is null');
        return null;
      }
      
      print('Getting friend info between $meId and $userId');
      
      // Get friend relationship info
      final friendInfo = await _profileService.getFriendInfo(meId, userId);
      return friendInfo;
    } catch (e) {
      print('Error getting friend info: $e');
      return null;
    }
  }

  Future<void> getFollowers() async {
    loading = true;
    final meId = _authService.getCurrentUser()?.id;
    _followers = await _profileService.getFollowers(meId!);
    loading = false;
  }

  Future<void> followUser(String userId) async {
    await _profileService.followUser(userId);
    await getFollowers();
  }

  Future<void> getFollowing() async {
    loading = true;
    final meId = _authService.getCurrentUser()?.id;
    _following = await _profileService.getFollowing(meId!);
    loading = false;
  }

  Future<void> unfollow(int relationshipId) async {
    await _profileService.unfollow(relationshipId);
    await getFollowing();
  }

  Future<void> followUserPost(String userId, BuildContext context) async {
    await _profileService.followUser(userId);
    CustomToast.showToastSuccessTop(context, 'Followed Successfully');
  }

  Future<void> unfollowPost(int relationshipId, BuildContext context) async {
    await _profileService.unfollow(relationshipId);
    CustomToast.showToastSuccessTop(context, 'Unfollowed Successfully');
  }

  Future<List<dynamic>> getFriends() async {
    try {
      final meId = _authService.getCurrentUser()?.id;
      if (meId == null) return [];

      return await _profileService.getFriends(meId);
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }
}
