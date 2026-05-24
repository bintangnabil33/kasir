import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasir/controllers/cart_provider.dart';
import 'package:kasir/models/cart.dart';
import 'package:kasir/models/produk_model.dart';
import 'package:kasir/models/user_login.dart';
import 'package:kasir/services/db_helper.dart';
import 'package:kasir/services/url.dart';
import 'package:kasir/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransaksiView extends StatefulWidget {
  const TransaksiView({super.key});

  @override
  State<TransaksiView> createState() => _TransaksiViewState();
}

class _TransaksiViewState extends State<TransaksiView> {
  final DBHelper _dbHelper = DBHelper();
  final CartProvider _cartProvider = CartProvider();
  final UserLogin _userLogin = UserLogin();

  List<ProdukModel> produk = [];
  bool isLoading = true;
  String? errorMsg;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { isLoading = true; errorMsg = null; });

    var user = await _userLogin.getUserLogin();
    role = user.role;

    print("TOKEN : ${user.token}");
    print("ROLE  : ${user.role}");

    if (user.status == false || user.token == null || user.token!.isEmpty) {
      setState(() { isLoading = false; errorMsg = "Sesi login habis. Silakan login ulang."; });
      return;
    }

    await _cartProvider.getData();

    // Admin pakai /admin/getbarang
    // kasir & user pakai /user/getbarang
    String endpoint = user.role == "admin"
        ? "$BaseUrl/admin/getbarang"
        : "$BaseUrl/user/getbarang";

    print("ENDPOINT: $endpoint");

    try {
      var response = await http.get(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer ${user.token}",
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 15));

      print("STATUS: ${response.statusCode}");
      print("BODY  : ${response.body.substring(0, response.body.length.clamp(0, 200))}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["status"] == true) {
          List<ProdukModel> list = (jsonData["data"] as List)
              .map((e) => ProdukModel.fromJson(e))
              .toList();
          if (!mounted) return;
          setState(() { produk = list; isLoading = false; });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMsg = "Gagal memuat produk (${response.statusCode}).\nRole '${user.role}' tidak memiliki akses.\nCoba daftar akun dengan role 'user'.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { isLoading = false; errorMsg = "Error: $e"; });
    }
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

  Future<void> _tambahKeCart(ProdukModel item) async {
    List<Cart> detail = await _dbHelper.getCartDetail(item.id);
    int qty = detail.isNotEmpty ? (detail[0].quantity ?? 0) : 0;

    await _dbHelper.insert(Cart(
      id:         item.id,
      idBarang:   item.id.toString(),
      namaBarang: item.namaBarang,
      harga:      item.harga,
      quantity:   qty + 1,
      image:      item.image,
    ));

    await _cartProvider.getData();
    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.namaBarang} ditambahkan ke keranjang"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  int get _tabIndex => role == "admin" ? 2 : 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Pesan",
            style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/cart');
                  await _cartProvider.getData();
                  if (mounted) setState(() {});
                },
              ),
              ListenableBuilder(
                listenable: _cartProvider,
                builder: (context, _) {
                  if (_cartProvider.jumlahItem == 0) return const SizedBox();
                  return Positioned(
                    right: 6, top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Color(0xFFE50914), shape: BoxShape.circle),
                      child: Text('${_cartProvider.jumlahItem}',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))

          : errorMsg != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(errorMsg!, textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Coba Lagi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout & Login Ulang"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFE50914),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: produk.length,
                itemBuilder: (context, index) {
                  final item = produk[index];
                  final imageUrl = buildImageUrl(item.image);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl,
                                  width: 90, height: 90, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 90, height: 90,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, color: Colors.grey)))
                              : Container(width: 90, height: 90,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.namaBarang, maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(rupiah(item.harga),
                                    style: const TextStyle(
                                        color: Color(0xFFE50914),
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text("Stok: ${item.stok}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ElevatedButton(
                            onPressed: item.stok > 0 ? () => _tambahKeCart(item) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Tambah", style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

      bottomNavigationBar: BottomNav(_tabIndex),
    );
  }
}