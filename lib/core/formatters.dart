/// Lightweight Arabic date/price formatting without extra dependencies.
class Fmt {
  Fmt._();

  static const _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  static const _weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String month(DateTime d) => _months[d.month - 1];

  static String date(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} ${month(d)}';

  static String time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'ص' : 'م'}';
  }

  static String dateTime(DateTime d) => '${date(d)} • ${time(d)}';

  static String price(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf ر.س';
  }

  static String remaining(DateTime end) {
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 'انتهى';
    if (diff.inDays > 0) {
      return 'متبقٍ ${diff.inDays} يوم و${diff.inHours % 24} ساعة';
    }
    if (diff.inHours > 0) return 'متبقٍ ${diff.inHours} ساعة';
    return 'متبقٍ ${diff.inMinutes} دقيقة';
  }
}
