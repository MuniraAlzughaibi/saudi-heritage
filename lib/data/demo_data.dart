import 'models.dart';

/// Sample content used by [DemoHeritageRepository].
/// Dates are relative to "now" so the demo always shows upcoming events
/// and running auctions.
class DemoData {
  DemoData._();

  static const places = <HeritagePlace>[
    HeritagePlace(
      id: 'p1',
      title: 'حي الطريف',
      city: 'الدرعية',
      description:
          'العاصمة الأولى للدولة السعودية ومن أبرز نماذج العمارة النجدية الطينية. '
          'يضم قصر سلوى وعددًا من القصور والمساجد التاريخية.',
      image: 'assets/images/at_turaif.jpg',
      mapUrl: 'https://maps.google.com/?q=At-Turaif+District+Diriyah',
      openingHours: 'يوميًا 4 م – 12 ص',
      isUnesco: true,
    ),
    HeritagePlace(
      id: 'p2',
      title: 'قصر المصمك',
      city: 'الرياض',
      description:
          'حصن طيني بُني عام 1865م، وشهد استرداد الرياض عام 1902م. '
          'يضم اليوم متحفًا يحكي قصة توحيد المملكة.',
      image: 'assets/images/masmak.jpg',
      mapUrl: 'https://maps.google.com/?q=Masmak+Fortress+Riyadh',
      openingHours: 'السبت – الخميس 8 ص – 9 م',
    ),
    HeritagePlace(
      id: 'p3',
      title: 'الحِجر (مدائن صالح)',
      city: 'العُلا',
      description:
          'أول موقع سعودي يُدرج في قائمة التراث العالمي لليونسكو، '
          'ويضم أكثر من 100 مقبرة نبطية منحوتة في الصخر.',
      image: 'assets/images/hegra.jpg',
      mapUrl: 'https://maps.google.com/?q=Hegra+AlUla',
      openingHours: 'يوميًا 9 ص – 6 م',
      isUnesco: true,
    ),
  ];

  static List<HeritageEvent> events() {
    final now = DateTime.now();
    DateTime inDays(int d, int hour) =>
        DateTime(now.year, now.month, now.day + d, hour);
    return [
      HeritageEvent(
        id: 'e1',
        title: 'ليالي الدرعية',
        date: inDays(5, 19),
        location: 'الدرعية – حي البجيري',
        description:
            'أمسيات ثقافية تجمع الفنون الشعبية والمأكولات التراثية والحِرف اليدوية.',
        category: 'مهرجان',
      ),
      HeritageEvent(
        id: 'e2',
        title: 'ورشة الخط العربي',
        date: inDays(9, 17),
        location: 'الرياض – المتحف الوطني',
        description:
            'ورشة للمبتدئين لتعلّم أساسيات خط الثلث مع خطاطين محترفين.',
        category: 'ورشة',
      ),
      HeritageEvent(
        id: 'e3',
        title: 'جولة الحِجر الليلية',
        date: inDays(14, 20),
        location: 'العُلا – الحِجر',
        description:
            'جولة مسائية بصحبة راوٍ محلي تحكي قصص الأنباط تحت السماء المفتوحة.',
        category: 'جولة',
      ),
      HeritageEvent(
        id: 'e4',
        title: 'معرض الحرف اليدوية',
        date: inDays(21, 16),
        location: 'جدة – البلد التاريخية',
        description: 'معرض لأعمال الحرفيين في السدو والفخار وصناعة الخناجر.',
        category: 'معرض',
      ),
    ];
  }

  /// Names used by the simulated rival bidder in demo mode.
  static const rivalBidders = ['سعد', 'نورة', 'عبدالله', 'خالد', 'ريم'];

  static List<AuctionItem> auctions() {
    final now = DateTime.now();
    return [
      AuctionItem(
        id: 'a1',
        title: 'خنجر احتفالي مذهّب',
        description:
            'خنجر عربي تقليدي بغمد مزخرف بخيوط الذهب، من مطلع القرن العشرين.',
        image: 'assets/images/khanjar.jpg',
        startingPrice: 3500,
        endsAt: now.add(const Duration(days: 2, hours: 5)),
        bids: [
          Bid(
            bidderId: 's1',
            bidderName: 'سعد',
            amount: 3700,
            time: now.subtract(const Duration(hours: 6)),
          ),
          Bid(
            bidderId: 's2',
            bidderName: 'نورة',
            amount: 3900,
            time: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      AuctionItem(
        id: 'a2',
        title: 'دلّتان نحاسيتان',
        description: 'زوج من دلال القهوة العربية النحاسية المصنوعة يدويًا.',
        image: 'assets/images/dallah.jpg',
        startingPrice: 1200,
        endsAt: now.add(const Duration(hours: 5, minutes: 30)),
        bids: [
          Bid(
            bidderId: 's3',
            bidderName: 'عبدالله',
            amount: 1300,
            time: now.subtract(const Duration(hours: 3)),
          ),
        ],
      ),
      AuctionItem(
        id: 'a3',
        title: 'جرّة فخارية بنقوش تقليدية',
        description: 'جرّة فخارية لحفظ الماء بزخارف محفورة يدويًا.',
        image: 'assets/images/jar.jpg',
        startingPrice: 800,
        endsAt: now.add(const Duration(days: 1, hours: 3)),
        bids: [
          Bid(
            bidderId: 's4',
            bidderName: 'خالد',
            amount: 850,
            time: now.subtract(const Duration(hours: 9)),
          ),
        ],
      ),
      AuctionItem(
        id: 'a4',
        title: 'جلسة بنقشة السدو',
        description:
            'طقم جلسة أرضية مع مساند، منسوج بنقشة السدو البدوية الأصيلة.',
        image: 'assets/images/sadu.jpg',
        startingPrice: 2500,
        endsAt: now.add(const Duration(days: 6)),
      ),
    ];
  }

  /// Bookings made by other (sample) visitors, so the admin stats are not empty.
  static List<Booking> bookings() {
    final now = DateTime.now();
    Booking sample(
      String id,
      BookingType type,
      String targetId,
      String title,
      int inDays,
      int guests,
    ) => Booking(
      id: id,
      type: type,
      targetId: targetId,
      targetTitle: title,
      dateTime: DateTime(now.year, now.month, now.day + inDays, 16),
      guests: guests,
      userId: 'sample-$id',
      createdAt: now.subtract(const Duration(days: 1)),
    );
    return [
      sample('BK-001', BookingType.place, 'p1', 'حي الطريف', 2, 4),
      sample('BK-002', BookingType.place, 'p2', 'قصر المصمك', 3, 2),
      sample('BK-003', BookingType.event, 'e1', 'ليالي الدرعية', 5, 3),
      sample('BK-004', BookingType.event, 'e2', 'ورشة الخط العربي', 9, 1),
    ];
  }

  static List<ContactMessage> messages() {
    final now = DateTime.now();
    return [
      ContactMessage(
        id: 'm1',
        name: 'ريم',
        email: 'reem@example.com',
        message: 'هل تتوفر جولات بالإنجليزية في حي الطريف؟',
        sentAt: now.subtract(const Duration(days: 1)),
      ),
      ContactMessage(
        id: 'm2',
        name: 'فهد',
        email: 'fahad@example.com',
        message: 'أقترح إضافة إشعار قبل انتهاء المزاد بساعة.',
        sentAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
