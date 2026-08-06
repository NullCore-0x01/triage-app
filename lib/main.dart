

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'core/constants/app_colors.dart';
import 'core/services/supabase_service.dart';

import 'features/auth/screens/role_selection_screen.dart';
import 'features/nurse/screens/nurse_dashboard_screen.dart';
import 'features/doctor/screens/doctor_queue_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';

import 'features/splash/screens/splash_screen.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

 
  runApp(const TriageSyncApp());
}

class TriageSyncApp extends StatelessWidget {
  const TriageSyncApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriageSync - الفرز الذكي',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Cairo', 
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
      ),

     
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],

      
      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(), 
        '/roles': (context) => const RoleSelectionScreen(), 
        '/nurse': (context) => const NurseDashboardScreen(),
        '/doctor': (context) => const DoctorQueueScreen(),
        '/admin': (context) => const AdminDashboardScreen(), 
      },
    );
  }
}
