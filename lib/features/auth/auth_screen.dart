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
            children: [
              // Header with Image/Gradient
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryOrange, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.accessibility_new_rounded,
                            color: Colors.white, size: 60),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'نبض الحركة',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 34,
                            ),
                      ),
                      Text(
                        'جودة الحياة تبدأ من هنا',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                            ),
                      ),
                      const SizedBox(height: 30),
                      if (!_isLogin) ...[
                        _buildField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildField(
                                controller: _cityController,
                                label: 'المدينة',
                                icon: Icons.location_city_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _buildField(
                                controller: _ageController,
                                label: 'العمر',
                                icon: Icons.calendar_today_rounded,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          controller: _medicalNotesController,
                          label: 'ملاحظات صحية',
                          icon: Icons.note_alt_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        icon: Icons.lock_open_rounded,
                        obscureText: true,
                      ),

                      const SizedBox(height: 40),

                      if (auth.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            auth.error!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: AnimatedButton(
                          onPressed: auth.loading ? () {} : _submit,
                          label: _isLogin ? 'دخول' : 'تأكيد الحساب',
                          isLoading: auth.loading,
                          icon: Icons.arrow_back_rounded,
                        ),
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: auth.loading
                              ? null
                              : () => setState(() => _isLogin = !_isLogin),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.grey[800], fontSize: 15, fontFamily: 'Tajawal'),
                              children: [
                                TextSpan(text: _isLogin ? 'ليس لديك حساب؟ ' : 'لديك حساب بالفعل؟ '),
                                TextSpan(
                                  text: _isLogin ? 'اشترك الآن' : 'سجل الدخول',
                                  style: const TextStyle(
                                    color: AppTheme.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange, size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
        ),
      ),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    bool success;
    if (_isLogin) {
      success = await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      success = await auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        city: _cityController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        medicalNotes: _medicalNotesController.text.trim().isEmpty
            ? null
            : _medicalNotesController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }
}
