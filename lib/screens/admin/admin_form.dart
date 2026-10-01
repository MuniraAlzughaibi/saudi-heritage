import 'package:flutter/material.dart';

import '../../core/theme.dart';

class FormFieldSpec {
  final String key;
  final String label;
  final String initial;
  final int maxLines;
  final bool numeric;

  const FormFieldSpec(
    this.key,
    this.label, {
    this.initial = '',
    this.maxLines = 1,
    this.numeric = false,
  });
}

/// Generic add/edit bottom sheet used by the admin management screens.
/// Returns the entered values keyed by [FormFieldSpec.key], or null if cancelled.
Future<Map<String, String>?> showAdminForm(
  BuildContext context, {
  required String title,
  required List<FormFieldSpec> fields,
}) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.cream,
    builder: (_) => _AdminForm(title: title, fields: fields),
  );
}

class _AdminForm extends StatefulWidget {
  final String title;
  final List<FormFieldSpec> fields;

  const _AdminForm({required this.title, required this.fields});

  @override
  State<_AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<_AdminForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers = {
    for (final f in widget.fields)
      f.key: TextEditingController(text: f.initial),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      for (final e in _controllers.entries) e.key: e.value.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              for (final f in widget.fields) ...[
                TextFormField(
                  controller: _controllers[f.key],
                  maxLines: f.maxLines,
                  keyboardType: f.numeric
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: f.label,
                    alignLabelWithHint: f.maxLines > 1,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
                    if (f.numeric && double.tryParse(v.trim()) == null) {
                      return 'أدخل رقمًا صحيحًا';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              FilledButton(onPressed: _save, child: const Text('حفظ')),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small edit/delete action pair used on admin list items.
class AdminItemActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminItemActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'تعديل',
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
        IconButton(
          tooltip: 'حذف',
          icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
