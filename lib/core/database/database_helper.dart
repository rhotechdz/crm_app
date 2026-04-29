import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('talabati.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
    if (oldVersion < 4) {
      await _migrateToV4(db);
    }
  }

  Future _migrateToV2(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE clients_new (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT NOT NULL UNIQUE,
          instagramHandle TEXT,
          wilaya TEXT NOT NULL,
          notes TEXT,
          returnCount INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
      await txn.execute('''
        INSERT INTO clients_new (id, name, phone, instagramHandle, wilaya, notes, returnCount, createdAt)
        SELECT id, name, phone, instagramHandle, wilaya, notes, returnCount, createdAt
        FROM clients
      ''');
      await txn.execute('DROP TABLE clients');
      await txn.execute('ALTER TABLE clients_new RENAME TO clients');
    });
  }

  Future _migrateToV3(Database db) async {
    // Migration for version 3: Make stockQuantity nullable in products and product_variants
    await db.transaction((txn) async {
      // 1. Fix products table
      await txn.execute(
        'CREATE TABLE products_new (id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT, sellingPrice REAL NOT NULL, costPrice REAL NOT NULL, stockQuantity INTEGER, imageUrl TEXT, createdAt TEXT NOT NULL)',
      );
      await txn.execute('INSERT INTO products_new SELECT * FROM products');
      await txn.execute('DROP TABLE products');
      await txn.execute('ALTER TABLE products_new RENAME TO products');

      // 2. Fix product_variants table
      await txn.execute(
        'CREATE TABLE product_variants_new (id TEXT PRIMARY KEY, productId TEXT, label TEXT NOT NULL, additionalPrice REAL NOT NULL, stockQuantity INTEGER, FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE)',
      );
      await txn.execute(
        'INSERT INTO product_variants_new SELECT * FROM product_variants',
      );
      await txn.execute('DROP TABLE product_variants');
      await txn.execute(
        'ALTER TABLE product_variants_new RENAME TO product_variants',
      );
    });
  }

  Future _migrateToV4(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE orders_new (
          id TEXT PRIMARY KEY,
          clientId TEXT NOT NULL,
          status INTEGER NOT NULL,
          isConfirmedByPhone INTEGER NOT NULL,
          wilaya TEXT NOT NULL,
          deliveryCompany INTEGER NOT NULL,
          deliveryFee REAL NOT NULL,
          trackingNumber TEXT,
          totalAmount REAL NOT NULL,
          amountCollected REAL,
          notes TEXT,
          returnReason TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (clientId) REFERENCES clients (id)
        )
      ''');
      await txn.execute('''
        INSERT INTO orders_new (
          id, clientId, status, isConfirmedByPhone, wilaya, deliveryCompany,
          deliveryFee, trackingNumber, totalAmount, amountCollected, notes,
          returnReason, createdAt, updatedAt
        )
        SELECT
          id, clientId, status, isConfirmedByPhone, wilaya, deliveryCompany,
          deliveryFee, trackingNumber, totalAmount, amountCollected, notes,
          returnReason, createdAt, updatedAt
        FROM orders
      ''');
      await txn.execute('DROP TABLE orders');
      await txn.execute('ALTER TABLE orders_new RENAME TO orders');
    });
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textUniqueType = 'TEXT NOT NULL UNIQUE';
    const textNullableType = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const intNullableType = 'INTEGER';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE clients (
  id $idType,
  name $textType,
  phone $textUniqueType,
  instagramHandle $textNullableType,
  wilaya $textType,
  notes $textNullableType,
  returnCount $intType,
  createdAt $textType
)
''');

    await db.execute('''
CREATE TABLE products (
  id $idType,
  name $textType,
  description $textNullableType,
  sellingPrice $doubleType,
  costPrice $doubleType,
  stockQuantity $intNullableType,
  imageUrl $textNullableType,
  createdAt $textType
)
''');

    await db.execute('''
CREATE TABLE product_variants (
  id $idType,
  productId $textType,
  label $textType,
  additionalPrice $doubleType,
  stockQuantity $intNullableType,
  FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE orders (
  id $idType,
  clientId $textType,
  status $intType,
  isConfirmedByPhone $intType,
  wilaya $textType,
  deliveryCompany $intType,
  deliveryFee $doubleType,
  trackingNumber $textNullableType,
  totalAmount $doubleType,
  amountCollected REAL,
  notes $textNullableType,
  returnReason $textNullableType,
  createdAt $textType,
  updatedAt $textType,
  FOREIGN KEY (clientId) REFERENCES clients (id)
)
''');

    await db.execute('''
CREATE TABLE order_items (
  orderId $textType,
  productId $textType,
  productName $textType,
  variantLabel $textNullableType,
  quantity $intType,
  unitPrice $doubleType,
  FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
