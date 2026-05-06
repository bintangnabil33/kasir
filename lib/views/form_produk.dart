import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/produk_model.dart';
import '../models/response_data_map.dart';
import '../services/produk_services.dart';
import '../services/url.dart';

class FormProdukView extends StatefulWidget {
  // null = Tambah, ada isi = Edit
  final ProdukModel? produk;

  const FormProdukView({super.key, this.produk});

  @override
  State<FormProdukView> createState() => _FormProdukViewState();
}

class _FormProdukViewState extends State<FormProdukView> {
  final ProdukServices produkServices = ProdukServices();
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nama;
  late TextEditingController harga;
  late TextEditingController stok;
  late TextEditingController deskripsi;

  File? _selectedFoto;
  bool isLoading = false;

  // Cek mode: true = edit, false = tambah
  bool get isEdit => widget.produk != null;

  @override
  void initState() {
    super.initState();
    // Kalau edit, isi data lama. Kalau tambah, kosong.
    nama      = TextEditingController(text: widget.produk?.namaBarang ?? "");
    harga     = TextEditingController(text: widget.produk?.harga.toString() ?? "");
    stok      = TextEditingController(text: widget.produk?.stok.toString() ?? "");
    deskripsi = TextEditingController(text: widget.produk?.deskripsi ?? "");
  }

  // ===== PILIH FOTO =====
  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 1024,
      );
      if (picked != null) setState(() => _selectedFoto = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih foto: $e")),
      );
    }
  }

  // ===== BOTTOM SHEET =====
  void _showPilihFotoSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pilih Sumber Foto",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceButton("Kamera", Icons.camera_alt, const Color(0xFFE50914),
                    () { Navigator.pop(context); _pilihFoto(ImageSource.camera); }),
                _sourceButton("Galeri", Icons.photo_library, Colors.blue,
                    () { Navigator.pop(context); _pilihFoto(ImageSource.gallery); }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sourceButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  // ===== SIMPAN (tambah atau edit) =====
  Future<void> simpan() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    ResponseDataMap response = await produkServices.simpanProduk(
      nama:      nama.text,
      harga:     harga.text,
      stok:      stok.text,
      deskripsi: deskripsi.text,
      foto:      _selectedFoto,
      id:        widget.produk?.id, // null = insert, ada = update
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? ""),
        backgroundColor: response.status ? Colors.green : Colors.red,
      ),
    );

    if (response.status == true) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nama.dispose(); harga.dispose(); stok.dispose(); deskripsi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build URL gambar lama (hanya saat mode edit)
    String imageUrl = '';
    if (isEdit && widget.produk!.image != null && widget.produk!.image!.isNotEmpty) {
      final cleanPath = widget.produk!.image!.startsWith('/')
          ? widget.produk!.image!.substring(1)
          : widget.produk!.image!;
      final encoded = cleanPath.split('/').map(Uri.encodeComponent).join('/');
      imageUrl = '$BaseUrlTanpaAPI/$encoded';
    }
    final adaFotoLama = imageUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        // Judul otomatis sesuai mode
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [

              // ===== SEKSI FOTO =====
              const Text("Foto Produk",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              // Preview foto
              GestureDetector(
                onTap: _showPilihFotoSheet,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedFoto != null
                          ? const Color(0xFFE50914)
                          : Colors.grey.shade300,
                      width: _selectedFoto != null ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _selectedFoto != null
                        // Foto baru yang dipilih
                        ? Image.file(_selectedFoto!, fit: BoxFit.cover,
                            width: double.infinity)
                        : adaFotoLama
                            // Foto lama dari server (mode edit)
                            ? Image.network(imageUrl, fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 52, color: Colors.grey),
                                ))
                            // Tidak ada foto
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined,
                                      size: 52, color: Colors.grey.shade400),
                                  const SizedBox(height: 10),
                                  Text("Ketuk untuk tambah foto",
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text("(Opsional)",
                                      style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12)),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Tombol pilih / ganti foto
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showPilihFotoSheet,
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(adaFotoLama || _selectedFoto != null
                          ? "Ganti Foto"
                          : "Pilih Foto"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE50914),
                        side: const BorderSide(color: Color(0xFFE50914)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  if (_selectedFoto != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _selectedFoto = null),
                        icon: const Icon(Icons.close),
                        label: const Text("Batal"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // ===== FORM DATA =====
              const Text("Data Produk",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              TextFormField(
                controller: nama,
                decoration: const InputDecoration(
                    labelText: "Nama Barang", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: harga,
                decoration: const InputDecoration(
                    labelText: "Harga",
                    border: OutlineInputBorder(),
                    prefixText: "Rp "),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: stok,
                decoration: const InputDecoration(
                    labelText: "Stok", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: deskripsi,
                decoration: const InputDecoration(
                    labelText: "Deskripsi", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ===== TOMBOL SIMPAN =====
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? "Update Produk" : "Simpan Produk",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}