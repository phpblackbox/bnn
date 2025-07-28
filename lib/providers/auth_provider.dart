import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  // Flag to track initialization
  bool _isInitialized = false;
  // Flag to prevent simultaneous sign-outs
  bool _isSigningOut = false;
  // Flag to prevent init loops
  bool _isInitializing = false;
  bool _appPaused = false;

  Future<void> init() async {
    // Prevent repeated initialization
    if (_isInitializing || _isSigningOut) return;

    _isInitializing = true;
    _isLoading = true;
    notifyListeners();

    try {
      final isUser = await _authService.isLoggedIn();

      if (isUser) {
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null) {
          _user = UserModel(email: currentUser.email, id: currentUser.id);

          if (_user?.id != null) {
            try {
              _profile = await _profileService.getUserProfileById(_user!.id!);
              // We'll handle null profile in the UI - don't auto-logout here
            } catch (e) {
              print('Error loading profile: $e');
              _profile = null; // Explicitly set to null on error
              // Don't auto-logout for profile errors
            }
          } else {
            print('User ID is null after getting current user');
            _user = null;
            _profile = null;
          }
        } else {
          print('Current user is null despite isLoggedIn returning true');
          _user = null;
          _profile = null;
        }
      } else {
        _user = null;
        _profile = null;
      }

      _isInitialized = true;
    } catch (e) {
      print('Error in init: $e');
      _user = null;
      _profile = null;
    } finally {
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Call this method when app is resumed
  Future<void> handleAppResume() async {
    if (!_appPaused) return; // Only handle if app was paused

    _appPaused = false;
    print('App resumed, checking auth state...');

    // Try to refresh the session
    final sessionValid = await _authService.refreshSession();

    if (!sessionValid) {
      // Session couldn't be refreshed, sign user out
      print('Session refresh failed, signing out');
      await signOut();
      return;
    }

    // Refresh profile if user is logged in
    if (_user != null && _user!.id != null) {
      try {
        print('Refreshing profile data after resume');
        _profile = await _profileService.getUserProfileById(_user!.id!);
        notifyListeners();
      } catch (e) {
        print('Error refreshing profile after resume: $e');
        // Don't sign out here, as session might still be valid
      }
    }
  }

  // Call this method when app is paused
  void handleAppPause() {
    _appPaused = true;
    print('App paused');
  }

  // In auth_provider.dart
  Future<bool> refreshProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First check if we have a cached profile
      await loadProfileFromStorage();

      // First, attempt to refresh the session token if needed
      final sessionValid = await _authService.refreshSession();

      // If session refresh failed, but we have a cached profile, we can still show it temporarily
      if (!sessionValid && _profile != null) {
        print('Using cached profile as session refresh failed');
        _isLoading = false;
        _errorMessage =
            'Using cached profile data. Some features may be limited.';
        notifyListeners();
        return true; // Return true since we have something to show
      }

      // If session is invalid and we have no cache, we need to log out
      if (!sessionValid && _profile == null) {
        _isLoading = false;
        _errorMessage = 'Session expired. Please log in again.';
        notifyListeners();
        return false;
      }

      // If user exists and session is valid, refresh profile data
      if (_user != null && _user!.id != null) {
        try {
          final updatedProfile =
              await _profileService.getUserProfileById(_user!.id!);

          if (updatedProfile != null) {
            _profile = updatedProfile;
            // Save the refreshed profile to persistent storage
            await saveProfileToStorage();
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            // If profile doesn't exist on server but we have a cached version, keep using it
            if (_profile != null) {
              _isLoading = false;
              notifyListeners();
              return true;
            }

            // No profile exists at all
            _profile = null;
            _isLoading = false;
            _errorMessage = 'Please complete your profile setup.';
            notifyListeners();
            return false;
          }
        } catch (e) {
          print('Error fetching profile: $e');

          // If we have a cached profile, use it as fallback
          if (_profile != null) {
            _isLoading = false;
            _errorMessage =
                'Using cached profile data. Some features may be limited.';
            notifyListeners();
            return true;
          }

          // Complete failure
          _isLoading = false;
          _errorMessage = 'Failed to refresh profile: ${e.toString()}';
          notifyListeners();
          return false;
        }
      } else {
        // No user ID available
        _isLoading = false;
        _errorMessage = 'User not properly authenticated.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Handle specific error types
      if (e.toString().contains('JWT') ||
          e.toString().contains('401') ||
          e.toString().contains('auth')) {
        // Authentication errors should trigger logout
        _isLoading = false;
        _errorMessage = 'Session expired. Please log in again.';
        notifyListeners();
        return false;
      }

      _isLoading = false;
      _errorMessage = 'Failed to refresh profile: ${e.toString()}';
      print('Error in refreshProfile: $e');
      notifyListeners();
      return false;
    }
  }

  // Add methods for saving and loading profile
  Future<void> saveProfileToStorage() async {
    if (_profile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(_profile!.toJson());
      await prefs.setString('user_profile', profileJson);
      print('Profile saved to storage');
    } catch (e) {
      print('Error saving profile to storage: $e');
    }
  }

  Future<void> loadProfileFromStorage() async {
    if (_user == null || _profile != null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');

      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson);

        // Only use stored profile if it matches current user ID
        if (profileMap['id'] == _user!.id) {
          _profile = ProfilesModel.fromJson(profileMap);
          print('Profile loaded from storage');
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading profile from storage: $e');
    }
  }

  Future<void> setProfile(Map<String, dynamic> updates) async {
    if (_profile != null) {
      final updatedProfile = _profile!.copyWith(
        // DO NOT update ID here, preserve existing ID
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
    } else if (_user?.id != null) {
      // Create a new profile with user ID if profile is null
      final newProfile = ProfilesModel(
        _user!.id,
        firstName: updates['firstName'] ?? '',
        lastName: updates['lastName'] ?? '',
        username: updates['username'] ?? '',
        age: updates['age'] ?? 25,
        bio: updates['bio'] ?? '',
        gender: updates['gender'] ?? 1,
        avatar: updates['avatar'] ?? '',
      );
      _profile = newProfile;
      notifyListeners();
    } else {
      print("Error: Cannot update profile. User ID is null.");
    }
    await saveProfileToStorage();
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

  Future<bool> loginWithEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.loginWithEmail(email);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (error) {
      print('Login error: $error');

      // Check for non-existent user errors
      if (error is AuthException) {
        if (error.message.contains('user not found') ||
            error.message.contains('Invalid login credentials') ||
            error.message.contains('does not exist') ||
            error.message.contains('invalid email') ||
            error.message.contains('not allowed for otp') ||
            error.message.contains('User not found')) {
          _errorMessage = 'This email is not registered. Please sign up first.';

          // We don't show toast here, since we'll display the error in the UI
        } else {
          _errorMessage = error.message;
        }
      } else {
        _errorMessage = 'An unexpected error occurred: ${error.toString()}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailLoginOTP(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // try {
    //   final response = await _authService.verifyEmailLoginOTP(email, otp);
    //   if (response.user != null) {
    //     final userId = response.user!.id;
    //     _user = UserModel(email: response.user?.email, id: userId);

    //     // Add logging to debug profile retrieval
    //     print('Successfully verified OTP. Looking for profile with user ID: $userId');

    //     try {
    //       _profile = await _profileService.getUserProfileById(userId);

    //       // User is logged in successfully
    //       _isLoading = false;
    //       notifyListeners();
    //       return true;
    //     } catch (profileError) {
    //       print('Profile error: $profileError');
    //       // Profile doesn't exist or there's an error
    //       _errorMessage = 'Please complete your profile setup first';
    //       _isLoading = false;
    //       notifyListeners();
    //       return true; // We'll handle the redirection in the UI
    //     }
    //   } else {
    //     _errorMessage = 'Verification failed. Please try again.';
    //     _isLoading = false;
    //     notifyListeners();
    //     return false;
    //   }
    // } catch (error) {
    //   print('Login error: $error');
    //   _errorMessage = 'An unexpected error occurred: ${error.toString()}';
    //   _isLoading = false;
    //   notifyListeners();
    //   return false;
    // }

    try {
      final response = await _authService.verifyEmailLoginOTP(email, otp);
      if (response.user != null) {
        final userId = response.user!.id;
        _user = UserModel(email: response.user?.email, id: userId);

        // Add logging to debug profile retrieval
        print(
            'Successfully verified OTP. Looking for profile with user ID: $userId');

        try {
          // Improve profile retrieval logic
          final profileData = await _profileService.getUserProfileById(userId);

          if (profileData != null) {
            print('Found existing profile for user: $userId');
            _profile = profileData;
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            // Try a more direct query if normal retrieval failed
            print(
                'Profile not found with standard query. Trying alternative lookup...');
            final directProfile =
                await _profileService.getUserProfileByIdDirect(userId);

            if (directProfile != null) {
              print('Found profile using direct query');
              _profile = directProfile;
              _isLoading = false;
              notifyListeners();
              return true;
            } else {
              print('No profile found. User needs to create one.');
              _errorMessage = 'Please complete your profile setup';
              _isLoading = false;
              notifyListeners();
              return true; // We'll handle the redirection in the UI
            }
          }
        } catch (profileError) {
          print('Profile retrieval error: $profileError');
          _errorMessage = 'Please complete your profile setup';
          _isLoading = false;
          notifyListeners();
          return true; // We'll handle the redirection in the UI
        }
      } else {
        _errorMessage = 'Verification failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      print('Login error: $error');
      _errorMessage = 'An unexpected error occurred: ${error.toString()}';
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
          "The passwords entered do not match. Let's give it another try!";
      _isLoading = false;
      notifyListeners();
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

  Future<bool> signUpWithEmail(String email, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.signUpWithEmail(email);
      if (success) {
        _user = UserModel(
            email: email,
            id: null); // We'll get the ID later after verification
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Sign-up failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> googleSignIn(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
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
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    // Guard against multiple simultaneous sign-outs or signing out when not logged in
    if (_isSigningOut) {
      print('Already signing out or not logged in, ignoring repeated call');
      return;
    }

    _isSigningOut = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _profile = null;
      _errorMessage = null;
      _isInitialized = false; // Reset initialization flag
    } catch (e) {
      print('Error during sign out: $e');
    } finally {
      _isLoading = false;
      _isSigningOut = false; // Reset flag
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    if (_profile == null) {
      _errorMessage = 'Cannot update profile: Profile is null';
      notifyListeners();
      return;
    }

    if (_profile!.id == null && _user?.id != null) {
      // If profile ID is null but user ID exists, set the ID
      _profile = _profile!.copyWith(id: _user!.id);
    }

    if (_profile!.id == null) {
      _errorMessage = 'Cannot update profile: Profile ID is null';
      notifyListeners();
      return;
    }

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
      if (userId == null) {
        throw Exception('User ID is null, cannot upload avatar');
      }

      final publicUrl =
          await _authService.uploadAvatar(userId: userId, image: image);
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

  Future<bool> verifyEmailOTP(String email, String otp) async {
    try {
      await _authService.verifyEmailOTP(email, otp);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> resendEmailOTP(String email) async {
    try {
      await _authService.resendEmailOTP(email);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> verifyPhone(String phone) async {
    try {
      await _authService.verifyPhone(phone);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> verifyPhoneOTP(String phone, String otp) async {
    try {
      await _authService.verifyPhoneOTP(phone, otp);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPasswordResetOTP(
      String email, String otp, String newPassword) async {
    try {
      await _authService.verifyPasswordResetOTP(email, otp, newPassword);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add these methods to your existing AuthProvider class:

  // PHONE AUTHENTICATION METHODS

  /// Sign up with phone number - sends OTP
  Future<bool> signUpWithPhone(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.signUpWithPhone(phoneNumber);
      if (success) {
        // Store phone temporarily for OTP verification
        _user = UserModel(
          email: null,
          id: null,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send verification code. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'An unexpected error occurred: ${error.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with phone number - sends OTP to existing users
  Future<bool> loginWithPhone(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.loginWithPhone(phoneNumber);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (error) {
      print('Phone login error: $error');

      // Check for non-existent user errors
      if (error is AuthException) {
        if (error.message.contains('user not found') ||
            error.message.contains('Invalid login credentials') ||
            error.message.contains('does not exist') ||
            error.message.contains('not allowed for otp')) {
          _errorMessage =
              'This phone number is not registered. Please sign up first.';
        } else {
          _errorMessage = error.message;
        }
      } else {
        _errorMessage = 'An unexpected error occurred: ${error.toString()}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify phone OTP for both signup and login
  Future<bool> verifyPhoneLoginOTP(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyPhoneOTP(phoneNumber, otp);

      if (response.user != null) {
        final userId = response.user!.id;
        _user = UserModel(email: response.user?.email, id: userId);

        print(
            'Successfully verified phone OTP. Looking for profile with user ID: $userId');

        try {
          // Try to get existing profile
          final profileData = await _profileService.getUserProfileById(userId);

          if (profileData != null) {
            print('Found existing profile for user: $userId');
            _profile = profileData;
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            // Try alternative lookup
            print(
                'Profile not found with standard query. Trying alternative lookup...');
            final directProfile =
                await _profileService.getUserProfileByIdDirect(userId);

            if (directProfile != null) {
              print('Found profile using direct query');
              _profile = directProfile;
              _isLoading = false;
              notifyListeners();
              return true;
            } else {
              print('No profile found. User needs to create one.');
              _errorMessage = 'Please complete your profile setup';
              _isLoading = false;
              notifyListeners();
              return true; // We'll handle redirection in UI
            }
          }
        } catch (profileError) {
          print('Profile retrieval error: $profileError');
          _errorMessage = 'Please complete your profile setup';
          _isLoading = false;
          notifyListeners();
          return true; // We'll handle redirection in UI
        }
      } else {
        _errorMessage = 'Verification failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      print('Phone OTP verification error: $error');
      _errorMessage = 'Invalid verification code. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resend phone OTP
  Future<bool> resendPhoneOTP(String phoneNumber) async {
    try {
      await _authService.resendPhoneOTP(phoneNumber);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to resend code: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
