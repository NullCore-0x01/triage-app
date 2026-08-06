// lib/features/doctor/screens/archived_cases_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/patient_case_model.dart';
import '../../../core/services/supabase_service.dart';

class ArchivedCasesScreen extends StatelessWidget {
  const ArchivedCasesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الحالات المؤرشفة'),
        backgroundColor: AppColors.triageBlack, // اللون الأسود يدل على الأرشيف
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SupabaseService.client
            .from('triage_cases')
            .stream(primaryKey: ['id'])
            .eq('status', 'closed') // 🟢 جلب الحالات المغلقة فقط
            .order('created_at', ascending: false), // الأحدث أولاً
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('خطأ في جلب البيانات'));
          }

          final cases = (snapshot.data ?? [])
              .map((e) => PatientCase.fromJson(e))
              .toList();

          if (cases.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد سجلات مؤرشفة بعد 📁',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final patient = cases[index];
              final severityColor = AppColors.getColorForSeverity(
                patient.colorCode,
              );

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: severityColor,
                    child: const Icon(Icons.archive, color: Colors.white),
                  ),
                  title: Text(
                    patient.patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text('العمر: ${patient.age} | تم الإغلاق بنجاح'),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      color: Colors.grey.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التشخيص الطبي:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            patient.diagnosis ?? 'لم يتم كتابة تشخيص',
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (patient.overrideReason != null) ...[
                            const Divider(),
                            const Text(
                              'ملاحظة تعديل الفرز:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.triageOrange,
                              ),
                            ),
                            Text(patient.overrideReason!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
