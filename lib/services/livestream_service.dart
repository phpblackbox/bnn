import 'package:supabase_flutter/supabase_flutter.dart';

class LivestreamService {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> getLivestreamById(String id) async {
    final data = await _supabase
        .from('livestream')
        .select('*')
        .eq('is_active', true)
        .eq('id', id)
        .order('created_at', ascending: false);
    return data;
  }

  Future<Map<String, dynamic>> getLivestreamByCallId(String callId) async {
    final data = await _supabase
        .from('livestream')
        .select('*')
        .eq('is_active', true)
        .eq('call_id', callId)
        .order('created_at', ascending: false)
        .single();
    return data;
  }

  Future<List<Map<String, dynamic>>> getLivestreams() async {
    final data = await _supabase
        .from('livestream')
        .select('*')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return data;
  }

  Future<void> upsert(String callId, bool active) async {
    final meId = _supabase.auth.currentUser?.id;
    await _supabase.from('livestream').upsert({
      'call_id': callId,
      'user_id': meId,
      'is_active': active,
    });

    return;
  }

  Future<void> update(String callId, bool active) async {
    final meId = _supabase.auth.currentUser?.id;
    await _supabase
        .from('livestream')
        .update({
          'is_active': active,
        })
        .eq('call_id', callId)
        .eq('user_id', meId!);

    return;
  }
}
