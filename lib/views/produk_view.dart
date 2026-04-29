import 'package:flutter/material.dart';
import 'package:kasir/models/produk_model.dart';
import 'package:kasir/models/response_data_list.dart';
import 'package:kasir/services/produk_services.dart';
import 'package:kasir/services/url.dart';
import 'package:kasir/widgets/bottom_nav.dart';

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
      ResponseDataList response = await produkServices.getProduk();

      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          produk = response.data as List<ProdukModel>;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? "Terjadi kesalahan")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String rupiah(double value) {
    return "Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Produk",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.67,
              ),
              itemBuilder: (context, index) {
                return _productCard(produk[index]);
              },
            ),
      bottomNavigationBar: BottomNav(1),
    );
  }

  Widget _productCard(ProdukModel item) {
    /// 🔥 FIX FINAL UNTUK LARAVEL STORAGE
    String imageUrl = "$BaseUrlTanpaAPI/${item.image ?? ''}";
    imageUrl = Uri.encodeFull(imageUrl);

    print("IMAGE URL FINAL: $imageUrl");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= IMAGE =================
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: item.image != null && item.image!.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print("❌ GAGAL LOAD IMAGE: $imageUrl");
                        print("❌ ERROR DETAIL: $error");

                        return Container(
                          height: 150,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 40),
                        );
                      },
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),

            /// ================= INFO =================
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaBarang,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rupiah(item.harga.toDouble()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFFE50914),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Stok: ${item.stok}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.deskripsi!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
