// lib/features/auth/screens/role_selection_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'pin_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_hospital,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'اسعفني',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'بوابة تسجيل الدخول',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),

              // زر الإدارة
              _buildRoleButton(
                context,
                'دخول الإدارة (Admin)',
                Icons.admin_panel_settings,
                AppColors.triageBlack,
                'admin',
              ),
              const SizedBox(height: 16),

              // زر الطبيب
              _buildRoleButton(
                context,
                'دخول كـ طـبـيـب',
                Icons.medical_services,
                AppColors.primary,
                'doctor',
              ),
              const SizedBox(height: 16),

              // زر الممرض
              _buildRoleButton(
                context,
                'دخول كـ مـمـرض',
                Icons.vaccines,
                AppColors.triageGreen,
                'nurse',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String role,
  ) {
    return ElevatedButton.icon(
      // عند الضغط، ننتقل لشاشة الـ PIN ونمرر لها الدور الذي تم اختياره
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PinLoginScreen(role: role)),
      ),
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
