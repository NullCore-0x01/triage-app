// lib/features/auth/screens/pin_login_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';

class PinLoginScreen extends StatefulWidget {
  final String role; // 'admin', 'doctor', 'nurse'

  const PinLoginScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  // ترجمة الدور للعربية لعرضه في العنوان
  String get roleNameArabic {
    switch (widget.role) {
      case 'admin':
        return 'الإدارة';
      case 'doctor':
        return 'الطبيب';
      case 'nurse':
        return 'الممرض';
      default:
        return '';
    }
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال جميع البيانات')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // البحث في قاعدة البيانات عن مستخدم يطابق الاسم + الكود + الدور
      final user = await SupabaseService.client
          .from('users')
          .select()
          .eq('username', _usernameController.text.trim())
          .eq('pin_code', _pinController.text.trim())
          .eq('role', widget.role)
          .maybeSingle();

      if (user == null) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('بيانات الدخول خاطئة أو لا تملك صلاحية لهذا الدور'),
            ),
          );
      } else {
        // نجاح تسجيل الدخول - توجيه المستخدم حسب دوره
        if (mounted) {
          if (widget.role == 'admin') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin',
              (route) => false,
            );
          } else if (widget.role == 'doctor') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/doctor',
              (route) => false,
            );
          } else if (widget.role == 'nurse') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/nurse',
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('دخول $roleNameArabic')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'اسم المستخدم',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true, // إخفاء الرمز السري
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الكود السري (PIN)',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
