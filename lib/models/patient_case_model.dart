// lib/models/patient_case_model.dart

class PatientCase {
  final String? id; // جعلناه اختياري لأننا لا نملك ID قبل الإرسال للقاعدة
  final String patientName;
  final int age;
  final Vitals vitals;
  final String colorCode; // RED, YELLOW, GREEN, BLACK
  final String status; // waiting, called, closed
  final DateTime? createdAt;
  final String? diagnosis; // يكون فارغاً حتى يكتبه الطبيب
  final String? overrideReason;

  PatientCase({
    this.id,
    required this.patientName,
    required this.age,
    required this.vitals,
    required this.colorCode,
    this.status = 'waiting', // الحالة الافتراضية عند تسجيل مريض جديد
    this.createdAt,
    this.diagnosis,
    this.overrideReason,
  });

  // دالة تحويل البيانات القادمة من Supabase (JSON) إلى كائن Dart
  factory PatientCase.fromJson(Map<String, dynamic> json) {
    return PatientCase(
      id: json['id'] as String?,
      patientName: json['patient_name'] ?? 'مجهول',
      age: json['age'] ?? 0,
      vitals: Vitals.fromJson(json['vitals'] ?? {}), // تحويل الـ JSONB
      colorCode: json['color_code'] ?? 'GREEN',
      status: json['status'] ?? 'waiting',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      diagnosis: json['diagnosis'],
      overrideReason: json['override_reason'],
    );
  }

  // دالة تحويل الكائن إلى JSON لإرساله إلى Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patient_name': patientName,
      'age': age,
      'vitals': vitals.toJson(), // تحويل العلامات الحيوية لـ JSONB
      'color_code': colorCode,
      'status': status,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (overrideReason != null) 'override_reason': overrideReason, // 🟢
      // لا نرسل created_at لأن قاعدة البيانات تنشئه تلقائياً
    };
  }
}

// ---------------------------------------------------------
// كلاس العلامات الحيوية (Vitals) لترتيب البيانات بدلاً من وضعها بشكل عشوائي
// ---------------------------------------------------------

class Vitals {
  final int heartRate; // معدل النبض
  final int respRate; // معدل التنفس
  final int systolicBP; // الضغط الانقباضي
  final int oxygenSaturation; // نسبة الأكسجين

  Vitals({
    required this.heartRate,
    required this.respRate,
    required this.systolicBP,
    required this.oxygenSaturation,
  });

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      heartRate: json['heart_rate'] ?? 0,
      respRate: json['resp_rate'] ?? 0,
      systolicBP: json['systolic_bp'] ?? 0,
      oxygenSaturation: json['oxygen_saturation'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heart_rate': heartRate,
      'resp_rate': respRate,
      'systolic_bp': systolicBP,
      'oxygen_saturation': oxygenSaturation,
    };
  }
}
