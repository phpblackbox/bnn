import 'dart:io';
import 'package:bnn/models/profiles_model.dart';
import 'package:bnn/services/profile_service.dart';
import 'package:bnn/services/stream_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();
  // StreamService streamService = StreamService();
  ProfilesModel? profile;
  bool _isSigningOut = false;

  // ==================== GOOGLE AUTHENTICATION ====================
  
  Future<UserModel?> nativeGoogleSignIn() async {
    final webClientId = dotenv.env['WEB_CLIENT_ID'] ?? '';
    final androidClientId = dotenv.env['ANDROID_CLIENT_ID'] ?? '';
    final iOSClientId = dotenv.env['IOS_CLIENT_ID'] ?? '';

    try {
      GoogleSignIn googleSignIn;
      if (Platform.isAndroid) {
        googleSignIn = GoogleSignIn(
          clientId: androidClientId,
          serverClientId: webClientId,
        );
      } else if (Platform.isIOS) {
        googleSignIn = GoogleSignIn(
          clientId: iOSClientId,
          serverClientId: webClientId,
        );
      } else {
        throw 'Unsupported platform';
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Missing Google Auth Token.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      if (response.user != null) {
        final userModel = UserModel.fromSupabase(response.user!.toJson());

        ProfilesModel? profile =
            await _profileService.getUserProfileById(userModel.id!);

        // streamService.initStream(
        //     profile!.id!, profile.username!, profile.avatar!);
        return userModel;
      } else {
        return null;
      }
    } catch (error) {
      rethrow;
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  Future<bool> isLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      // Only consider logged in if both session and user exist
      if (session == null || user == null) {
        return false;
      }

      // Check if token is expired
      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      final now = DateTime.now();

      if (now.isAfter(expiresAt)) {
        print('Token expired, trying to refresh');
        // Try to refresh the token
        final refreshResult = await refreshSession();
        return refreshResult;
      }

      return true;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel.fromSupabase(user.toJson());
    }
    return null;
  }

  Future<bool> refreshSession() async {
    try {
      final currentSession = _supabase.auth.currentSession;

      // No session to refresh
      if (currentSession == null) {
        print('No session to refresh');
        return false;
      }

      // Check if token is expired or about to expire (within 5 minutes)
      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(currentSession.expiresAt! * 1000);
      final now = DateTime.now();
      final fiveMinutes = Duration(minutes: 5);

      if (now.isAfter(expiresAt) ||
          now.isAfter(expiresAt.subtract(fiveMinutes))) {
        print('Token expired or about to expire, refreshing...');

        try {
          // Attempt to refresh the session
          final response = await _supabase.auth.refreshSession();

          if (response.session != null) {
            print('Session refreshed successfully');
            return true;
          } else {
            print('Failed to refresh session');
            return false;
          }
        } catch (e) {
          print('Error during refresh: $e');
          return false;
        }
      }

      // Token is still valid
      return true;
    } catch (e) {
      print('Error refreshing session: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    // Guard against multiple simultaneous sign-outs
    if (_isSigningOut) {
      print('Auth service already signing out, ignoring repeated call');
      return;
    }

    _isSigningOut = true;

    try {
      // Sign out with full scope to clear all sessions
      await _supabase.auth.signOut(scope: SignOutScope.global);
      print('Successfully signed out from Supabase');
    } catch (e) {
      print('Error signing out from Supabase: $e');
      rethrow;
    } finally {
      _isSigningOut = false;
    }
  }

  // ==================== EMAIL AUTHENTICATION ====================

  Future<AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    final response = await _supabase.auth
        .signInWithPassword(email: email, password: password);

    final userModel = UserModel.fromSupabase(response.user!.toJson());

    ProfilesModel? profile =
        await _profileService.getUserProfileById(userModel.id!);

    // streamService.initStream(profile!.id!, profile.username!, profile.avatar!);
    return response;
  }

  Future<bool> loginWithEmail(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        emailRedirectTo: '${dotenv.env['APP_URL']}/auth/callback',
        shouldCreateUser: false,
      );
      print('OTP sent successfully to: $email');
      return true;
    } catch (error) {
      print('Login error: $error');

      // Parse specific error messages from Supabase
      String errorMessage = error.toString().toLowerCase();

      if (errorMessage.contains('user not found') ||
          errorMessage.contains('invalid login credentials') ||
          errorMessage.contains('does not exist') ||
          errorMessage.contains('not allowed for otp') ||
          errorMessage.contains('invalid email')) {
        throw AuthException(
            'This email is not registered. Please sign up first.');
      }

      // Rethrow the original error for other cases
      rethrow;
    }
  }

  Future<AuthResponse> verifyEmailLoginOTP(String email, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      return response;
    } catch (e) {
      print('Error verifying email OTP for login: $e');
      rethrow;
    }
  }

  Future<bool> signUpWithEmail(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        emailRedirectTo: '${dotenv.env['APP_URL']}/auth/callback',
        shouldCreateUser: true,
      );
      return true;
    } catch (e) {
      print('Error sending email OTP: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: '${dotenv.env['APP_URL']}/auth/callback',
    );
  }

  Future<void> verifyEmailOTP(String email, String otp) async {
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
    } catch (e) {
      print('Error verifying email OTP: $e');
      rethrow;
    }
  }

  Future<void> resendEmailOTP(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      print('Error resending email OTP: $e');
      rethrow;
    }
  }

  // ==================== PHONE AUTHENTICATION ====================

  /// Send OTP to phone number for signup
  Future<bool> signUpWithPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );
      print('Signup OTP sent successfully to: $phoneNumber');
      return true;
    } catch (error) {
      print('Phone signup error: $error');
      rethrow;
    }
  }

  /// Send OTP to phone number for login (existing users only)
  Future<bool> loginWithPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: false,
      );
      print('Login OTP sent successfully to: $phoneNumber');
      return true;
    } catch (error) {
      print('Phone login error: $error');

      // Parse specific error messages
      String errorMessage = error.toString().toLowerCase();

      if (errorMessage.contains('user not found') ||
          errorMessage.contains('invalid login credentials') ||
          errorMessage.contains('does not exist') ||
          errorMessage.contains('not allowed for otp')) {
        throw AuthException(
            'This phone number is not registered. Please sign up first.');
      }

      rethrow;
    }
  }

  /// Verify phone OTP for both signup and login
  Future<AuthResponse> verifyPhoneOTP(String phoneNumber, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        print('Phone OTP verified successfully for: $phoneNumber');
      }

      return response;
    } catch (e) {
      print('Error verifying phone OTP: $e');
      rethrow;
    }
  }

  /// Resend phone OTP
  Future<bool> resendPhoneOTP(String phoneNumber) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.sms,
        phone: phoneNumber,
      );
      print('Phone OTP resent successfully to: $phoneNumber');
      return true;
    } catch (e) {
      print('Error resending phone OTP: $e');
      rethrow;
    }
  }

  // LEGACY PHONE METHODS (for backward compatibility)
  Future<void> verifyPhone(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phone,
      );
    } catch (e) {
      print('Error sending phone verification: $e');
      rethrow;
    }
  }

  // Future<void> verifyPhoneOTP(String phone, String otp) async {
  //   try {
  //     await _supabase.auth.verifyOTP(
  //       phone: phone,
  //       token: otp,
  //       type: OtpType.sms,
  //     );
  //   } catch (e) {
  //     print('Error verifying phone OTP: $e');
  //     rethrow;
  //   }
  // }

  // ==================== PASSWORD MANAGEMENT ====================

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Error sending password reset OTP: $e');
      rethrow;
    }
  }

  Future<void> verifyPasswordResetOTP(
      String email, String otp, String newPassword) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.user != null) {
        await _supabase.auth.updateUser(
          UserAttributes(
            password: newPassword,
          ),
        );
      }
    } catch (e) {
      print('Error verifying password reset OTP: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  // ==================== VERIFICATION STATUS ====================

  Future<bool> isEmailVerified() async {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  Future<bool> isPhoneVerified() async {
    final user = _supabase.auth.currentUser;
    return user?.phoneConfirmedAt != null;
  }

  // ==================== FILE UPLOAD ====================

  Future<String> uploadAvatar({
    required String userId,
    required XFile image,
  }) async {
    try {
      String randomNumStr = Constants().generateRandomNumberString(6);
      final filename = '${userId}_$randomNumStr.png';
      final fileBytes = await File(image.path).readAsBytes();

      await _supabase.storage.from('avatars').uploadBinary(
            filename,
            fileBytes,
          );

      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(filename);
      return publicUrl;
    } catch (e) {
      print('Error uploading avatar to Supabase: $e');
      rethrow;
    }
  }
}