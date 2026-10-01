import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/booking_sheet.dart';
import '../../widgets/common.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final all = context.repo.events;
    final categories = {for (final e in all) e.category}.toList();
    final events = all
        .where((e) => _category == null || e.category == _category)
        .where((e) => e.title.contains(_query) || e.location.contains(_query))
        .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverList.list(
              children: [
                Text(
                  'الفعاليات القادمة',
                  style: t.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                SearchField(
                  hint: 'ابحث عن فعالية',
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip(
                        'الكل',
                        _category == null,
                        () => setState(() => _category = null),
                      ),
                      for (final c in categories)
                        _chip(
                          c,
                          _category == c,
                          () => setState(() => _category = c),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (events.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.event_busy_rounded,
                title: 'لا توجد فعاليات مطابقة',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.separated(
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => EventCard(event: events[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.brown,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final HeritageEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateBadge(date: event.date),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(text: event.category),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InfoRow(
                        icon: Icons.location_on_outlined,
                        text: event.location,
                      ),
                      const SizedBox(height: 2),
                      InfoRow(
                        icon: Icons.schedule_rounded,
                        text: Fmt.time(event.date),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(event.description, style: t.bodyMedium?.copyWith(height: 1.6)),
            const SizedBox(height: 14),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: AppColors.sand,
                foregroundColor: AppColors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => showBookingSheet(
                context,
                type: BookingType.event,
                targetId: event.id,
                title: event.title,
                fixedDate: event.date,
              ),
              child: const Text(
                'احجز مقعدك',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brown,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: t.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Fmt.month(date),
            style: t.labelMedium?.copyWith(color: AppColors.sand),
          ),
        ],
      ),
    );
  }
}
