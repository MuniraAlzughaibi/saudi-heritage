import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(),
                  Flexible(
                    flex: 4,
                    child: Image.asset('assets/images/logo.png', height: 240),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اكتشف تراث المملكة',
                    textAlign: TextAlign.center,
                    style: t.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'استكشف المواقع التاريخية، احجز الفعاليات الثقافية،\nوشارك في مزادات القطع التراثية.',
                    textAlign: TextAlign.center,
                    style: t.bodyLarge?.copyWith(
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('تسجيل الدخول'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: const Text('إنشاء حساب جديد'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
