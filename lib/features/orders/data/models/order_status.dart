enum OrderStatus {
  newOrder,       // New Order
  called,         // Called
  confirmed,      // Confirmed
  handedToCourier,// Handed to Courier
  delivered,      // Delivered
  collected,      // Collected
  returned,       // Returned
  cancelled,      // Cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return "New Order";
      case OrderStatus.called:
        return "Called";
      case OrderStatus.confirmed:
        return "Confirmed";
      case OrderStatus.handedToCourier:
        return "Handed to Courier";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.collected:
        return "Collected";
      case OrderStatus.returned:
        return "Returned";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }
}
