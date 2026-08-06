// lib/core/services/supabase_service.dart
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  /// متغير ثابت يتيح لنا الوصول لقاعدة البيانات من أي شاشة بسهولة
  /// مثال للاستخدام: SupabaseService.client.from('triage_cases')...
  static final SupabaseClient client = Supabase.instance.client;

  /// دالة التهيئة الأساسية: سيتم استدعاؤها مرة واحدة فقط عند تشغيل التطبيق (في main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      // ملاحظة: عند التطبيق الفعلي، ستضع الرابط والمفتاح الخاصين بمشروعك على Supabase هنا
      url: 'https://fhqlazkhnjlwjyqheatt.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZocWxhemtobmpsd2p5cWhlYXR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNjMzMzgsImV4cCI6MjA5ODYzOTMzOH0.GI91Y2-hKUJudh7S2ukc0RQYUJIpSKjGxxWNKGUdZ7w',
    );
  }
}
