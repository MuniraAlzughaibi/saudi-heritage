import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.auth.currentUser;
    final all = user == null ? <Booking>[] : context.repo.bookingsFor(user.id);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          bottom: const TabBar(
            labelColor: AppColors.brown,
            indicatorColor: AppColors.terracotta,
            tabs: [
              Tab(text: 'زيارات المواقع'),
              Tab(text: 'الفعاليات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingList(
              bookings: all.where((b) => b.type == BookingType.place).toList(),
            ),
            _BookingList(
              bookings: all.where((b) => b.type == BookingType.event).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.confirmation_number_outlined,
        title: 'لا توجد حجوزات بعد',
        subtitle: 'احجز زيارتك القادمة من صفحة المواقع أو الفعاليات',
      );
    }
    final t = Theme.of(context).textTheme;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = bookings[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        b.targetTitle,
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Pill(text: b.id, icon: Icons.tag_rounded),
                  ],
                ),
                const SizedBox(height: 10),
                InfoRow(
                  icon: Icons.event_rounded,
                  text: Fmt.dateTime(b.dateTime),
                ),
                const SizedBox(height: 4),
                InfoRow(
                  icon: Icons.groups_outlined,
                  text: '${b.guests} ${b.guests == 1 ? 'شخص' : 'أشخاص'}',
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                    onPressed: () async {
                      final ok = await confirmDialog(
                        context,
                        title: 'إلغاء الحجز',
                        message: 'هل تريد إلغاء حجز "${b.targetTitle}"؟',
                      );
                      if (ok && context.mounted) {
                        context.repo.cancelBooking(b.id);
                        showMessage(context, 'تم إلغاء الحجز');
                      }
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('إلغاء الحجز'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
