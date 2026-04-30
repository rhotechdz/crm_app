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
  final String? lastWilaya;

  const OrdersState({
    this.orders = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.lastDeliveryCompany,
    this.lastWilaya,
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
    String? lastWilaya,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: identical(statusFilter, _unset)
          ? this.statusFilter
          : statusFilter as OrderStatus?,
      lastDeliveryCompany: lastDeliveryCompany ?? this.lastDeliveryCompany,
      lastWilaya: lastWilaya ?? this.lastWilaya,
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
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Delivery Company
    final companyName = prefs.getString('last_delivery_company');
    if (companyName != null) {
      try {
        final company = DeliveryCompany.values.byName(companyName);
        state = state.copyWith(lastDeliveryCompany: company);
      } catch (_) {}
    }

    // Load Wilaya
    final wilaya = prefs.getString('last_wilaya');
    if (wilaya != null) {
      state = state.copyWith(lastWilaya: wilaya);
    }
  }

  Future<void> _savePreferences(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_delivery_company', order.deliveryCompany.name);
    await prefs.setString('last_wilaya', order.wilaya);
    
    state = state.copyWith(
      lastDeliveryCompany: order.deliveryCompany,
      lastWilaya: order.wilaya,
    );
  }

  Future<void> loadOrders() async {
    final orders = await _repository.getOrders();
    state = state.copyWith(orders: orders);
  }

  Future<void> addOrder(Order order) async {
    await _repository.addOrder(order);
    await _savePreferences(order);
    await loadOrders();
  }

  Future<void> updateOrder(Order order) async {
    await _repository.updateOrder(order);
    await _savePreferences(order);
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
