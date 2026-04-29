import 'package:sqflite/sqflite.dart';
import 'package:talabati/core/database/database_helper.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';

class DashboardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> getTotalOrdersCount() async {
    final db = await _dbHelper.database;
    return _firstInt(await db.rawQuery('SELECT COUNT(*) FROM orders'));
  }

  Future<int> getTodaysOrdersCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _countOrdersBetween('createdAt', start, end);
  }

  Future<int> getPendingConfirmationCount() async {
    final db = await _dbHelper.database;
    return _firstInt(
      await db.rawQuery('SELECT COUNT(*) FROM orders WHERE status IN (?, ?)', [
        OrderStatus.newOrder.index,
        OrderStatus.called.index,
      ]),
    );
  }

  Future<int> getWithCourierCount() async {
    return _countOrdersByStatus(OrderStatus.handedToCourier);
  }

  Future<int> getDeliveredAwaitingCollectionCount() async {
    return _countOrdersByStatus(OrderStatus.delivered);
  }

  Future<double> getMonthlyRevenue() async {
    final db = await _dbHelper.database;
    final range = _currentMonthRange();
    return _firstDouble(
      await db.rawQuery(
        '''
        SELECT COALESCE(SUM(amountCollected), 0) AS value
        FROM orders
        WHERE status = ? AND updatedAt >= ? AND updatedAt < ?
        ''',
        [
          OrderStatus.collected.index,
          range.start.toIso8601String(),
          range.end.toIso8601String(),
        ],
      ),
    );
  }

  Future<double> getMonthlyProfit() async {
    final db = await _dbHelper.database;
    final range = _currentMonthRange();
    final itemProfit = _firstDouble(
      await db.rawQuery(
        '''
        SELECT COALESCE(SUM((order_items.unitPrice - products.costPrice) * order_items.quantity), 0) AS value
        FROM order_items
        INNER JOIN orders ON orders.id = order_items.orderId
        INNER JOIN products ON products.id = order_items.productId
        WHERE orders.status = ? AND orders.updatedAt >= ? AND orders.updatedAt < ?
        ''',
        [
          OrderStatus.collected.index,
          range.start.toIso8601String(),
          range.end.toIso8601String(),
        ],
      ),
    );

    final deliveryFees = _firstDouble(
      await db.rawQuery(
        '''
        SELECT COALESCE(SUM(deliveryFee), 0) AS value
        FROM orders
        WHERE status = ? AND updatedAt >= ? AND updatedAt < ?
        ''',
        [
          OrderStatus.collected.index,
          range.start.toIso8601String(),
          range.end.toIso8601String(),
        ],
      ),
    );

    return itemProfit - deliveryFees;
  }

  Future<double> getPendingRevenue() async {
    final db = await _dbHelper.database;
    return _firstDouble(
      await db.rawQuery(
        '''
        SELECT COALESCE(SUM(totalAmount), 0) AS value
        FROM orders
        WHERE status IN (?, ?, ?)
        ''',
        [
          OrderStatus.confirmed.index,
          OrderStatus.handedToCourier.index,
          OrderStatus.delivered.index,
        ],
      ),
    );
  }

  Future<int> getReturnsThisMonthCount() async {
    final range = _currentMonthRange();
    return _countOrdersBetween(
      'updatedAt',
      range.start,
      range.end,
      status: OrderStatus.returned,
    );
  }

  Future<List<TopReturningClientStat>> getTopReturningClients() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'clients',
      columns: ['name', 'returnCount'],
      where: 'returnCount > 0',
      orderBy: 'returnCount DESC, name ASC',
      limit: 3,
    );

    return rows.map((row) {
      return TopReturningClientStat(
        name: row['name'] as String,
        returnCount: row['returnCount'] as int,
      );
    }).toList();
  }

  Future<List<RecentOrderStat>> getRecentOrders() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT
        orders.id AS orderId,
        orders.wilaya AS wilaya,
        orders.totalAmount AS totalAmount,
        orders.status AS status,
        orders.createdAt AS createdAt,
        clients.name AS clientName
      FROM orders
      LEFT JOIN clients ON clients.id = orders.clientId
      ORDER BY orders.createdAt DESC
      LIMIT 5
      ''');

    return rows.map((row) {
      return RecentOrderStat(
        orderId: row['orderId'] as String,
        clientName: row['clientName'] as String? ?? 'Deleted client',
        wilaya: row['wilaya'] as String,
        totalAmount: (row['totalAmount'] as num).toDouble(),
        status: OrderStatus.values[row['status'] as int],
        createdAt: DateTime.parse(row['createdAt'] as String),
      );
    }).toList();
  }

  Future<int> _countOrdersByStatus(OrderStatus status) async {
    final db = await _dbHelper.database;
    return _firstInt(
      await db.rawQuery('SELECT COUNT(*) FROM orders WHERE status = ?', [
        status.index,
      ]),
    );
  }

  Future<int> _countOrdersBetween(
    String column,
    DateTime start,
    DateTime end, {
    OrderStatus? status,
  }) async {
    final db = await _dbHelper.database;
    final statusSql = status == null ? '' : ' AND status = ?';
    final args = <Object?>[
      start.toIso8601String(),
      end.toIso8601String(),
      if (status != null) status.index,
    ];
    return _firstInt(
      await db.rawQuery(
        'SELECT COUNT(*) FROM orders WHERE $column >= ? AND $column < ?$statusSql',
        args,
      ),
    );
  }

  _DateRange _currentMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month + 1);
    return _DateRange(start, end);
  }

  int _firstInt(List<Map<String, Object?>> rows) {
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  double _firstDouble(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) return 0;
    final value = rows.first['value'];
    return value is num ? value.toDouble() : 0;
  }
}

class TopReturningClientStat {
  final String name;
  final int returnCount;

  const TopReturningClientStat({required this.name, required this.returnCount});
}

class RecentOrderStat {
  final String orderId;
  final String clientName;
  final String wilaya;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;

  const RecentOrderStat({
    required this.orderId,
    required this.clientName,
    required this.wilaya,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange(this.start, this.end);
}
