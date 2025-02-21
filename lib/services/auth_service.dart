import 'dart:io';

import 'package:bnn/utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> nativeGoogleSignIn() async {
    final webClientId = dotenv.env['WEB_CLIENT_ID'] ?? '';
    final androidClientId = dotenv.env['ANDROID_CLIENT_ID'] ?? '';

    try {
      final googleSignIn = GoogleSignIn(
        clientId: androidClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Or handle cancellation appropriately
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
        return UserModel.fromSupabase(response.user!.toJson());
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
    await _supabase.auth.signOut();
  }

  Future<AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email.trim(), password: password);
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
      return publicUrl; // Return the public URL
    } catch (e) {
      print('Error uploading avatar to Supabase: $e');
      rethrow; // Re-throw the error to be handled by the provider
    }
  }
}
