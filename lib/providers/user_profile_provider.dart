import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/services/auth_service.dart';
import 'package:bnn/services/profile_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {
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

  ProfilesModel? userInfo;

  List<Map<String, dynamic>> _followers = Constants.fakeFollwers;
  List<Map<String, dynamic>> get followers => _followers;

  List<Map<String, dynamic>> _following = Constants.fakeFollwers;
  List<Map<String, dynamic>> get following => _following;

  Future<void> getCountsOfProfileInfo(String userId) async {
    loading = true;
    userInfo = await _profileService.getUserProfileById(userId);
    countFollowers = await _profileService.getCountFollowers(userId);
    countFollowing = await _profileService.getCountFollowing(userId);
    countViews = await _profileService.getCountViews(userId);
    loading = false;
  }

  Future<void> increaseUserView(String userId) async {
    await _profileService.increaseUserView(userId);
  }

  Future<void> getFollowers(String userId) async {
    loading = true;
    _followers = await _profileService.getFollowers(userId);
    loading = false;
  }

  Future<void> followUser(String userId) async {
    await _profileService.followUser(userId);
  }

  Future<void> getFollowing(String userId) async {
    loading = true;
    _following = await _profileService.getFollowing(userId);
    loading = false;
  }
}
