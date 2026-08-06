// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// استدعاء الثوابت والخدمات
import 'core/constants/app_colors.dart';
import 'core/services/supabase_service.dart';

// استدعاء الشاشات
import 'features/auth/screens/role_selection_screen.dart';
import 'features/nurse/screens/nurse_dashboard_screen.dart';
import 'features/doctor/screens/doctor_queue_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';

import 'features/splash/screens/splash_screen.dart';

void main() async {
  // 1. التأكد من تهيئة بيئة Flutter قبل تنفيذ أي كود غير متزامن
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة الاتصال بقاعدة بيانات Supabase
  await SupabaseService.initialize();

  // 3. تشغيل التطبيق
  runApp(const TriageSyncApp());
}

class TriageSyncApp extends StatelessWidget {
  const TriageSyncApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriageSync - الفرز الذكي',
      debugShowCheckedModeBanner: false, // إخفاء شريط الـ Debug
      // إعدادات التصميم العامة
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Cairo', // يُفضل إضافة خط عربي مثل Cairo في pubspec.yaml
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
      ),

      // 4. دعم اللغة العربية وتوجيه التطبيق من اليمين لليسار (RTL)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'), // تحديد العربية كلغة أساسية
      ],

      // 5. نظام التوجيه والمسارات (Routing)
      initialRoute: '/', // الشاشة التي يبدأ بها التطبيق
      routes: {
        '/': (context) => const SplashScreen(), // 🟢 التطبيق سيبدأ من هنا الآن
        '/roles': (context) => const RoleSelectionScreen(), // مسار اختيار الدور
        '/nurse': (context) => const NurseDashboardScreen(),
        '/doctor': (context) => const DoctorQueueScreen(),
        '/admin': (context) => const AdminDashboardScreen(), // 🟢 تم تفعيلها
      },
    );
  }
}
