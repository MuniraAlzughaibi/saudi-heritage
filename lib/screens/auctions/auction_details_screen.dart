import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/countdown.dart';
import 'bid_sheet.dart';

class AuctionDetailsScreen extends StatelessWidget {
  final String auctionId;

  const AuctionDetailsScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = context.auth.currentUser;
    final item = context.repo.auctions
        .where((a) => a.id == auctionId)
        .firstOrNull;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.gavel_rounded,
          title: 'هذا المزاد لم يعد متاحًا',
        ),
      );
    }
    final bids = item.bids.reversed.toList();
    final canBid =
        user != null &&
        !user.isAdmin &&
        item.isOpen &&
        !item.isLeading(user.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.cream,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'auction-${item.id}',
                child: Image.asset(item.image, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                if (user != null && item.hasBidFrom(user.id)) ...[
                  _LeadBanner(leading: item.isLeading(user.id)),
                  const SizedBox(height: 16),
                ],
                Text(
                  item.title,
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: t.bodyLarge?.copyWith(
                    height: 1.6,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'السعر الحالي',
                        highlight: true,
                        child: Text(Fmt.price(item.currentPrice)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        label: 'ينتهي خلال',
                        child: Countdown(endsAt: item.endsAt),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'سعر الافتتاح',
                        child: Text(Fmt.price(item.startingPrice)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        label: 'عدد المزايدات',
                        child: Text('${item.bids.length}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'سجل المزايدات',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (bids.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'كن أول من يزايد على هذه القطعة',
                      style: t.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  )
                else
                  for (final (i, bid) in bids.indexed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: i == 0
                            ? AppColors.gold
                            : AppColors.sand,
                        child: Icon(
                          i == 0
                              ? Icons.emoji_events_rounded
                              : Icons.person_outline,
                          color: i == 0 ? Colors.white : AppColors.brown,
                        ),
                      ),
                      title: Text(
                        bid.bidderId == user?.id
                            ? '${bid.bidderName} (أنت)'
                            : bid.bidderName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(Fmt.dateTime(bid.time)),
                      trailing: Text(
                        Fmt.price(bid.amount),
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: user == null || user.isAdmin
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton.icon(
                  onPressed: canBid ? () => showBidSheet(context, item) : null,
                  icon: const Icon(Icons.gavel_rounded),
                  label: Text(switch ((item.isOpen, item.isLeading(user.id))) {
                    (false, true) => 'فزت بهذا المزاد',
                    (false, false) => 'انتهى المزاد',
                    (true, true) => 'مزايدتك هي الأعلى',
                    (true, false) =>
                      'زايد الآن • من ${Fmt.price(item.minimumNextBid)}',
                  }),
                ),
              ),
            ),
    );
  }
}

class _LeadBanner extends StatelessWidget {
  final bool leading;

  const _LeadBanner({required this.leading});

  @override
  Widget build(BuildContext context) {
    final color = leading ? const Color(0xFF2E7D32) : Colors.red.shade700;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            leading ? Icons.emoji_events_rounded : Icons.trending_up_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              leading
                  ? 'مزايدتك هي الأعلى حاليًا'
                  : 'تمت المزايدة عليك! زايد من جديد للحفاظ على فرصتك',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final Widget child;
  final bool highlight;

  const _Stat({
    required this.label,
    required this.child,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.brown : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight ? AppColors.brown : AppColors.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: t.labelMedium?.copyWith(
              color: highlight ? AppColors.sand : AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight ? Colors.white : AppColors.ink,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// The user's "My bids" list, reused from the account screen.
class MyBidsScreen extends StatelessWidget {
  const MyBidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = context.auth.currentUser;
    final items = user == null
        ? <AuctionItem>[]
        : context.repo.auctionsBidBy(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('مزايداتي')),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.gavel_rounded,
              title: 'لم تزايد على أي قطعة بعد',
              subtitle: 'تصفّح المزادات وقدّم أول مزايدة لك',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final a = items[i];
                final mine = a.bids.where((b) => b.bidderId == user!.id).last;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AuctionDetailsScreen(auctionId: a.id),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          a.image,
                          width: 96,
                          height: 104,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'مزايدتك ${Fmt.price(mine.amount)} • الحالي ${Fmt.price(a.currentPrice)}',
                                  style: t.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (a.isLeading(user!.id))
                                      const Pill(
                                        text: 'أنت الأعلى',
                                        color: Color(0xFF2E7D32),
                                        textColor: Colors.white,
                                      )
                                    else
                                      Pill(
                                        text: 'تمت المزايدة عليك',
                                        color: Colors.red.shade700,
                                        textColor: Colors.white,
                                      ),
                                    const SizedBox(width: 8),
                                    Countdown(
                                      endsAt: a.endsAt,
                                      style: t.labelSmall?.copyWith(
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
