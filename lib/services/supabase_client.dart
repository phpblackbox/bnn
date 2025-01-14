import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClient {
  static final SupabaseClient _instance = SupabaseClient._internal();
  static final supabase = Supabase.instance.client;

  // Private constructor
  SupabaseClient._internal();

  factory SupabaseClient() {
    return _instance;
  }
}
