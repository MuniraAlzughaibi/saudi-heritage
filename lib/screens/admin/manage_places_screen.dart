import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import 'admin_form.dart';

class ManagePlacesScreen extends StatelessWidget {
  const ManagePlacesScreen({super.key});

  Future<void> _edit(BuildContext context, [HeritagePlace? place]) async {
    final values = await showAdminForm(
      context,
      title: place == null ? 'إضافة موقع' : 'تعديل الموقع',
      fields: [
        FormFieldSpec('title', 'اسم الموقع', initial: place?.title ?? ''),
        FormFieldSpec('city', 'المدينة', initial: place?.city ?? ''),
        FormFieldSpec(
          'hours',
          'أوقات الزيارة',
          initial: place?.openingHours ?? '',
        ),
        FormFieldSpec(
          'description',
          'الوصف',
          initial: place?.description ?? '',
          maxLines: 4,
        ),
        FormFieldSpec(
          'map',
          'رابط الخريطة',
          initial: place?.mapUrl ?? 'https://maps.google.com/?q=',
        ),
      ],
    );
    if (values == null || !context.mounted) return;
    final repo = context.repo;
    repo.savePlace(
      (place ??
              HeritagePlace(
                id: repo.newId('p'),
                title: '',
                city: '',
                description: '',
                image: 'assets/images/logo.png',
                mapUrl: '',
              ))
          .copyWith(
            title: values['title'],
            city: values['city'],
            openingHours: values['hours'],
            description: values['description'],
            mapUrl: values['map'],
          ),
    );
    showMessage(context, 'تم الحفظ');
  }

  @override
  Widget build(BuildContext context) {
    final places = context.repo.places;
    return Scaffold(
      appBar: AppBar(title: const Text('المواقع التاريخية')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
      body: places.isEmpty
          ? const EmptyState(
              icon: Icons.account_balance_outlined,
              title: 'لا توجد مواقع',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final p = places[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 10,
                      end: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        p.image,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      p.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(p.city),
                    trailing: AdminItemActions(
                      onEdit: () => _edit(context, p),
                      onDelete: () async {
                        if (await confirmDialog(
                              context,
                              title: 'حذف الموقع',
                              message: 'حذف "${p.title}"؟',
                            ) &&
                            context.mounted) {
                          context.repo.deletePlace(p.id);
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
