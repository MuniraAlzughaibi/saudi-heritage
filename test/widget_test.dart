import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heritage_app/data/auth_service.dart';
import 'package:heritage_app/data/heritage_repository.dart';
import 'package:heritage_app/data/models.dart';
import 'package:heritage_app/main.dart';

void main() {
  group('DemoHeritageRepository', () {
    test('booking is stored for the user and can be cancelled', () {
      final repo = DemoHeritageRepository();
      final booking = repo.book(
        type: BookingType.place,
        targetId: 'p1',
        targetTitle: 'حي الطريف',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        guests: 2,
        userId: 'u1',
      );
      expect(repo.bookingsFor('u1'), hasLength(1));
      expect(repo.bookingsFor('u2'), isEmpty);

      repo.cancelBooking(booking.id);
      expect(repo.bookingsFor('u1'), isEmpty);
    });

    test('bids below the minimum are rejected', () {
      final repo = DemoHeritageRepository();
      final item = repo.auctions.first;

      expect(
        () => repo.placeBid(
          item.id,
          bidderId: 't1',
          bidderName: 'test',
          amount: item.currentPrice,
        ),
        throwsArgumentError,
      );

      repo.placeBid(
        item.id,
        bidderId: 't1',
        bidderName: 'test',
        amount: item.minimumNextBid,
      );
      final updated = repo.auctions.firstWhere((a) => a.id == item.id);
      expect(updated.currentPrice, item.minimumNextBid);
      expect(updated.bids.last.bidderName, 'test');
    });

    test(
      'leader cannot outbid themselves and the previous leader is alerted',
      () async {
        final repo = DemoHeritageRepository();
        final item = repo.auctions.firstWhere((a) => a.bids.isNotEmpty);
        final previousLeader = item.leadingBid!.bidderId;
        final alerts = <OutbidAlert>[];
        final sub = repo.outbidAlerts.listen(alerts.add);

        repo.placeBid(
          item.id,
          bidderId: 'me',
          bidderName: 'me',
          amount: item.minimumNextBid,
        );
        await Future<void>.delayed(Duration.zero);
        expect(alerts.single.userId, previousLeader);

        final updated = repo.auctions.firstWhere((a) => a.id == item.id);
        expect(updated.isLeading('me'), isTrue);
        expect(
          () => repo.placeBid(
            item.id,
            bidderId: 'me',
            bidderName: 'me',
            amount: updated.minimumNextBid,
          ),
          throwsArgumentError,
        );
        expect(repo.auctionsBidBy('me').map((a) => a.id), [item.id]);
        await sub.cancel();
      },
    );

    test('rival bidder answers in demo mode', () {
      fakeAsync((async) {
        final repo = DemoHeritageRepository(
          simulateRivals: true,
          rivalDelay: const Duration(seconds: 5),
        );
        final item = repo.auctions.first;
        repo.placeBid(
          item.id,
          bidderId: 'me',
          bidderName: 'me',
          amount: item.minimumNextBid,
        );
        expect(repo.auctions.first.isLeading('me'), isTrue);

        async.elapse(const Duration(seconds: 6));
        expect(repo.auctions.first.isLeading('me'), isFalse);
        expect(repo.auctions.first.leadingBid!.bidderId, startsWith('rival-'));
        repo.dispose();
      });
    });

    test('events are sorted by date', () {
      final dates = DemoHeritageRepository().events.map((e) => e.date).toList();
      final sorted = [...dates]..sort();
      expect(dates, sorted);
    });
  });

  group('DemoAuthService', () {
    test('demo accounts sign in with the right roles', () async {
      final auth = DemoAuthService();
      final admin = await auth.signIn(
        DemoAccounts.adminEmail,
        DemoAccounts.password,
      );
      expect(admin.isAdmin, isTrue);

      final visitor = await auth.signIn(
        DemoAccounts.visitorEmail,
        DemoAccounts.password,
      );
      expect(visitor.isAdmin, isFalse);
    });

    test('wrong password is rejected', () async {
      final auth = DemoAuthService();
      expect(
        () => auth.signIn(DemoAccounts.visitorEmail, 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });

    test('sign up rejects duplicate emails and short passwords', () async {
      final auth = DemoAuthService();
      expect(
        () => auth.signUp(
          name: 'x',
          email: DemoAccounts.visitorEmail,
          password: '12345678',
        ),
        throwsA(isA<AuthException>()),
      );
      expect(
        () =>
            auth.signUp(name: 'x', email: 'new@heritage.demo', password: '123'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  testWidgets('welcome screen shows login and sign-up actions', (tester) async {
    await tester.pumpWidget(
      HeritageApp(
        repository: DemoHeritageRepository(),
        auth: DemoAuthService(),
      ),
    );
    await tester.pump();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('إنشاء حساب جديد'), findsOneWidget);
  });
}
