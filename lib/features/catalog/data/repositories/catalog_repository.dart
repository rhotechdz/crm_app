import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:talabati/core/database/database_helper.dart';
import 'package:talabati/features/catalog/data/models/product.dart';
import 'package:talabati/features/catalog/data/models/product_variant.dart';

class CatalogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Product>> getProducts() async {
    final db = await _dbHelper.database;
    final productsJson = await db.query('products', orderBy: 'name ASC');

    List<Product> products = [];
    for (var productMap in productsJson) {
      final variantsJson = await db.query(
        'product_variants',
        where: 'productId = ?',
        whereArgs: [productMap['id']],
      );
      final variants = variantsJson.map((v) => ProductVariant.fromMap(v)).toList();
      products.add(Product.fromMap(productMap, variants));
    }
    return products;
  }

  Future<void> addProduct(Product product) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('products', product.toMap());
      for (var variant in product.variants) {
        await txn.insert('product_variants', variant.toMap(product.id));
      }
    });
  }

  Future<void> updateProduct(Product product, List<String> variantsToDelete) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );

      // Handle variants
      for (var variant in product.variants) {
        await txn.insert(
          'product_variants',
          variant.toMap(product.id),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Handle deletions
      for (var variantId in variantsToDelete) {
        final count = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM order_items WHERE productId = ? AND variantLabel = ?',
          [product.id, (await _getVariantLabel(txn, variantId))]
        )) ?? 0;

        if (count == 0) {
          await txn.delete(
            'product_variants',
            where: 'id = ?',
            whereArgs: [variantId],
          );
        }
      }
    });
  }

  Future<String?> _getVariantLabel(DatabaseExecutor txn, String variantId) async {
    final result = await txn.query(
      'product_variants',
      columns: ['label'],
      where: 'id = ?',
      whereArgs: [variantId],
    );
    if (result.isNotEmpty) {
      return result.first['label'] as String?;
    }
    return null;
  }

  Future<bool> isProductInOrders(String productId) async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM order_items WHERE productId = ?',
      [productId],
    )) ?? 0;
    return count > 0;
  }

  Future<void> deleteProduct(String productId) async {
    final db = await _dbHelper.database;
    
    // Get product to check for image deletion
    final products = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    String? imageUrl;
    if (products.isNotEmpty) {
      imageUrl = products.first['imageUrl'] as String?;
    }

    await db.transaction((txn) async {
      await txn.delete(
        'product_variants',
        where: 'productId = ?',
        whereArgs: [productId],
      );
      await txn.delete(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );
    });

    // Delete local image file if it exists
    if (imageUrl != null) {
      final file = File(imageUrl);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
