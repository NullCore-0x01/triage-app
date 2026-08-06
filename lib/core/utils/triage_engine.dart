// lib/core/utils/triage_engine.dart

import '../../models/patient_case_model.dart';

class TriageEngine {
  static String calculateSeverity(Vitals vitals) {
    // 1. أسود (ميئوس منها / متوفى): النبض والتنفس صفر
    if (vitals.heartRate == 0 && vitals.respRate == 0) {
      return 'BLACK';
    }

    // 2. أحمر (خطر فوري على الحياة): علامات متدهورة بشدة
    if (vitals.heartRate >= 130 ||
        vitals.heartRate <= 40 ||
        vitals.respRate >= 30 ||
        vitals.respRate <= 10 ||
        vitals.systolicBP <= 90 ||
        vitals.oxygenSaturation <= 90) {
      return 'RED';
    }

    // 3. برتقالي (خطير جداً): علامات سيئة جداً لكن ليست انهياراً تاماً
    if (vitals.heartRate >= 120 ||
        vitals.heartRate < 50 ||
        vitals.respRate >= 26 ||
        vitals.systolicBP >= 160 ||
        vitals.oxygenSaturation <= 92) {
      return 'ORANGE';
    }

    // 4. أصفر (عاجل): علامات غير طبيعية وتستدعي الاهتمام
    if (vitals.heartRate >= 100 ||
        vitals.respRate >= 22 ||
        vitals.systolicBP >= 140 ||
        vitals.systolicBP < 100 ||
        vitals.oxygenSaturation <= 95) {
      return 'YELLOW';
    }

    // 5. أخضر (غير عاجل): مستقر وطبيعي
    return 'GREEN';
  }

  static String getSeverityNameArabic(String colorCode) {
    switch (colorCode) {
      case 'RED':
        return 'خطر فوري على الحياة';
      case 'ORANGE':
        return 'خطير جداً';
      case 'YELLOW':
        return 'عاجل';
      case 'GREEN':
        return 'غير عاجل';
      case 'BLACK':
        return 'حالة ميئوس منها';
      default:
        return 'غير مصنف';
    }
  }
}
