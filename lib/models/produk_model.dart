class ProdukModel {
  final int id;
  final String namaBarang;
  final String? deskripsi;
  final int stok;
  final double harga;
  final String? image;

  ProdukModel({
    required this.id,
    required this.namaBarang,
    this.deskripsi,
    required this.stok,
    required this.harga,
    this.image,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      namaBarang: json['nama_barang'] ?? "",
      deskripsi: json['deskripsi'],
      stok: json['stok'] ?? 0,
      harga: (json['harga'] as num).toDouble(),
      image: json['image'],
    );
  }
}
