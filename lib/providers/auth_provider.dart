import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  UserModel? get user => _user;

  final ProfileService _profileService = ProfileService();
  ProfilesModel? _profile;
  ProfilesModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    final isUser = await _authService.isLoggedIn();

    if (isUser) {
      // initial
      _user = UserModel(
          email: _authService.getCurrentUser()?.email,
          id: _authService.getCurrentUser()?.id);

      final userId = _user!.id;
      _profile = await _profileService.getUserProfileById(userId!);
    }
  }

  Future<void> setProfile(Map<String, dynamic> updates) async {
    if (_profile != null) {
      final updatedProfile = _profile!.copyWith(
        firstName: updates['firstName'] ?? _profile!.firstName ?? '',
        lastName: updates['lastName'] ?? _profile!.lastName ?? '',
        username: updates['username'] ?? _profile!.username ?? '',
        age: updates['age'] ?? _profile!.age ?? 25,
        bio: updates['bio'] ?? _profile!.bio ?? '',
        gender: updates['gender'] ?? _profile!.gender ?? 1,
        avatar: updates['avatar'] ?? _profile!.avatar ?? '',
      );

      _profile = updatedProfile;
      notifyListeners();
    } else {
      print("Error: Cannot update profile. Profile is null.");
    }
  }

  Future<void> createProfile() async {
    final newProfile = ProfilesModel(
      _user?.id,
      firstName: '',
      lastName: '',
      username: '',
      age: 25,
      bio: '',
      gender: 1,
      avatar: '',
    );
    _profile = newProfile;
  }

  Future<bool> loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _authService.signInWithEmailAndPassword(email, password);
      if (response.user != null) {
        final userId = response.user!.id;
        _user = UserModel(email: response.user?.email, id: response.user?.id);
        _profile = await _profileService.getUserProfileById(userId);

        if (_profile != null) {
          _isLoading = false;
          notifyListeners();
          Navigator.pushReplacementNamed(context, '/home');
          return true;
        } else {
          _errorMessage = 'Failed to fetch user profile.';
          _isLoading = false;
          notifyListeners();
          Navigator.pushReplacementNamed(context, '/create-profile');
          return false;
        }
      } else {
        _errorMessage = 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'An unexpected error occurred.';
      print(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String confirmPassword,
      BuildContext context) async {
    _isLoading = true;
    if (password != confirmPassword) {
      _errorMessage =
          'The passwords entered do not match. Let’s give it another try!';
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _authService.signUp(email, password);
      if (res.user != null) {
        _user = UserModel(email: res.user?.email, id: res.user?.id);
        _isLoading = false;
        return true;
      } else {
        _errorMessage = 'Sign-up failed. Please try again.';
        _isLoading = false;
        return false;
      }
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;

      return false;
    } catch (error) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> googleSignIn(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    _user = await _authService.nativeGoogleSignIn();

    if (_user != null) {
      _isLoading = false;
      notifyListeners();
      final userId = _user?.id;
      if (userId != null) {
        _profile = await _profileService.getUserProfileById(userId);

        if (_profile != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/create-profile');
        }
      }
    } else {
      _isLoading = false;
      _errorMessage = 'Google sign-in failed.';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> updateProfile() async {
    try {
      await _profileService.updateUserProfile(_profile!);
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to update profile: $error';
      notifyListeners();
    }
  }

  Future<String?> uploadAvatar({
    required XFile image,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = user?.id;
      final publicUrl =
          await _authService.uploadAvatar(userId: userId!, image: image);

      notifyListeners();
      return publicUrl;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      print('Error in AuthProvider: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
