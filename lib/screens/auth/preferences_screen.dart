import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../home/home_shell.dart';

/// Short onboarding survey shown after sign-up to learn the user's interests.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _questions = [
    (
      q: 'كيف تفضّل حضور المزادات؟',
      options: ['عبر الإنترنت', 'حضوريًا', 'لا فرق عندي'],
    ),
    (
      q: 'أي نوع من المزادات يهمّك أكثر؟',
      options: ['القطع الأثرية والتحف', 'العملات والمخطوطات', 'كلاهما'],
    ),
    (
      q: 'ما الذي يجذبك في التراث؟',
      options: [
        'القصص والروايات الشعبية',
        'العمارة والمواقع التاريخية',
        'الحِرف والفنون',
      ],
    ),
  ];

  int _index = 0;
  final Map<int, String> _answers = {};

  void _finish() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  void _next() =>
      _index < _questions.length - 1 ? setState(() => _index++) : _finish();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final question = _questions[_index];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [TextButton(onPressed: _finish, child: const Text('تخطٍّ'))],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: AppColors.sand,
                  color: AppColors.terracotta,
                ),
                const SizedBox(height: 8),
                Text(
                  'سؤال ${_index + 1} من ${_questions.length}',
                  style: t.labelLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                Text(
                  question.q,
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                for (final option in question.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionTile(
                      text: option,
                      selected: _answers[_index] == option,
                      onTap: () => setState(() => _answers[_index] = option),
                    ),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _answers[_index] == null ? null : _next,
                  child: Text(
                    _index == _questions.length - 1
                        ? 'ابدأ الاستكشاف'
                        : 'التالي',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.brown : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.brown : AppColors.sand,
          width: 1.4,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? Colors.white : AppColors.sand,
        ),
      ),
    );
  }
}
