// lib/core/widgets/patient_card.dart

import 'package:flutter/material.dart';
import '../../models/patient_case_model.dart';
import '../constants/app_colors.dart';
import '../utils/triage_engine.dart';

class PatientCard extends StatelessWidget {
  final PatientCase patientCase;
  final Widget? actionButton; // زر اختياري يتغير حسب الشاشة (طبيب أو ممرض)
  final VoidCallback? onTap; // حدث عند الضغط على البطاقة كاملة

  const PatientCard({
    Key? key,
    required this.patientCase,
    this.actionButton,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // جلب اللون والاسم العربي للتصنيف
    final severityColor = AppColors.getColorForSeverity(patientCase.colorCode);
    final severityName = TriageEngine.getSeverityNameArabic(patientCase.colorCode);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias, // لضمان عدم خروج الألوان عن حواف البطاقة
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight( // لجعل الشريط الجانبي يأخذ نفس ارتفاع البطاقة
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. الشريط اللوني الجانبي (يعبر عن خطورة الحالة)
              Container(
                width: 12,
                color: severityColor,
              ),
              
              // 2. محتوى البطاقة
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // بيانات المريض
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientCase.patientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'العمر: ${patientCase.age} سنة | الحالة: $severityName',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 3. زر الإجراء (إن وُجد)
                      if (actionButton != null) actionButton!,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
