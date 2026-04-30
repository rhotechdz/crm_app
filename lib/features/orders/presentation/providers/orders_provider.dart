import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talabati/features/orders/data/models/delivery_company.dart';
import 'package:talabati/features/orders/data/models/order.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';
import 'package:talabati/features/orders/data/models/order_with_client.dart';
import 'package:talabati/features/orders/data/repositories/orders_repository.dart';

final ordersRepositoryProvider = Provider((ref) => OrdersRepository());

final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(
  OrdersNotifier.new,
);

class OrdersState {
  final List<OrderWithClient> orders;
  final String searchQuery;
  final OrderStatus? statusFilter;
  final DeliveryCompany? lastDeliveryCompany;

  const OrdersState({
    this.orders = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.lastDeliveryCompany,
  });

  List<OrderWithClient> get filteredOrders {
    final query = searchQuery.toLowerCase().trim();
    return orders.where((entry) {
      final matchesStatus =
          statusFilter == null || entry.order.status == statusFilter;
      final matchesSearch =
          query.isEmpty ||
          entry.clientName.toLowerCase().contains(query) ||
          (entry.order.trackingNumber ?? '').toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  OrdersState copyWith({
    List<OrderWithClient>? orders,
    String? searchQuery,
    Object? statusFilter = _unset,
    DeliveryCompany? lastDeliveryCompany,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: identical(statusFilter, _unset)
          ? this.statusFilter
          : statusFilter as OrderStatus?,
      lastDeliveryCompany: lastDeliveryCompany ?? this.lastDeliveryCompany,
    );
  }
}

const Object _unset = Object();

class OrdersNotifier extends Notifier<OrdersState> {
  OrdersRepository get _repository => ref.read(ordersRepositoryProvider);

  @override
  OrdersState build() {
    _init();
    return const OrdersState();
  }

  Future<void> _init() async {
    await loadOrders();
    await _loadLastDeliveryCompany();
  }

  Future<void> _loadLastDeliveryCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('last_delivery_company');
    if (name != null) {
      try {
        final company = DeliveryCompany.values.byName(name);
        state = state.copyWith(lastDeliveryCompany: company);
      } catch (_) {
        // Handle case where enum name might have changed
      }
    }
  }

  Future<void> _saveLastDeliveryCompany(DeliveryCompany company) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_delivery_company', company.name);
    state = state.copyWith(lastDeliveryCompany: company);
  }

  Future<void> loadOrders() async {
    final orders = await _repository.getOrders();
    state = state.copyWith(orders: orders);
  }

  Future<void> addOrder(Order order) async {
    await _repository.addOrder(order);
    await _saveLastDeliveryCompany(order.deliveryCompany);
    await loadOrders();
  }

  Future<void> updateOrder(Order order) async {
    await _repository.updateOrder(order);
    await _saveLastDeliveryCompany(order.deliveryCompany);
    await loadOrders();
  }

  Future<void> deleteOrder(String id) async {
    await _repository.deleteOrder(id);
    await loadOrders();
  }

  Future<void> updateOrderStatus(
    String id,
    OrderStatus status, {
    String? returnReason,
    double? amountCollected,
  }) async {
    await _repository.updateOrderStatus(
      id,
      status,
      returnReason: returnReason,
      amountCollected: amountCollected,
    );
    await loadOrders();
  }

  void searchOrders(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void filterByStatus(OrderStatus? status) {
    state = state.copyWith(statusFilter: status);
  }
}
