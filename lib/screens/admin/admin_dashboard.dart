import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../auth/welcome_screen.dart';
import 'manage_auctions_screen.dart';
import 'manage_events_screen.dart';
import 'manage_places_screen.dart';
import 'messages_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final repo = context.repo;
    final totalBids = repo.auctions.fold<int>(
      0,
      (sum, a) => sum + a.bids.length,
    );
    final auctionValue = repo.auctions.fold<double>(
      0,
      (sum, a) => sum + a.currentPrice,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'نظرة عامة',
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                icon: Icons.confirmation_number_outlined,
                label: 'الحجوزات',
                value: '${repo.totalBookings}',
              ),
              _StatCard(
                icon: Icons.gavel_rounded,
                label: 'المزايدات',
                value: '$totalBids',
              ),
              _StatCard(
                icon: Icons.payments_outlined,
                label: 'قيمة المزادات',
                value: Fmt.price(auctionValue),
              ),
              _StatCard(
                icon: Icons.mail_outline_rounded,
                label: 'الرسائل',
                value: '${repo.messages.length}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'إدارة المحتوى',
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _ManageTile(
            icon: Icons.account_balance_outlined,
            title: 'المواقع التاريخية',
            count: repo.places.length,
            onTap: () => _open(context, const ManagePlacesScreen()),
          ),
          _ManageTile(
            icon: Icons.event_outlined,
            title: 'الفعاليات',
            count: repo.events.length,
            onTap: () => _open(context, const ManageEventsScreen()),
          ),
          _ManageTile(
            icon: Icons.gavel_outlined,
            title: 'المزادات',
            count: repo.auctions.length,
            onTap: () => _open(context, const ManageAuctionsScreen()),
          ),
          _ManageTile(
            icon: Icons.forum_outlined,
            title: 'رسائل الزوار',
            count: repo.messages.length,
            onTap: () => _open(context, const MessagesScreen()),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.terracotta),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    value,
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  label,
                  style: t.labelMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  const _ManageTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: AppColors.sand,
            child: Icon(icon, color: AppColors.brown),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text('$count عنصر'),
          trailing: const Icon(Icons.chevron_left_rounded),
        ),
      ),
    );
  }
}
