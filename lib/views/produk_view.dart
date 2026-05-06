import 'package:flutter/material.dart';
import 'package:kasir/models/produk_model.dart';
import 'package:kasir/models/response_data_list.dart';
import 'package:kasir/services/produk_services.dart';
import 'package:kasir/services/url.dart';
import 'package:kasir/widgets/bottom_nav.dart';
import 'form_produk.dart'; // <-- satu file untuk tambah & edit

class ProdukView extends StatefulWidget {
  const ProdukView({super.key});

  @override
  State<ProdukView> createState() => _ProdukViewState();
}

class _ProdukViewState extends State<ProdukView> {
  final ProdukServices produkServices = ProdukServices();
  List<ProdukModel> produk = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProduk();
  }

  Future<void> getProduk() async {
    try {
      ResponseDataList<ProdukModel> response = await produkServices.getProduk();
      if (!mounted) return;
      if (response.status) {
        setState(() { produk = response.data ?? []; isLoading = false; });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? "Terjadi kesalahan")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String rupiah(double value) {
    return "Rp ${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}."
    )}";
  }

  String buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    final encoded = cleanPath.split('/').map(Uri.encodeComponent).join('/');
    return '$BaseUrlTanpaAPI/$encoded';
  }

  // ===== NAVIGASI KE FORM =====
  Future<void> _bukaForm({ProdukModel? produk}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormProdukView(produk: produk), // null = tambah, ada = edit
      ),
    );
    if (result == true) getProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Produk", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE50914),
        child: const Icon(Icons.add),
        onPressed: () => _bukaForm(), // tambah = tanpa produk
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : produk.isEmpty
              ? const Center(child: Text("Produk tidak tersedia"))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: produk.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.58,
                  ),
                  itemBuilder: (context, index) => _productCard(produk[index]),
                ),
      bottomNavigationBar: BottomNav(1),
    );
  }

  Widget _productCard(ProdukModel item) {
    final imageUrl = buildImageUrl(item.image);
    final adaGambar = imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: adaGambar
                ? Image.network(imageUrl, height: 130, width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : Container(
                          height: 130, color: Colors.grey.shade200,
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                    errorBuilder: (_, __, ___) => Container(
                      height: 130, color: Colors.grey.shade200,
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 36, color: Colors.grey)),
                    ))
                : Container(height: 130, color: Colors.grey.shade300,
                    child: const Center(
                        child: Icon(Icons.image, size: 36, color: Colors.grey))),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.namaBarang,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(rupiah(item.harga),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14,
                            color: Color(0xFFE50914))),
                  ),
                  const SizedBox(height: 2),
                  Text("Stok: ${item.stok}",
                      style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Edit — kirim data produk
                      InkWell(
                        onTap: () => _bukaForm(produk: item),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.edit, color: Colors.blue, size: 20),
                        ),
                      ),
                      // Hapus
                      InkWell(
                        onTap: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Konfirmasi"),
                              content: const Text("Yakin ingin menghapus produk ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text("Hapus"),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
                          if (!mounted) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          final result = await produkServices.hapusProduk(item.id);
                          if (!mounted) return;
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.message ?? ""),
                              backgroundColor: result.status ? Colors.green : Colors.red,
                            ),
                          );
                          if (result.status == true) getProduk();
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.delete, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}