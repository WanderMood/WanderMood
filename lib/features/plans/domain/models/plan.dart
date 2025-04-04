import 'place.dart';

enum PlanStatus {
  draft,
  confirmed,
  completed,
  cancelled
}

enum PaymentStatus {
  pending,
  partiallyPaid,
  paid,
  refunded
}

class Plan {
  final String id;
  final String userId;
  final String mood;
  final List<PlaceBooking> bookings;
  final String description;
  final DateTime createdAt;
  final PlanStatus status;
  final PaymentStatus paymentStatus;
  final double totalCost;

  Plan({
    required this.id,
    required this.userId,
    required this.mood,
    required this.bookings,
    required this.description,
    required this.createdAt,
    this.status = PlanStatus.draft,
    this.paymentStatus = PaymentStatus.pending,
    this.totalCost = 0.0,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      userId: json['user_id'],
      mood: json['mood'],
      bookings: (json['bookings'] as List)
          .map((b) => PlaceBooking.fromJson(b))
          .toList(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      status: PlanStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => PlanStatus.draft,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (s) => s.toString() == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood,
      'bookings': bookings.map((b) => b.toJson()).toList(),
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status.toString(),
      'payment_status': paymentStatus.toString(),
      'total_cost': totalCost,
    };
  }

  Plan copyWith({
    String? id,
    String? userId,
    String? mood,
    List<PlaceBooking>? bookings,
    String? description,
    DateTime? createdAt,
    PlanStatus? status,
    PaymentStatus? paymentStatus,
    double? totalCost,
  }) {
    return Plan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      bookings: bookings ?? this.bookings,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalCost: totalCost ?? this.totalCost,
    );
  }
}

class PlaceBooking {
  final Place place;
  final DateTime scheduledTime;
  final int partySize;
  final List<String> specialRequests;
  final double cost;
  final bool isConfirmed;

  PlaceBooking({
    required this.place,
    required this.scheduledTime,
    required this.partySize,
    this.specialRequests = const [],
    this.cost = 0.0,
    this.isConfirmed = false,
  });

  factory PlaceBooking.fromJson(Map<String, dynamic> json) {
    return PlaceBooking(
      place: Place.fromJson(json['place']),
      scheduledTime: DateTime.parse(json['scheduled_time']),
      partySize: json['party_size'],
      specialRequests: List<String>.from(json['special_requests'] ?? []),
      cost: (json['cost'] ?? 0.0).toDouble(),
      isConfirmed: json['is_confirmed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place': place.toJson(),
      'scheduled_time': scheduledTime.toIso8601String(),
      'party_size': partySize,
      'special_requests': specialRequests,
      'cost': cost,
      'is_confirmed': isConfirmed,
    };
  }

  PlaceBooking copyWith({
    Place? place,
    DateTime? scheduledTime,
    int? partySize,
    List<String>? specialRequests,
    double? cost,
    bool? isConfirmed,
  }) {
    return PlaceBooking(
      place: place ?? this.place,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      partySize: partySize ?? this.partySize,
      specialRequests: specialRequests ?? this.specialRequests,
      cost: cost ?? this.cost,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
} 