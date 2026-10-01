import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/countdown.dart';
import 'auction_details_screen.dart';

class AuctionsScreen extends StatefulWidget {
  const AuctionsScreen({super.key});

  @override
  State<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends State<AuctionsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items =
        context.repo.auctions.where((a) => a.title.contains(_query)).toList()
          ..sort((a, b) => a.endsAt.compareTo(b.endsAt));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverList.list(
              children: [
                Text(
                  'مزادات التراث',
                  style: t.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قطع تراثية أصيلة بانتظار مالكها الجديد',
                  style: t.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                SearchField(
                  hint: 'ابحث في المزادات',
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.gavel_rounded,
                title: 'لا توجد مزادات مطابقة',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => AuctionTile(item: items[i]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows whether the signed-in user is leading or has been outbid.
class BidStatusPill extends StatelessWidget {
  final AuctionItem item;

  const BidStatusPill({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final user = context.auth.currentUser;
    if (user == null || !item.hasBidFrom(user.id)) {
      return const SizedBox.shrink();
    }
    return item.isLeading(user.id)
        ? const Pill(
            text: 'أنت الأعلى',
            icon: Icons.emoji_events_rounded,
            color: Color(0xFF2E7D32),
            textColor: Colors.white,
          )
        : Pill(
            text: 'تمت المزايدة عليك',
            icon: Icons.trending_up_rounded,
            color: Colors.red.shade700,
            textColor: Colors.white,
          );
  }
}

class AuctionTile extends StatelessWidget {
  final AuctionItem item;

  const AuctionTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AuctionDetailsScreen(auctionId: item.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'auction-${item.id}',
                    child: Image.asset(item.image, fit: BoxFit.cover),
                  ),
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: BidStatusPill(item: item),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Fmt.price(item.currentPrice),
                    style: t.titleMedium?.copyWith(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Countdown(
                          endsAt: item.endsAt,
                          style: t.labelSmall?.copyWith(color: AppColors.muted),
                          urgentStyle: t.labelMedium?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${item.bids.length} مزايدة',
                        style: t.labelSmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
