import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_widgets.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController(text: 'غزة');
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High-end medical header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(30, 80, 30, 40),
                decoration: const BoxDecoration(
                  color: AppTheme.deepTeal,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.primaryTeal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.accessibility_new_rounded, color: AppTheme.primaryTeal, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب طبي',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'أهلاً بك في نظام التعافي الذكي' : 'ابدأ رحلتك العلاجية مع نبض الحركة',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildAuthField(controller: _nameController, label: 'الاسم الكامل', icon: Icons.person_outline_rounded),
                        const SizedBox(height: 20),
                        _buildAuthField(controller: _cityController, label: 'المدينة', icon: Icons.location_city_rounded),
                        const SizedBox(height: 20),
                        _buildAuthField(controller: _ageController, label: 'العمر', icon: Icons.calendar_today_rounded, keyboardType: TextInputType.number),
                        const SizedBox(height: 20),
                      ],
                      _buildAuthField(controller: _emailController, label: 'البريد الإلكتروني', icon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 20),
                      _buildAuthField(controller: _passwordController, label: 'كلمة المرور', icon: Icons.lock_open_rounded, obscureText: true),

                      const SizedBox(height: 40),

                      if (auth.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(auth.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 65,
                        child: AnimatedButton(
                          onPressed: auth.loading ? () {} : _submit,
                          label: _isLogin ? 'دخول النظام' : 'تأكيد التسجيل',
                          isLoading: auth.loading,
                          icon: Icons.login_rounded,
                        ),
                      ),

                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: auth.loading ? null : () => setState(() => _isLogin = !_isLogin),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppTheme.softGrey, fontSize: 15, fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: _isLogin ? 'لا تملك حساباً؟ ' : 'لديك حساب بالفعل؟ '),
                              const TextSpan(text: 'اضغط هنا', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildAuthField({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.deepTeal),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryTeal, size: 22),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    bool success = _isLogin
      ? await auth.login(email: _emailController.text.trim(), password: _passwordController.text.trim())
      : await auth.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          city: _cityController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? 0
        );
    if (success && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose(); _cityController.dispose(); _ageController.dispose();
    _emailController.dispose(); _passwordController.dispose(); _medicalNotesController.dispose();
    super.dispose();
  }
}
