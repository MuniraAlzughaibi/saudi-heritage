import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../auctions/auction_details_screen.dart';
import '../auth/welcome_screen.dart';
import '../bookings/bookings_screen.dart';
import 'contact_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _signOut(BuildContext context) {
    context.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  void _about(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Saudi Heritage',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset('assets/images/logo.png', width: 56),
      children: const [
        Text(
          'تطبيق يتيح استكشاف المواقع التراثية في المملكة، '
          'وحجز الفعاليات الثقافية، والمشاركة في مزادات القطع التراثية.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = context.auth.currentUser;
    final bookings = user == null
        ? 0
        : context.repo.bookingsFor(user.id).length;
    final bids = user == null ? 0 : context.repo.auctionsBidBy(user.id).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'حسابي',
            style: t.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.brown,
                    child: Text(
                      (user?.name.isNotEmpty ?? false)
                          ? user!.name.characters.first
                          : '؟',
                      style: t.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '',
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          textDirection: TextDirection.ltr,
                          style: t.bodyMedium?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.confirmation_number_outlined,
                  title: 'حجوزاتي',
                  trailing: bookings > 0 ? '$bookings' : null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingsScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.gavel_rounded,
                  title: 'مزايداتي',
                  trailing: bids > 0 ? '$bids' : null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBidsScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'تواصل معنا',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'عن التطبيق',
                  onTap: () => _about(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: _MenuTile(
              icon: Icons.logout_rounded,
              title: 'تسجيل الخروج',
              color: Colors.red.shade700,
              onTap: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final Color? color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.brown;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.terracotta,
              child: Text(
                trailing!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          if (color == null)
            const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
