
import '../core/units.dart';

enum BuyerStatus { none, pending, returned, approved, rejected, suspended }

class CompanyProfile {
  String legalName = '', tradeName = '', type = 'trader';
  String gstin = '', pan = '', cin = '', fssai = '';
  String regAddress = '', whAddress = '', contact = '', designation = '', email = '';
  String commodities = '', monthlyVolume = '', districts = '', varieties = '';
  QtyUnit volumeUnit = QtyUnit.tonne;
  List<String> languages = ['Tamil', 'English'];

  // document key -> file name
  Map<String, String> docs = {};
}

const List<String> buyerTypes = [
  'trader',
  'mill',
  'processor',
  'exporter',
  'retailer',
  'FPO',
  'other',
];

class Listing {
  final String id, crop, variety, grade, village, district, farmerFirstName;
  double quantity; // remaining, in [unit]
  final QtyUnit unit;
  final double expectedPrice; // per unit
  final DateTime readyDate, listedAt;

  Listing({
    required this.id,
    required this.crop,
    required this.variety,
    required this.grade,
    required this.village,
    required this.district,
    required this.farmerFirstName,
    required this.quantity,
    required this.unit,
    required this.expectedPrice,
    required this.readyDate,
    required this.listedAt,
  });

  double? get kg => toKg(quantity, unit, crop);
}

class ListingFilter {
  String? crop, district;
  double? minQty;
  DateTime? readyBy;
  QtyUnit? unit;

  bool get active =>
      crop != null ||
          district != null ||
          minQty != null ||
          readyBy != null ||
          unit != null;
}

// Chat message loaded from MySQL.
class ChatMsg {
  final String id;
  final bool fromBuyer;
  final String text;
  final DateTime time;

  ChatMsg(
      this.fromBuyer,
      this.text, {
        this.id = '',
        DateTime? time,
      }) : time = time ?? DateTime.now();

  factory ChatMsg.fromJson(Map<String, dynamic> json) {
    return ChatMsg(
      (json['sender_type'] ?? '').toString() == 'buyer',
      (json['message'] ?? '').toString(),
      id: (json['id'] ?? '').toString(),
      time: DateTime.tryParse(
        (json['created_at'] ?? '').toString(),
      ) ??
          DateTime.now(),
    );
  }
}

// Chat conversation loaded from MySQL.
class Chat {
  final String id, listingId, farmerName, crop;
  final List<ChatMsg> msgs = [];

  bool blocked = false, reported = false;
  int unread = 0;

  Chat({
    required this.id,
    required this.listingId,
    required this.farmerName,
    required this.crop,
    this.blocked = false,
    this.reported = false,
    this.unread = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: (json['id'] ?? '').toString(),
      listingId: (json['listing_id'] ?? '').toString(),
      farmerName: (json['farmer_name'] ?? '').toString(),
      crop: (json['crop'] ?? '').toString(),
      blocked: json['is_blocked'].toString() == '1' ||
          json['is_blocked'] == true,
      reported: json['is_reported'].toString() == '1' ||
          json['is_reported'] == true,
      unread: int.tryParse(
        (json['unread_count'] ?? '0').toString(),
      ) ??
          0,
    );
  }

  DateTime get lastTime => msgs.isEmpty
      ? DateTime.fromMillisecondsSinceEpoch(0)
      : msgs.last.time;
}

class Agreement {
  final String id, listingId, farmerName, crop, place;
  final double quantity, pricePerUnit;
  final QtyUnit unit;
  final DateTime collectionDate;
  bool buyerConfirmed, farmerConfirmed, cancelled;

  Agreement({
    required this.id,
    required this.listingId,
    required this.farmerName,
    required this.crop,
    required this.place,
    required this.quantity,
    required this.pricePerUnit,
    required this.unit,
    required this.collectionDate,
    this.buyerConfirmed = false,
    this.farmerConfirmed = false,
    this.cancelled = false,
  });

  bool get confirmed => buyerConfirmed && farmerConfirmed && !cancelled;

  // Either side can cancel before the collection date (BY-14).
  bool get canCancel =>
      !cancelled && collectionDate.isAfter(DateTime.now());
}

class Requirement {
  final String id, crop, district, notes;
  final double quantity;
  final QtyUnit unit;
  final DateTime neededBy;

  Requirement({
    required this.id,
    required this.crop,
    required this.district,
    required this.notes,
    required this.quantity,
    required this.unit,
    required this.neededBy,
  });
}

// Notifications loaded from MySQL.
class AppNotification {
  final String id;
  final String titleEn, titleTa, bodyEn, bodyTa;
  final DateTime time;
  bool read;

  AppNotification(
      this.titleEn,
      this.titleTa,
      this.bodyEn,
      this.bodyTa, {
        this.id = '',
        DateTime? time,
        this.read = false,
      }) : time = time ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      (json['title_en'] ?? '').toString(),
      (json['title_ta'] ?? '').toString(),
      (json['body_en'] ?? '').toString(),
      (json['body_ta'] ?? '').toString(),
      id: (json['id'] ?? '').toString(),
      time: DateTime.tryParse(
        (json['created_at'] ?? '').toString(),
      ) ??
          DateTime.now(),
      read: json['is_read'].toString() == '1' ||
          json['is_read'] == true,
    );
  }
}
