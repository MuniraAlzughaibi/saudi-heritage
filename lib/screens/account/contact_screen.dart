import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.auth.currentUser;
    if (user != null && _name.text.isEmpty) {
      _name.text = user.name;
      _email.text = user.email;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    context.repo.sendMessage(
      name: _name.text.trim(),
      email: _email.text.trim(),
      message: _message.text.trim(),
    );
    _message.clear();
    showMessage(context, 'وصلتنا رسالتك، شكرًا لتواصلك');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('تواصل معنا')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'نسعد باقتراحاتك واستفساراتك',
              style: t.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'الاسم'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل اسمك' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'أدخل بريدًا صحيحًا' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _message,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'رسالتك',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 5) ? 'اكتب رسالتك' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.send_rounded),
              label: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
