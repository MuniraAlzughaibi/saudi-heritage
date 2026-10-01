import 'dart:async';

import 'package:flutter/material.dart';

/// Text that counts down to [endsAt], refreshing every second.
/// Shows days/hours when far away and a ticking HH:MM:SS clock in the last day.
class Countdown extends StatefulWidget {
  final DateTime endsAt;
  final TextStyle? style;
  final TextStyle? urgentStyle;

  const Countdown({
    super.key,
    required this.endsAt,
    this.style,
    this.urgentStyle,
  });

  static String format(Duration d) {
    if (d.isNegative || d == Duration.zero) return 'انتهى';
    if (d.inDays > 0) return '${d.inDays} يوم و${d.inHours % 24} ساعة';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (DateTime.now().isAfter(widget.endsAt)) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.endsAt.difference(DateTime.now());
    final urgent = left.inDays == 0;
    return Text(
      Countdown.format(left),
      textDirection: urgent ? TextDirection.ltr : null,
      style: urgent ? (widget.urgentStyle ?? widget.style) : widget.style,
    );
  }
}
