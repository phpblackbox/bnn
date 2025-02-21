import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://prrbylvucoyewsezqcjn.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBycmJ5bHZ1Y295ZXdzZXpxY2puIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ4OTI2NTQsImV4cCI6MjA1MDQ2ODY1NH0.x8WeQI2hxqrgSa7ERSE7e1ROOCBRVemEY9VhMoD_JAY',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
