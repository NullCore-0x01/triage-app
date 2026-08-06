// lib/features/nurse/screens/add_patient_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/patient_case_model.dart'; // مسار افتراضي للـ models
import '../../../core/utils/triage_engine.dart';
import '../../../core/services/supabase_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // متحكمات النصوص (Controllers)
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respRateController = TextEditingController();
  final _bpController = TextEditingController();
  final _oxygenController = TextEditingController();

  // متغير لحفظ اللون الحالي المعروض على الشاشة
  String _currentColorCode = 'GREEN';
  bool _isLoading = false;

  // دالة تُستدعى كلما كتب الممرض رقماً جديداً لتحديث اللون فوراً
  void _updateSeverity() {
    final vitals = _getCurrentVitals();
    final newColor = TriageEngine.calculateSeverity(vitals);

    if (_currentColorCode != newColor) {
      setState(() {
        _currentColorCode = newColor;
      });
    }
  }

  // دالة مساعدة لتجميع العلامات الحيوية من الحقول
  Vitals _getCurrentVitals() {
    return Vitals(
      heartRate: int.tryParse(_heartRateController.text) ?? 0,
      respRate: int.tryParse(_respRateController.text) ?? 0,
      systolicBP: int.tryParse(_bpController.text) ?? 0,
      oxygenSaturation: int.tryParse(_oxygenController.text) ?? 0,
    );
  }

  // دالة إرسال البيانات إلى Supabase
  Future<void> _submitCase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newCase = PatientCase(
        patientName: _nameController.text,
        age: int.parse(_ageController.text),
        vitals: _getCurrentVitals(),
        colorCode: _currentColorCode,
      );

      // سطر واحد فقط لحفظ البيانات في قاعدة البيانات!
      await SupabaseService.client
          .from('triage_cases')
          .insert(newCase.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الحالة وتحويلها للطبيب بنجاح'),
          ),
        );
        Navigator.pop(context); // العودة للشاشة السابقة
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = AppColors.getColorForSeverity(_currentColorCode);
    final severityText = TriageEngine.getSeverityNameArabic(_currentColorCode);

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل مريض جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // شريط يوضح الخطورة اللحظية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: severityColor, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: severityColor),
                  const SizedBox(width: 8),
                  Text(
                    '$severityText',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // حقول الإدخال
            _buildTextField(
              controller: _nameController,
              label: 'اسم المريض',
              isNumber: false,
            ),
            _buildTextField(controller: _ageController, label: 'العمر'),
            const Divider(height: 32),
            const Text(
              'العلامات الحيوية:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _heartRateController,
              label: 'معدل النبض (HR)',
            ),
            _buildTextField(
              controller: _respRateController,
              label: 'معدل التنفس (RR)',
            ),
            _buildTextField(
              controller: _bpController,
              label: 'الضغط الانقباضي (Systolic BP)',
            ),
            _buildTextField(
              controller: _oxygenController,
              label: 'نسبة الأكسجين (SPO2) %',
            ),

            const SizedBox(height: 32),

            // زر الحفظ
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCase,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    severityColor, // يتغير لون الزر حسب خطورة الحالة
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'تأكيد وإرسال للطبيب',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء حقول الإدخال وتقليل التكرار
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: (value) => isNumber
            ? _updateSeverity()
            : null, // تحديث اللون عند تغيير الأرقام
        validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
