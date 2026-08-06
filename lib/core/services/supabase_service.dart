// lib/core/services/supabase_service.dart
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  
  static final SupabaseClient client = Supabase.instance.client;

   
  static Future<void> initialize() async {
    await Supabase.initialize(
      
      url: 'https://fhqlazkhnjlwjyqheatt.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZocWxhemtobmpsd2p5cWhlYXR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNjMzMzgsImV4cCI6MjA5ODYzOTMzOH0.GI91Y2-hKUJudh7S2ukc0RQYUJIpSKjGxxWNKGUdZ7w',
    );
  }
}
