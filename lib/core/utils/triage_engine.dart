// lib/core/utils/triage_engine.dart

import '../../models/patient_case_model.dart';

class TriageEngine {
  static String calculateSeverity(Vitals vitals) {
     
    if (vitals.heartRate == 0 && vitals.respRate == 0) {
      return 'BLACK';
    }

    
    if (vitals.heartRate >= 130 ||
        vitals.heartRate <= 40 ||
        vitals.respRate >= 30 ||
        vitals.respRate <= 10 ||
        vitals.systolicBP <= 90 ||
        vitals.oxygenSaturation <= 90) {
      return 'RED';
    }

    
    if (vitals.heartRate >= 120 ||
        vitals.heartRate < 50 ||
        vitals.respRate >= 26 ||
        vitals.systolicBP >= 160 ||
        vitals.oxygenSaturation <= 92) {
      return 'ORANGE';
    }

    
    if (vitals.heartRate >= 100 ||
        vitals.respRate >= 22 ||
        vitals.systolicBP >= 140 ||
        vitals.systolicBP < 100 ||
        vitals.oxygenSaturation <= 95) {
      return 'YELLOW';
    }

    
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
