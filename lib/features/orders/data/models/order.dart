import 'package:uuid/uuid.dart';
import 'order_status.dart';
import 'delivery_company.dart';
import 'order_item.dart';

class Order {
  final String id;
  final String clientId;
  final List<OrderItem> items;
  final OrderStatus status;
  final bool isConfirmedByPhone;
  final String wilaya;
  final DeliveryCompany deliveryCompany;
  final double deliveryFee;
  final String? trackingNumber;
  final double totalAmount;
  final double? amountCollected;
  final String? notes;
  final String? returnReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    String? id,
    required this.clientId,
    this.items = const [],
    this.status = OrderStatus.newOrder,
    this.isConfirmedByPhone = false,
    required this.wilaya,
    required this.deliveryCompany,
    required this.deliveryFee,
    this.trackingNumber,
    required this.totalAmount,
    this.amountCollected,
    this.notes,
    this.returnReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'status': status.index,
      'isConfirmedByPhone': isConfirmedByPhone ? 1 : 0,
      'wilaya': wilaya,
      'deliveryCompany': deliveryCompany.index,
      'deliveryFee': deliveryFee,
      'trackingNumber': trackingNumber,
      'totalAmount': totalAmount,
      'amountCollected': amountCollected,
      'notes': notes,
      'returnReason': returnReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, List<OrderItem> items) {
    return Order(
      id: map['id'],
      clientId: map['clientId'],
      items: items,
      status: OrderStatus.values[map['status']],
      isConfirmedByPhone: map['isConfirmedByPhone'] == 1,
      wilaya: map['wilaya'],
      deliveryCompany: DeliveryCompany.values[map['deliveryCompany']],
      deliveryFee: (map['deliveryFee'] as num).toDouble(),
      trackingNumber: map['trackingNumber'],
      totalAmount: (map['totalAmount'] as num).toDouble(),
      amountCollected: (map['amountCollected'] as num?)?.toDouble(),
      notes: map['notes'],
      returnReason: map['returnReason'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
