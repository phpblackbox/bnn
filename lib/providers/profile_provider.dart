import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/services/auth_service.dart';
import 'package:bnn/services/profile_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';

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
    final meId = _authService.getCurrentUser()?.id;
    countFollowers = await _profileService.getCountFollowers(meId!);
    countFollowing = await _profileService.getCountFollowing(meId);
    countViews = await _profileService.getCountViews(meId);
    loading = false;
  }

  Future<Map<String, dynamic>?> getFriendInfo(String userId) async {
    final meId = _authService.getCurrentUser()?.id;
    print(meId);
    final friendInfo = await _profileService.getFriendInfo(meId!, userId);
    return friendInfo;
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
}
