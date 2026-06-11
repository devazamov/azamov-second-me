/// ═══════════════════════════════════════════════════════════════
/// Subscription Model - AZAMOV Second Me
/// Premium subscription management
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus { active, expired, cancelled, trial }

class Subscription {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? cancelledAt;
  final double price;
  final String currency;
  final bool autoRenew;

  const Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.cancelledAt,
    required this.price,
    required this.currency,
    this.autoRenew = true,
  });

  /// Whether subscription is currently valid
  bool get isActive => status == SubscriptionStatus.active &&
      endDate.isAfter(DateTime.now());

  /// Days remaining in subscription
  int get daysRemaining {
    if (!isActive) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Monthly price in UZS
  static const double monthlyPriceUZS = 49000;

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Subscription(
      id: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'] ?? '',
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
      startDate:
          (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'UZS',
      autoRenew: data['autoRenew'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'status': status.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'price': price,
      'currency': currency,
      'autoRenew': autoRenew,
    };
  }
}
