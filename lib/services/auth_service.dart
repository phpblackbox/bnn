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

  Future<bool> isLoggedIn() async {
    return _supabase.auth.currentUser != null;
  }

  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel.fromSupabase(user.toJson());
    }
    return null;
  }

  Future<void> signOut() async {
    // await streamService.disconnect();
    await _supabase.auth.signOut();
  }

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

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: '${dotenv.env['APP_URL']}/auth/callback',
    );
  }

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

  Future<void> verifyPhoneOTP(String phone, String otp) async {
    try {
      await _supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.signup,
      );
    } catch (e) {
      print('Error verifying phone OTP: $e');
      rethrow;
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  Future<bool> isPhoneVerified() async {
    final user = _supabase.auth.currentUser;
    return user?.phoneConfirmedAt != null;
  }

  Future<void> verifyEmailOTP(String email, String otp) async {
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
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
}
