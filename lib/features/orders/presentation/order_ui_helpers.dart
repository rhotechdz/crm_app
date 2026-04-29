import 'package:flutter/material.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';

Color orderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.newOrder:
      return Colors.grey;
    case OrderStatus.called:
      return Colors.blue;
    case OrderStatus.confirmed:
      return Colors.teal;
    case OrderStatus.handedToCourier:
      return Colors.orange;
    case OrderStatus.delivered:
      return Colors.lightGreen;
    case OrderStatus.collected:
      return Colors.green.shade800;
    case OrderStatus.returned:
      return Colors.red;
    case OrderStatus.cancelled:
      return Colors.grey.shade800;
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
    return Chip(
      backgroundColor: orderStatusColor(status),
      label: Text(
        status.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: large ? 15 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 4,
        vertical: large ? 8 : 0,
      ),
    );
  }
}
