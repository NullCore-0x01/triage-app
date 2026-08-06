// lib/features/doctor/screens/diagnosis_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/patient_case_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/triage_engine.dart';

class DiagnosisScreen extends StatefulWidget {
  final PatientCase patientCase;

  const DiagnosisScreen({Key? key, required this.patientCase})
    : super(key: key);

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final _diagnosisController = TextEditingController();
  bool _isLoading = false;

  // دالة إغلاق الحالة بعد كتابة التشخيص
  Future<void> _closeCase() async {
    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة التشخيص أولاً')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // تحديث الحالة في قاعدة البيانات إلى "مغلقة" وإضافة نص التشخيص
      await SupabaseService.client
          .from('triage_cases')
          .update({
            'status': 'closed',
            'diagnosis': _diagnosisController.text.trim(),
          })
          .eq('id', widget.patientCase.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إغلاق الحالة وأرشفتها بنجاح 📋')),
        );
        // العودة إلى قائمة الانتظار
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = AppColors.getColorForSeverity(
      widget.patientCase.colorCode,
    );
    final severityText = TriageEngine.getSeverityNameArabic(
      widget.patientCase.colorCode,
    );
    final vitals = widget.patientCase.vitals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحالة والتشخيص'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. بطاقة معلومات المريض الأساسية
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: severityColor,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  widget.patientCase.patientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'العمر: ${widget.patientCase.age} | التصنيف: $severityText',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. شبكة العلامات الحيوية (Vitals Grid)
            const Text(
              'العلامات الحيوية:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _vitalTile(
                  'نبض القلب (HR)',
                  '${vitals.heartRate} bpm',
                  Icons.favorite,
                  Colors.red,
                ),
                _vitalTile(
                  'معدل التنفس (RR)',
                  '${vitals.respRate} /min',
                  Icons.air,
                  Colors.blue,
                ),
                _vitalTile(
                  'الضغط (BP)',
                  '${vitals.systolicBP} mmHg',
                  Icons.speed,
                  Colors.orange,
                ),
                _vitalTile(
                  'الأكسجين (SPO2)',
                  '${vitals.oxygenSaturation} %',
                  Icons.water_drop,
                  Colors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 3. حقل التشخيص الطبي
            const Text(
              'التشخيص الطبي والإجراء المتخذ:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _diagnosisController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'اكتب تفاصيل التشخيص هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // 4. زر إغلاق الحالة
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _closeCase,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isLoading ? 'جاري الحفظ...' : 'إغلاق الحالة (أرشفة)',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.triageBlack, // أسود دلالة على النهاية/الأرشفة
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لتصميم مربعات العلامات الحيوية
  Widget _vitalTile(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
