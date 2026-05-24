import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/db_helper.dart';

class CartProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Cart> cart = [];

  // ===== LOAD DATA DARI SQLITE =====
  Future<List<Cart>> getData() async {
    cart = await _dbHelper.getCartList();
    notifyListeners();
    return cart;
  }

  // ===== JUMLAH ITEM DI CART =====
  int get jumlahItem => cart.length;

  // ===== TOTAL HARGA =====
  double get totalHarga {
    return cart.fold(0, (sum, item) => sum + (item.harga ?? 0) * (item.quantity ?? 1));
  }

  // ===== TAMBAH QTY =====
  void addQuantity(int id) async {
    final index = cart.indexWhere((e) => e.id == id);
    if (index == -1) return;
    cart[index].quantity = (cart[index].quantity ?? 1) + 1;
    await _dbHelper.updateQuantity(cart[index].id!, cart[index].quantity!);
    notifyListeners();
  }

  // ===== KURANG QTY =====
  void deleteQuantity(int id) async {
    final index = cart.indexWhere((e) => e.id == id);
    if (index == -1) return;
    if ((cart[index].quantity ?? 1) <= 1) return; // minimal 1
    cart[index].quantity = cart[index].quantity! - 1;
    await _dbHelper.updateQuantity(cart[index].id!, cart[index].quantity!);
    notifyListeners();
  }

  // ===== HAPUS ITEM =====
  void removeItem(int id) async {
    await _dbHelper.deleteCartItem(id);
    cart.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ===== KOSONGKAN CART =====
  void clearAll() async {
    await _dbHelper.clearCart();
    cart.clear();
    notifyListeners();
  }
}