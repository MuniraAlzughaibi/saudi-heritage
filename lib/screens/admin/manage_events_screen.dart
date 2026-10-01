import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import 'admin_form.dart';

class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});

  Future<void> _edit(BuildContext context, [HeritageEvent? event]) async {
    final values = await showAdminForm(
      context,
      title: event == null ? 'إضافة فعالية' : 'تعديل الفعالية',
      fields: [
        FormFieldSpec('title', 'اسم الفعالية', initial: event?.title ?? ''),
        FormFieldSpec(
          'category',
          'التصنيف (مهرجان، ورشة، جولة...)',
          initial: event?.category ?? '',
        ),
        FormFieldSpec('location', 'المكان', initial: event?.location ?? ''),
        FormFieldSpec(
          'description',
          'الوصف',
          initial: event?.description ?? '',
          maxLines: 4,
        ),
      ],
    );
    if (values == null || !context.mounted) return;

    final now = DateTime.now();
    final current =
        event?.date ?? DateTime(now.year, now.month, now.day + 7, 19);
    final day = await showDatePicker(
      context: context,
      helpText: 'تاريخ الفعالية',
      initialDate: current.isBefore(now) ? now : current,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!context.mounted) return;
    final date = day == null
        ? current
        : DateTime(day.year, day.month, day.day, current.hour);

    final repo = context.repo;
    repo.saveEvent(
      (event ??
              HeritageEvent(
                id: repo.newId('e'),
                title: '',
                date: date,
                location: '',
                description: '',
              ))
          .copyWith(
            title: values['title'],
            category: values['category'],
            location: values['location'],
            description: values['description'],
            date: date,
          ),
    );
    showMessage(context, 'تم الحفظ');
  }

  @override
  Widget build(BuildContext context) {
    final events = context.repo.events;
    return Scaffold(
      appBar: AppBar(title: const Text('الفعاليات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
      body: events.isEmpty
          ? const EmptyState(
              icon: Icons.event_outlined,
              title: 'لا توجد فعاليات',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final e = events[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 4,
                    ),
                    title: Text(
                      e.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${Fmt.date(e.date)} • ${e.location}'),
                    trailing: AdminItemActions(
                      onEdit: () => _edit(context, e),
                      onDelete: () async {
                        if (await confirmDialog(
                              context,
                              title: 'حذف الفعالية',
                              message: 'حذف "${e.title}"؟',
                            ) &&
                            context.mounted) {
                          context.repo.deleteEvent(e.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
