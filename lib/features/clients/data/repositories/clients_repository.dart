import 'package:talabati/core/database/database_helper.dart';
import 'package:talabati/features/clients/data/models/client.dart';
import 'package:talabati/features/orders/data/models/order.dart';
import 'package:talabati/features/orders/data/models/order_item.dart';

class ClientsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Client>> getClients() async {
    final db = await _dbHelper.database;
    final result = await db.query('clients', orderBy: 'name ASC');
    return result.map((json) => Client.fromMap(json)).toList();
  }

  Future<void> addClient(Client client) async {
    final db = await _dbHelper.database;
    await db.insert('clients', client.toMap());
  }

  Future<void> updateClient(Client client) async {
    final db = await _dbHelper.database;
    await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<void> deleteClient(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Client?> getClientByPhone(String phone) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'clients',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Client.fromMap(result.first);
  }

  Future<List<Order>> getClientOrders(String clientId) async {
    final db = await _dbHelper.database;
    final ordersJson = await db.query(
      'orders',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'createdAt DESC',
    );

    List<Order> orders = [];
    for (var orderMap in ordersJson) {
      final itemsJson = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderMap['id']],
      );
      final items = itemsJson.map((item) => OrderItem.fromMap(item)).toList();
      orders.add(Order.fromMap(orderMap, items));
    }
    return orders;
  }
}
