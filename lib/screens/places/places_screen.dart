import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/booking_sheet.dart';
import '../../widgets/common.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = context.auth.currentUser;
    final places = context.repo.places
        .where((p) => p.title.contains(_query) || p.city.contains(_query))
        .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverList.list(
              children: [
                Text(
                  'مرحبًا ${user?.name ?? ''}',
                  style: t.titleMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  'المواقع التاريخية',
                  style: t.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                SearchField(
                  hint: 'ابحث باسم الموقع أو المدينة',
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ],
            ),
          ),
          if (places.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'لا توجد نتائج',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.separated(
                itemCount: places.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => PlaceCard(place: places[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final HeritagePlace place;

  const PlaceCard({super.key, required this.place});

  Future<void> _openMap(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(place.mapUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      showMessage(context, 'تعذّر فتح الخريطة', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(place.image, fit: BoxFit.cover),
              ),
              if (place.isUnesco)
                const PositionedDirectional(
                  top: 12,
                  start: 12,
                  child: Pill(
                    text: 'تراث عالمي – اليونسكو',
                    icon: Icons.verified_rounded,
                    color: AppColors.gold,
                    textColor: Colors.white,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                InfoRow(icon: Icons.location_on_outlined, text: place.city),
                if (place.openingHours.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  InfoRow(
                    icon: Icons.schedule_rounded,
                    text: place.openingHours,
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  place.description,
                  style: t.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showBookingSheet(
                          context,
                          type: BookingType.place,
                          targetId: place.id,
                          title: place.title,
                        ),
                        icon: const Icon(Icons.confirmation_number_outlined),
                        label: const Text('احجز زيارة'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 56,
                      child: OutlinedButton(
                        onPressed: () => _openMap(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.map_outlined),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
