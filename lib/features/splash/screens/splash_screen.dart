// lib/features/splash/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال التلقائي بعد 4 ثوانٍ إلى شاشة اختيار الدور
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/roles');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // 1. الأيقونة واسم التطبيق
            const Icon(
              Icons.local_hospital,
              size: 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'RescueMe',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'نظام فرز الطوارئ الذكي',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // 2. شريط التحميل (النقاط الثلاث)
            const ThreeDotsLoader(),

            const Spacer(),

            // 3. حقوق المشروع (نص التخرج)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    Text(
                      'هذا التطبيق هو نموذج أولي لمشروع تخرج',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.triageOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'الكلية الأردنية السودانية للعلوم والتكنولوجيا',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(height: 20),
                    Text(
                      'إعداد الطلاب:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'محمد أبوبكر إبراهيم بلة\nمحمد مبارك عمر يوسف',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// كلاس مساعد لبرمجة النقاط الثلاث التي تضيء بالتناوب (بدون مكتبات خارجية)
// ---------------------------------------------------------
class ThreeDotsLoader extends StatefulWidget {
  const ThreeDotsLoader({Key? key}) : super(key: key);

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // تغيير النقطة المضيئة كل 300 جزء من الثانية
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // النقطة الحالية تأخذ لوناً غامقاً، والبقية لون فاتح شفاف
            color: _currentIndex == index
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}
