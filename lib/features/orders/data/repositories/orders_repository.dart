import 'package:sqflite/sqflite.dart';
import 'package:talabati/core/database/database_helper.dart';
import 'package:talabati/features/orders/data/models/order.dart';
import 'package:talabati/features/orders/data/models/order_item.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';
import 'package:talabati/features/orders/data/models/order_with_client.dart';

class OrdersRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<OrderWithClient>> getOrders() async {
    final db = await _dbHelper.database;
    final ordersJson = await db.query('orders', orderBy: 'createdAt DESC');

    final orders = <OrderWithClient>[];
    for (final orderMap in ordersJson) {
      final items = await _getItems(db, orderMap['id'] as String);
      final client = await _getClientSnapshot(
        db,
        orderMap['clientId'] as String,
      );

      orders.add(
        OrderWithClient(
          order: Order.fromMap(orderMap, items),
          clientName: client.name,
          clientPhone: client.phone,
          clientWilaya: client.wilaya,
        ),
      );
    }

    return orders;
  }

  Future<void> addOrder(Order order) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('orders', order.toMap());
      await _insertItems(txn, order);
    });
  }

  Future<void> updateOrder(Order order) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'orders',
        order.toMap(),
        where: 'id = ?',
        whereArgs: [order.id],
      );
      await txn.delete(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [order.id],
      );
      await _insertItems(txn, order);
    });
  }

  Future<void> deleteOrder(String id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('order_items', where: 'orderId = ?', whereArgs: [id]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> updateOrderStatus(
    String id,
    OrderStatus status, {
    String? returnReason,
    double? amountCollected,
  }) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'orders',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (existing.isEmpty) return;

      final currentOrder = existing.first;
      final currentStatus = OrderStatus.values[currentOrder['status'] as int];
      final values = <String, Object?>{
        'status': status.index,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (status.index >= OrderStatus.confirmed.index &&
          status != OrderStatus.returned &&
          status != OrderStatus.cancelled) {
        values['isConfirmedByPhone'] = 1;
      }

      if (status == OrderStatus.returned) {
        values['returnReason'] = returnReason;
        if (currentStatus != OrderStatus.returned) {
          await txn.rawUpdate(
            'UPDATE clients SET returnCount = returnCount + 1 WHERE id = ?',
            [currentOrder['clientId']],
          );
        }
      }

      if (status == OrderStatus.collected) {
        values['amountCollected'] = amountCollected;
      }

      await txn.update('orders', values, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<OrderItem>> _getItems(DatabaseExecutor db, String orderId) async {
    final itemsJson = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    return itemsJson.map((item) => OrderItem.fromMap(item)).toList();
  }

  Future<_ClientSnapshot> _getClientSnapshot(
    DatabaseExecutor db,
    String clientId,
  ) async {
    final clients = await db.query(
      'clients',
      columns: ['name', 'phone', 'wilaya'],
      where: 'id = ?',
      whereArgs: [clientId],
      limit: 1,
    );

    if (clients.isEmpty) {
      return const _ClientSnapshot(
        name: 'Deleted client',
        phone: '',
        wilaya: 'Unknown wilaya',
      );
    }

    final client = clients.first;
    return _ClientSnapshot(
      name: client['name'] as String,
      phone: client['phone'] as String,
      wilaya: client['wilaya'] as String,
    );
  }

  Future<void> _insertItems(DatabaseExecutor txn, Order order) async {
    for (final item in order.items) {
      await txn.insert('order_items', item.toMap(order.id));
    }
  }
}

class _ClientSnapshot {
  final String name;
  final String phone;
  final String wilaya;

  const _ClientSnapshot({
    required this.name,
    required this.phone,
    required this.wilaya,
  });
}
