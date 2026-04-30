import 'package:flutter/material.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';

Color orderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.newOrder:
      return const Color(0xFFE2E8F0);
    case OrderStatus.called:
      return const Color(0xFFDBEAFE);
    case OrderStatus.confirmed:
      return const Color(0xFFD1FAE5);
    case OrderStatus.handedToCourier:
      return const Color(0xFFFEF3C7);
    case OrderStatus.delivered:
      return const Color(0xFFDCFCE7);
    case OrderStatus.collected:
      return const Color(0xFFD1FAE5);
    case OrderStatus.returned:
      return const Color(0xFFFEE2E2);
    case OrderStatus.cancelled:
      return const Color(0xFFF1F5F9);
  }
}

Color orderStatusTextColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.newOrder:
      return const Color(0xFF475569);
    case OrderStatus.called:
      return const Color(0xFF1D4ED8);
    case OrderStatus.confirmed:
      return const Color(0xFF065F46);
    case OrderStatus.handedToCourier:
      return const Color(0xFF92400E);
    case OrderStatus.delivered:
      return const Color(0xFF166534);
    case OrderStatus.collected:
      return const Color(0xFF14532D);
    case OrderStatus.returned:
      return const Color(0xFF991B1B);
    case OrderStatus.cancelled:
      return const Color(0xFF64748B);
  }
}

String shortOrderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.newOrder:
      return 'New';
    case OrderStatus.called:
      return 'Called';
    case OrderStatus.confirmed:
      return 'Confirmed';
    case OrderStatus.handedToCourier:
      return 'Handed to Courier';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.collected:
      return 'Collected';
    case OrderStatus.returned:
      return 'Returned';
    case OrderStatus.cancelled:
      return 'Cancelled';
  }
}

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  final bool large;

  const OrderStatusChip({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: orderStatusColor(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: orderStatusTextColor(status),
          fontSize: large ? 14 : 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
