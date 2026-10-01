import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'common.dart';

/// Bottom sheet for booking a heritage place visit or an event seat.
///
/// For events the date is fixed to the event date; for places the
/// visitor picks a date and time slot.
Future<void> showBookingSheet(
  BuildContext context, {
  required BookingType type,
  required String targetId,
  required String title,
  DateTime? fixedDate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.cream,
    builder: (_) => _BookingSheet(
      type: type,
      targetId: targetId,
      title: title,
      fixedDate: fixedDate,
    ),
  );
}

class _BookingSheet extends StatefulWidget {
  final BookingType type;
  final String targetId;
  final String title;
  final DateTime? fixedDate;

  const _BookingSheet({
    required this.type,
    required this.targetId,
    required this.title,
    this.fixedDate,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  static const _slots = [9, 12, 16, 19];

  late DateTime _day;
  int _slot = _slots.first;
  int _guests = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = widget.fixedDate ?? DateTime(now.year, now.month, now.day + 1);
  }

  DateTime get _selected =>
      widget.fixedDate ?? DateTime(_day.year, _day.month, _day.day, _slot);

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _day = picked);
  }

  void _confirm() {
    final user = context.auth.currentUser;
    if (user == null) return;
    final booking = context.repo.book(
      type: widget.type,
      targetId: widget.targetId,
      targetTitle: widget.title,
      dateTime: _selected,
      guests: _guests,
      userId: user.id,
    );
    Navigator.pop(context);
    showMessage(context, 'تم تأكيد الحجز • رقم الحجز ${booking.id}');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حجز: ${widget.title}',
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          if (widget.fixedDate == null) ...[
            Text(
              'التاريخ',
              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDay,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(Fmt.date(_day)),
            ),
            const SizedBox(height: 16),
            Text(
              'الوقت',
              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final h in _slots)
                  ChoiceChip(
                    label: Text(Fmt.time(DateTime(2000, 1, 1, h))),
                    selected: _slot == h,
                    labelStyle: TextStyle(
                      color: _slot == h ? Colors.white : AppColors.brown,
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _slot = h),
                  ),
              ],
            ),
          ] else
            InfoRow(
              icon: Icons.event_rounded,
              text: Fmt.dateTime(widget.fixedDate!),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'عدد الأشخاص',
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$_guests', style: t.titleLarge),
              ),
              IconButton.filledTonal(
                onPressed: _guests < 10
                    ? () => setState(() => _guests++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _confirm, child: const Text('تأكيد الحجز')),
        ],
      ),
    );
  }
}
