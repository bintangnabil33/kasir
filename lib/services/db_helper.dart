import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cart.dart';

class DBHelper {
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'cart_kasir.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS cart('
      'id INTEGER PRIMARY KEY, '
      'id_barang VARCHAR, '
      'nama_barang TEXT, '
      'harga DOUBLE, '
      'quantity INTEGER, '
      'image TEXT'
      ')',
    );
  }

  // ===== INSERT =====
  Future<Cart> insert(Cart cart) async {
    var dbClient = await database;
    await dbClient!.insert(
      'cart',
      cart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return cart;
  }

  // ===== GET ALL =====
  Future<List<Cart>> getCartList() async {
    try {
      var dbClient = await database;
      final List<Map<String, Object?>> result = await dbClient!.query('cart');
      return result.map((e) => Cart.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ===== GET BY ID =====
  Future<List<Cart>> getCartDetail(int id) async {
    try {
      var dbClient = await database;
      final result = await dbClient!.query(
        'cart',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.map((e) => Cart.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ===== UPDATE QTY =====
  Future<int> updateQuantity(int id, int qty) async {
    var dbClient = await database;
    return await dbClient!.update(
      'cart',
      {'quantity': qty},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== DELETE ITEM =====
  Future<int> deleteCartItem(int id) async {
    var dbClient = await database;
    return await dbClient!.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  // ===== CLEAR ALL =====
  Future<int> clearCart() async {
    var dbClient = await database;
    return await dbClient!.delete('cart');
  }
}