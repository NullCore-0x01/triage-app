// lib/features/nurse/screens/nurse_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/patient_case_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/patient_card.dart';
import 'add_patient_screen.dart';

class NurseDashboardScreen extends StatelessWidget {
  const NurseDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: AppColors.triageGreen,
        // 🟢 إضافة زر تسجيل الخروج
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل خروج',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPatientScreen()),
        ),
        backgroundColor: AppColors.primary,

        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'حالة جديدة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SupabaseService.client
            .from('triage_cases')
            .stream(primaryKey: ['id'])
            .neq('status', 'closed')
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return const Center(child: Text('خطأ في جلب البيانات'));

          final cases = (snapshot.data ?? [])
              .map((e) => PatientCase.fromJson(e))
              .toList();

          if (cases.isEmpty)
            return const Center(
              child: Text(
                'لا توجد حالات طوارئ حالياً ',
                style: TextStyle(fontSize: 18),
              ),
            );

          return Column(
            children: [
              _buildStatisticsRow(cases), // 🟢 الإحصائيات المحدثة
              Expanded(
                child: ListView.builder(
                  itemCount: cases.length,
                  itemBuilder: (context, index) {
                    final patient = cases[index];
                    return PatientCard(
                      patientCase: patient,
                      actionButton: patient.status == 'called'
                          ? const Chip(
                              label: Text(
                                'تم الاستدعاء',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppColors.primary,
                            )
                          : const Chip(label: Text('في الانتظار')),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🟢 تحديث شريط الإحصائيات ليدعم الـ 5 ألوان مع إمكانية التمرير الأفقي
  Widget _buildStatisticsRow(List<PatientCase> cases) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _statBadge(
            'أحمر',
            cases.where((c) => c.colorCode == 'RED').length,
            AppColors.triageRed,
          ),
          const SizedBox(width: 12),
          _statBadge(
            'برتقالي',
            cases.where((c) => c.colorCode == 'ORANGE').length,
            AppColors.triageOrange,
          ),
          const SizedBox(width: 12),
          _statBadge(
            'أصفر',
            cases.where((c) => c.colorCode == 'YELLOW').length,
            AppColors.triageYellow,
          ),
          const SizedBox(width: 12),
          _statBadge(
            'أخضر',
            cases.where((c) => c.colorCode == 'GREEN').length,
            AppColors.triageGreen,
          ),
          const SizedBox(width: 12),
          _statBadge(
            'أسود',
            cases.where((c) => c.colorCode == 'BLACK').length,
            AppColors.triageBlack,
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 22,
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
