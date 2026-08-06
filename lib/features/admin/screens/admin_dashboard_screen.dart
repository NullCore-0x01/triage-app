// lib/features/admin/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();

  String _selectedRole = 'doctor'; // القيمة الافتراضية
  bool _isLoading = false;

  // دالة إضافة مستخدم جديد
  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await SupabaseService.client.from('users').insert({
        'username': _usernameController.text.trim(),
        'pin_code': _pinController.text.trim(),
        'role': _selectedRole,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المستخدم بنجاح ✅')),
        );
        // تفريغ الحقول بعد النجاح
        _usernameController.clear();
        _pinController.clear();
        setState(() {}); // لتحديث القائمة بالأسفل
      }
    } catch (e) {
      if (mounted) {
        // إذا كان اسم المستخدم موجوداً مسبقاً، قاعدة البيانات سترفضه (لأننا جعلناه UNIQUE)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ربما اسم المستخدم موجود مسبقاً! ($e)')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دالة تسجيل الخروج المشتركة
  void _logout() {
    // العودة إلى شاشة اختيار الدور ومسح كل الشاشات السابقة من الذاكرة
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        backgroundColor: AppColors.triageBlack,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. نموذج إضافة مستخدم
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إضافة مستخدم جديد:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'الكود السري (PIN)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'الدور (الصلاحية)',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'doctor',
                            child: Text('طبيب'),
                          ),
                          DropdownMenuItem(value: 'nurse', child: Text('ممرض')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('إدارة'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedRole = val!),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addUser,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: AppColors.primary,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'إضافة المستخدم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. قائمة المستخدمين الحاليين (للتأكد من الإضافة)
            const Text(
              'المستخدمون الحاليون:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                // نجلب بيانات المستخدمين لعرضها
                future: SupabaseService.client
                    .from('users')
                    .select()
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return const Text('لا يوجد مستخدمين');

                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      // تحديد لون الأيقونة حسب الدور
                      Color iconColor = user['role'] == 'admin'
                          ? AppColors.triageBlack
                          : user['role'] == 'doctor'
                          ? AppColors.primary
                          : AppColors.triageGreen;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: iconColor,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            user['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'الدور: ${user['role']} | الكود: ${user['pin_code']}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
