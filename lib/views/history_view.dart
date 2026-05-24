import 'package:flutter/material.dart';
import 'package:kasir/services/transaksi_service.dart';
import 'package:kasir/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final TransaksiService _service = TransaksiService();

  List<dynamic> historyList = [];
  bool isLoading = true;
  String? errorMsg;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { isLoading = true; errorMsg = null; });

    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString("role");

    var result = await _service.getHistory();

    if (!mounted) return;

    if (result.status && result.data != null) {
      setState(() {
        historyList = result.data as List<dynamic>;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMsg = result.message ?? "Gagal memuat history";
      });
    }
  }

  int get _tabIndex => role == "admin" ? 2 : 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "History Transaksi",
          style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w700),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : errorMsg != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(errorMsg!, textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadHistory,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Coba Lagi"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                )
          : historyList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 72, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Belum ada transaksi",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              color: const Color(0xFFE50914),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  final item = historyList[index];
                  final List detail = item["detail"] ?? [];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== HEADER =====
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Transaksi #${item["id_transaksi"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: const Text("Selesai",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),

                        // ===== INFO =====
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(item["nama_user"] ?? "-",
                                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
                              const Spacer(),
                              const Icon(Icons.calendar_today_outlined,
                                  size: 14, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(item["tgl_transaksi"] ?? "-",
                                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // ===== DETAIL ITEM =====
                        if (detail.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("Tidak ada detail transaksi",
                                style: TextStyle(color: Colors.grey, fontSize: 13)),
                          )
                        else
                          ...detail.map((d) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_bag_outlined,
                                      size: 16, color: Color(0xFFE50914)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      d["nama_barang"] ?? "Barang #${d["barang_id"]}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    "x${d["qty"] ?? d["jumlah"] ?? 1}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE50914)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: 8),
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