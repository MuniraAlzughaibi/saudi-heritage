import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../auctions/auction_details_screen.dart';
import 'admin_form.dart';

class ManageAuctionsScreen extends StatelessWidget {
  const ManageAuctionsScreen({super.key});

  Future<void> _edit(BuildContext context, [AuctionItem? item]) async {
    final values = await showAdminForm(
      context,
      title: item == null ? 'إضافة قطعة للمزاد' : 'تعديل المزاد',
      fields: [
        FormFieldSpec('title', 'اسم القطعة', initial: item?.title ?? ''),
        FormFieldSpec(
          'description',
          'الوصف',
          initial: item?.description ?? '',
          maxLines: 3,
        ),
        FormFieldSpec(
          'price',
          'سعر الافتتاح (ر.س)',
          initial: item?.startingPrice.toStringAsFixed(0) ?? '',
          numeric: true,
        ),
        FormFieldSpec(
          'days',
          'مدة المزاد بالأيام',
          initial: '7',
          numeric: true,
        ),
      ],
    );
    if (values == null || !context.mounted) return;
    final repo = context.repo;
    final days = double.parse(values['days']!).round();
    repo.saveAuction(
      (item ??
              AuctionItem(
                id: repo.newId('a'),
                title: '',
                description: '',
                image: 'assets/images/logo.png',
                startingPrice: 0,
                endsAt: DateTime.now(),
              ))
          .copyWith(
            title: values['title'],
            description: values['description'],
            startingPrice: double.parse(values['price']!),
            endsAt: DateTime.now().add(Duration(days: days)),
          ),
    );
    showMessage(context, 'تم الحفظ');
  }

  @override
  Widget build(BuildContext context) {
    final items = context.repo.auctions;
    return Scaffold(
      appBar: AppBar(title: const Text('المزادات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.gavel_outlined,
              title: 'لا توجد مزادات',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final a = items[i];
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AuctionDetailsScreen(auctionId: a.id),
                      ),
                    ),
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 10,
                      end: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        a.image,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${Fmt.price(a.currentPrice)} • ${a.bids.length} مزايدة',
                    ),
                    trailing: AdminItemActions(
                      onEdit: () => _edit(context, a),
                      onDelete: () async {
                        if (await confirmDialog(
                              context,
                              title: 'حذف المزاد',
                              message: 'حذف "${a.title}"؟',
                            ) &&
                            context.mounted) {
                          context.repo.deleteAuction(a.id);
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
