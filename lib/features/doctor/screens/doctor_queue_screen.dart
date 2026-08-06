// lib/features/doctor/screens/doctor_queue_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/patient_case_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/patient_card.dart';
import 'diagnosis_screen.dart';
import 'archived_cases_screen.dart'; // 🟢 استدعاء شاشة الأرشيف

class DoctorQueueScreen extends StatefulWidget {
  const DoctorQueueScreen({Key? key}) : super(key: key);

  @override
  State<DoctorQueueScreen> createState() => _DoctorQueueScreenState();
}

class _DoctorQueueScreenState extends State<DoctorQueueScreen> {
  int _getPriority(String colorCode) {
    switch (colorCode) {
      case 'RED':
        return 1;
      case 'ORANGE':
        return 2;
      case 'YELLOW':
        return 3;
      case 'GREEN':
        return 4;
      case 'BLACK':
        return 5;
      default:
        return 6;
    }
  }

  Future<void> _callPatient(String patientId) async {
    try {
      await SupabaseService.client
          .from('triage_cases')
          .update({'status': 'called'})
          .eq('id', patientId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المرضى'),
        backgroundColor: AppColors.primary,
        actions: [
          // 🟢 1. زر التحديث اليدوي (Refresh)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث القائمة',
            onPressed: () {
              setState(
                () {},
              ); // يقوم بإعادة بناء الشاشة لجلب أحدث البيانات فوراً
            },
          ),
          // 🟢 2. زر السجلات والأرشيف
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'سجل الحالات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArchivedCasesScreen()),
              );
            },
          ),
          // 🟢 3. زر تسجيل الخروج
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SupabaseService.client
            .from('triage_cases')
            .stream(primaryKey: ['id'])
            .neq(
              'status',
              'closed',
            ), // الحالات المغلقة ستختفي من هنا وتذهب للأرشيف
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return const Center(child: Text('خطأ في جلب البيانات'));

          final cases = (snapshot.data ?? [])
              .map((e) => PatientCase.fromJson(e))
              .toList();

          cases.sort((a, b) {
            int pA = _getPriority(a.colorCode);
            int pB = _getPriority(b.colorCode);
            if (pA != pB) return pA.compareTo(pB);

            final tA = a.createdAt ?? DateTime.now();
            final tB = b.createdAt ?? DateTime.now();
            return tA.compareTo(tB);
          });

          if (cases.isEmpty)
            return const Center(
              child: Text(
                'لا يوجد مرضى في الانتظار ',
                style: TextStyle(fontSize: 18),
              ),
            );

          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final patient = cases[index];
              return PatientCard(
                patientCase: patient,
                actionButton: patient.status == 'waiting'
                    ? ElevatedButton.icon(
                        onPressed: () => _callPatient(patient.id!),
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('استدعاء'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.triageRed,
                          foregroundColor: Colors.white,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DiagnosisScreen(patientCase: patient),
                          ),
                        ),
                        icon: const Icon(Icons.medical_information),
                        label: const Text('فحص وتشخيص'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
