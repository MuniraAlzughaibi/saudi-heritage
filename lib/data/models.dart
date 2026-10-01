enum UserRole { visitor, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.visitor,
  });

  bool get isAdmin => role == UserRole.admin;
}

class HeritagePlace {
  final String id;
  final String title;
  final String city;
  final String description;
  final String image;
  final String mapUrl;
  final String openingHours;
  final bool isUnesco;

  const HeritagePlace({
    required this.id,
    required this.title,
    required this.city,
    required this.description,
    required this.image,
    required this.mapUrl,
    this.openingHours = '',
    this.isUnesco = false,
  });

  HeritagePlace copyWith({
    String? title,
    String? city,
    String? description,
    String? mapUrl,
    String? openingHours,
  }) {
    return HeritagePlace(
      id: id,
      title: title ?? this.title,
      city: city ?? this.city,
      description: description ?? this.description,
      image: image,
      mapUrl: mapUrl ?? this.mapUrl,
      openingHours: openingHours ?? this.openingHours,
      isUnesco: isUnesco,
    );
  }
}

class HeritageEvent {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final String category;

  const HeritageEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    this.category = 'ثقافة',
  });

  HeritageEvent copyWith({
    String? title,
    DateTime? date,
    String? location,
    String? description,
    String? category,
  }) {
    return HeritageEvent(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}

class Bid {
  final String bidderId;
  final String bidderName;
  final double amount;
  final DateTime time;

  const Bid({
    required this.bidderId,
    required this.bidderName,
    required this.amount,
    required this.time,
  });
}

class AuctionItem {
  final String id;
  final String title;
  final String description;
  final String image;
  final double startingPrice;
  final DateTime endsAt;
  final List<Bid> bids;

  const AuctionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.startingPrice,
    required this.endsAt,
    this.bids = const [],
  });

  double get currentPrice => bids.isEmpty ? startingPrice : bids.last.amount;

  Bid? get leadingBid => bids.isEmpty ? null : bids.last;

  bool isLeading(String userId) => leadingBid?.bidderId == userId;

  bool hasBidFrom(String userId) => bids.any((b) => b.bidderId == userId);

  /// Minimum allowed next bid: 5% above the current price, rounded up to 10 SAR.
  double get minimumNextBid {
    final raw = currentPrice * 1.05;
    return (raw / 10).ceil() * 10;
  }

  bool get isOpen => DateTime.now().isBefore(endsAt);

  /// Quick-bid options shown in the bid sheet: the minimum, then fixed steps above it.
  List<double> get quickBids {
    final min = minimumNextBid;
    final step = startingPrice >= 2000 ? 250.0 : 100.0;
    return [min, min + step, min + step * 2];
  }

  AuctionItem copyWith({
    String? title,
    String? description,
    double? startingPrice,
    DateTime? endsAt,
    List<Bid>? bids,
  }) {
    return AuctionItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image,
      startingPrice: startingPrice ?? this.startingPrice,
      endsAt: endsAt ?? this.endsAt,
      bids: bids ?? this.bids,
    );
  }
}

enum BookingType { place, event }

class Booking {
  final String id;
  final BookingType type;
  final String targetId;
  final String targetTitle;
  final DateTime dateTime;
  final int guests;
  final String userId;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.type,
    required this.targetId,
    required this.targetTitle,
    required this.dateTime,
    required this.guests,
    required this.userId,
    required this.createdAt,
  });
}

class ContactMessage {
  final String id;
  final String name;
  final String email;
  final String message;
  final DateTime sentAt;

  const ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.sentAt,
  });
}
