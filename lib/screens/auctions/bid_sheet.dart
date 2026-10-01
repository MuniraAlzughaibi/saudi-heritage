import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// Bottom sheet for placing a bid: quick-bid chips plus a custom amount,
/// validated against [AuctionItem.minimumNextBid] before submitting.
Future<void> showBidSheet(BuildContext context, AuctionItem item) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.cream,
    builder: (_) => _BidSheet(item: item),
  );
}

class _BidSheet extends StatefulWidget {
  final AuctionItem item;

  const _BidSheet({required this.item});

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  late final _amount = TextEditingController(
    text: widget.item.minimumNextBid.toStringAsFixed(0),
  );
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_amount.text.trim());
    final min = widget.item.minimumNextBid;
    if (value == null || value < min) {
      setState(() => _error = 'أقل مزايدة مسموحة ${Fmt.price(min)}');
      return;
    }
    final user = context.auth.currentUser!;
    try {
      context.repo.placeBid(
        widget.item.id,
        bidderId: user.id,
        bidderName: user.name,
        amount: value,
      );
      Navigator.pop(context);
      showMessage(context, 'أنت الآن صاحب أعلى مزايدة: ${Fmt.price(value)}');
    } on ArgumentError catch (e) {
      setState(() => _error = e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final item = widget.item;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'قدّم مزايدتك',
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.title} • السعر الحالي ${Fmt.price(item.currentPrice)}',
            style: t.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Text(
            'مزايدة سريعة',
            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, v) in item.quickBids.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      padding: EdgeInsets.zero,
                      backgroundColor: _amount.text == v.toStringAsFixed(0)
                          ? AppColors.sand
                          : null,
                    ),
                    onPressed: () => setState(() {
                      _amount.text = v.toStringAsFixed(0);
                      _error = null;
                    }),
                    child: FittedBox(child: Text(Fmt.price(v))),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: 'أو اكتب المبلغ',
              suffixText: 'ر.س',
              errorText: _error,
              helperText:
                  'الحد الأدنى ${Fmt.price(item.minimumNextBid)} (+5% على السعر الحالي)',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.gavel_rounded),
            label: const Text('تأكيد المزايدة'),
          ),
        ],
      ),
    );
  }
}
