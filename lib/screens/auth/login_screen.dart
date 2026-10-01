import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../data/auth_service.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../admin/admin_dashboard.dart';
import '../home/home_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fillDemo(String email) {
    setState(() {
      _email.text = email;
      _password.text = DemoAccounts.password;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await context.auth.signIn(_email.text, _password.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => homeFor(user)),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'أهلًا بعودتك',
                style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'سجّل دخولك لمتابعة حجوزاتك ومزايداتك',
                style: t.bodyLarge?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'أدخل بريدًا إلكترونيًا صحيحًا'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'أدخل كلمة المرور' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('دخول'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text('ليس لديك حساب؟ أنشئ حسابًا'),
              ),
              const SizedBox(height: 24),
              _DemoAccountsCard(onPick: _fillDemo),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoAccountsCard extends StatelessWidget {
  final ValueChanged<String> onPick;

  const _DemoAccountsCard({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      color: AppColors.sand.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, color: AppColors.brown),
                const SizedBox(width: 8),
                Text(
                  'حسابات تجريبية',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'اختر حسابًا لتعبئة البيانات تلقائيًا',
              style: t.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DemoButton(
                    icon: Icons.person_outline_rounded,
                    label: 'زائر',
                    onTap: () => onPick(DemoAccounts.visitorEmail),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DemoButton(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'مدير',
                    onTap: () => onPick(DemoAccounts.adminEmail),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DemoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: AppColors.terracotta),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Returns the landing screen for a signed-in [user].
Widget homeFor(AppUser user) =>
    user.isAdmin ? const AdminDashboard() : const HomeShell();
