// lib/services/story_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadVideo(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    String filename = '${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _supabase.storage.from('story').uploadBinary(filename, bytes);

    return _supabase.storage.from('story').getPublicUrl(filename);
  }

  Future<void> createReel(String userId, String videoUrl) async {
    await _supabase.from('reels').upsert({
      'author_id': userId,
      'video_url': videoUrl,
    });
  }
}
