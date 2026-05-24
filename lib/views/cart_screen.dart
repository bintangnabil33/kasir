import 'package:flutter/material.dart';
import 'package:kasir/controllers/cart_provider.dart';
import 'package:kasir/services/transaksi_service.dart';
import 'package:kasir/widgets/alert.dart';
import 'package:kasir/widgets/tombol_plus_minus.dart';
import 'package:kasir/services/url.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartProvider _cartProvider = CartProvider();
  bool isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _cartProvider.getData();
  }

  String rupiah(double value) {
    return "Rp ${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}."
    )}";
  }

  String buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    final clean = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    final encoded = clean.split('/').map(Uri.encodeComponent).join('/');
    return '$BaseUrlTanpaAPI/$encoded';
  }

  // ===== CHECKOUT =====
  Future<void> _checkout() async {
    if (_cartProvider.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keranjang masih kosong")),
      );
      return;
    }

    setState(() => isCheckingOut = true);

    // Format data untuk API: [{ "barang_id": x, "qty": y }]
    List<Map<String, dynamic>> items = _cartProvider.cart.map((item) {
      return {
        "barang_id": int.parse(item.idBarang ?? "0"),
        "qty": item.quantity,
      };
    }).toList();

    var result = await TransaksiService().checkout(items);

    if (!mounted) return;
    setState(() => isCheckingOut = false);

    if (result.status == true) {
      // Kosongkan cart setelah checkout berhasil
      _cartProvider.clearAll();

      await AlertMessage().showAlert(context, "Transaksi berhasil!", true);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/history',
        (route) => false,
      );
    } else {
      AlertMessage().showAlert(
        context,
        result.message ?? "Transaksi gagal",
        false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Keranjang",
          style: TextStyle(
            color: Color(0xFFE50914),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Badge jumlah item
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ListenableBuilder(
              listenable: _cartProvider,
              builder: (context, _) => Stack(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.black),
                  if (_cartProvider.jumlahItem > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE50914),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_cartProvider.jumlahItem}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _cartProvider,
        builder: (context, _) {
          if (_cartProvider.cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Keranjang kosong",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ===== LIST ITEM CART =====
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    final item = _cartProvider.cart[index];
                    final imageUrl = buildImageUrl(item.image);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Row(
                        children: [
                          // Gambar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl.isNotEmpty
                                ? Image.network(imageUrl,
                                    width: 70, height: 70, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 70, height: 70,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image,
                                          color: Colors.grey),
                                    ))
                                : Container(
                                    width: 70, height: 70,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image,
                                        color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 12),

                          // Info & kontrol
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaBarang ?? "-",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rupiah(item.harga ?? 0),
                                  style: const TextStyle(
                                    color: Color(0xFFE50914),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Tombol +/-
                                    TombolPlusMinus(
                                      jumlah: item.quantity.toString(),
                                      onTambah: () =>
                                          _cartProvider.addQuantity(item.id!),
                                      onKurang: () =>
                                          _cartProvider.deleteQuantity(item.id!),
                                    ),

                                    // Subtotal
                                    Text(
                                      rupiah(
                                          (item.harga ?? 0) * (item.quantity ?? 1)),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    // Hapus
                                    InkWell(
                                      onTap: () =>
                                          _cartProvider.removeItem(item.id!),
                                      child: const Icon(Icons.delete,
                                          color: Colors.red, size: 22),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ===== TOTAL & CHECKOUT =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Belanja",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        ListenableBuilder(
                          listenable: _cartProvider,
                          builder: (context, _) => Text(
                            rupiah(_cartProvider.totalHarga),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE50914),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isCheckingOut ? null : _checkout,
                        icon: isCheckingOut
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.shopping_cart_checkout_rounded),
                        label: Text(
                            isCheckingOut ? "Memproses..." : "Checkout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}