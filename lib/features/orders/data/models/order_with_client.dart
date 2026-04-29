import 'order.dart';

class OrderWithClient {
  final Order order;
  final String clientName;
  final String clientPhone;
  final String clientWilaya;

  const OrderWithClient({
    required this.order,
    required this.clientName,
    required this.clientPhone,
    required this.clientWilaya,
  });
}
