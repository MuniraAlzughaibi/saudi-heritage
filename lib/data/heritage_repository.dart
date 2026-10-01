import 'dart:async';

import 'package:flutter/foundation.dart';

import 'demo_data.dart';
import 'models.dart';

/// Data access contract for the app.
///
/// The UI depends only on this interface, so the in-memory demo
/// implementation below can be swapped for a Firebase (or REST) one
/// without touching any screen.
abstract class HeritageRepository extends ChangeNotifier {
  List<HeritagePlace> get places;
  List<HeritageEvent> get events;
  List<AuctionItem> get auctions;
  List<ContactMessage> get messages;
  List<Booking> bookingsFor(String userId);
  int get totalBookings;

  void savePlace(HeritagePlace place);
  void deletePlace(String id);
  void saveEvent(HeritageEvent event);
  void deleteEvent(String id);
  void saveAuction(AuctionItem item);
  void deleteAuction(String id);

  Booking book({
    required BookingType type,
    required String targetId,
    required String targetTitle,
    required DateTime dateTime,
    required int guests,
    required String userId,
  });
  void cancelBooking(String id);

  /// Auctions the user has bid on, ending soonest first.
  List<AuctionItem> auctionsBidBy(String userId);

  /// Throws [ArgumentError] when the auction is closed or the bid is below
  /// [AuctionItem.minimumNextBid].
  void placeBid(
    String auctionId, {
    required String bidderId,
    required String bidderName,
    required double amount,
  });

  /// Emits whenever a user loses the lead on an auction.
  Stream<OutbidAlert> get outbidAlerts;

  void sendMessage({
    required String name,
    required String email,
    required String message,
  });

  /// Generates an id for new items created from the admin panel.
  String newId(String prefix);
}

class OutbidAlert {
  final String userId;
  final AuctionItem item;

  const OutbidAlert({required this.userId, required this.item});
}

class DemoHeritageRepository extends HeritageRepository {
  /// When true, a rival bidder answers the user's bids after a short delay
  /// so the auction flow (leading → outbid → bid again) can be tried in the demo.
  final bool simulateRivals;
  final Duration rivalDelay;

  DemoHeritageRepository({
    this.simulateRivals = false,
    this.rivalDelay = const Duration(seconds: 8),
  });

  final List<HeritagePlace> _places = [...DemoData.places];
  final List<HeritageEvent> _events = DemoData.events();
  final List<AuctionItem> _auctions = DemoData.auctions();
  final List<ContactMessage> _messages = DemoData.messages();
  final List<Booking> _bookings = DemoData.bookings();
  final _outbid = StreamController<OutbidAlert>.broadcast();
  final List<Timer> _rivalTimers = [];
  int _seq = 100;

  String _nextId(String prefix) => '$prefix${_seq++}';

  @override
  List<HeritagePlace> get places => List.unmodifiable(_places);

  @override
  List<HeritageEvent> get events =>
      List.unmodifiable([..._events]..sort((a, b) => a.date.compareTo(b.date)));

  @override
  List<AuctionItem> get auctions => List.unmodifiable(_auctions);

  @override
  List<ContactMessage> get messages => List.unmodifiable(
    [..._messages]..sort((a, b) => b.sentAt.compareTo(a.sentAt)),
  );

  @override
  List<Booking> bookingsFor(String userId) =>
      _bookings.where((b) => b.userId == userId).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  @override
  int get totalBookings => _bookings.length;

  void _upsert<T>(List<T> list, T item, String Function(T) idOf) {
    final i = list.indexWhere((e) => idOf(e) == idOf(item));
    if (i == -1) {
      list.add(item);
    } else {
      list[i] = item;
    }
    notifyListeners();
  }

  @override
  void savePlace(HeritagePlace place) => _upsert(_places, place, (p) => p.id);

  @override
  void deletePlace(String id) {
    _places.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  @override
  void saveEvent(HeritageEvent event) => _upsert(_events, event, (e) => e.id);

  @override
  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  @override
  void saveAuction(AuctionItem item) => _upsert(_auctions, item, (a) => a.id);

  @override
  void deleteAuction(String id) {
    _auctions.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  @override
  Booking book({
    required BookingType type,
    required String targetId,
    required String targetTitle,
    required DateTime dateTime,
    required int guests,
    required String userId,
  }) {
    final booking = Booking(
      id: _nextId('BK-'),
      type: type,
      targetId: targetId,
      targetTitle: targetTitle,
      dateTime: dateTime,
      guests: guests,
      userId: userId,
      createdAt: DateTime.now(),
    );
    _bookings.add(booking);
    notifyListeners();
    return booking;
  }

  @override
  void cancelBooking(String id) {
    _bookings.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  @override
  Stream<OutbidAlert> get outbidAlerts => _outbid.stream;

  @override
  List<AuctionItem> auctionsBidBy(String userId) =>
      _auctions.where((a) => a.hasBidFrom(userId)).toList()
        ..sort((a, b) => a.endsAt.compareTo(b.endsAt));

  @override
  void placeBid(
    String auctionId, {
    required String bidderId,
    required String bidderName,
    required double amount,
  }) {
    final i = _auctions.indexWhere((a) => a.id == auctionId);
    if (i == -1) throw ArgumentError('هذا المزاد لم يعد متاحًا');
    final item = _auctions[i];
    if (!item.isOpen) throw ArgumentError('انتهى هذا المزاد');
    if (item.isLeading(bidderId)) {
      throw ArgumentError('مزايدتك هي الأعلى حاليًا');
    }
    if (amount < item.minimumNextBid) {
      throw ArgumentError(
        'أقل مزايدة مسموحة ${item.minimumNextBid.toStringAsFixed(0)} ريال',
      );
    }

    final previousLeader = item.leadingBid?.bidderId;
    final updated = item.copyWith(
      bids: [
        ...item.bids,
        Bid(
          bidderId: bidderId,
          bidderName: bidderName,
          amount: amount,
          time: DateTime.now(),
        ),
      ],
    );
    _auctions[i] = updated;
    notifyListeners();

    if (previousLeader != null && previousLeader != bidderId) {
      _outbid.add(OutbidAlert(userId: previousLeader, item: updated));
    }
    if (simulateRivals && !bidderId.startsWith('rival-')) {
      _scheduleRival(auctionId, bidderId);
    }
  }

  /// A rival answers once per user bid, and stops once the price has
  /// doubled so the user can eventually win.
  void _scheduleRival(String auctionId, String userId) {
    _rivalTimers.add(
      Timer(rivalDelay, () {
        final item = _auctions.where((a) => a.id == auctionId).firstOrNull;
        if (item == null || !item.isOpen || !item.isLeading(userId)) return;
        if (item.currentPrice >= item.startingPrice * 2) return;
        final name = DemoData
            .rivalBidders[item.bids.length % DemoData.rivalBidders.length];
        placeBid(
          auctionId,
          bidderId: 'rival-$name',
          bidderName: name,
          amount: item.minimumNextBid,
        );
      }),
    );
  }

  @override
  void dispose() {
    for (final t in _rivalTimers) {
      t.cancel();
    }
    _outbid.close();
    super.dispose();
  }

  @override
  void sendMessage({
    required String name,
    required String email,
    required String message,
  }) {
    _messages.add(
      ContactMessage(
        id: _nextId('M-'),
        name: name,
        email: email,
        message: message,
        sentAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  @override
  String newId(String prefix) => _nextId(prefix);
}
