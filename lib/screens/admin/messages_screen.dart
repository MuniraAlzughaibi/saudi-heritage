import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final messages = context.repo.messages;
    return Scaffold(
      appBar: AppBar(title: const Text('رسائل الزوار')),
      body: messages.isEmpty
          ? const EmptyState(icon: Icons.forum_outlined, title: 'لا توجد رسائل')
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final m = messages[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.sand,
                              child: Text(
                                m.name.characters.first,
                                style: const TextStyle(
                                  color: AppColors.brown,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    m.email,
                                    textDirection: TextDirection.ltr,
                                    style: t.bodySmall?.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Fmt.date(m.sentAt),
                              style: t.labelSmall?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          m.message,
                          style: t.bodyMedium?.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
