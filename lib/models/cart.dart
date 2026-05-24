class Cart {
  final int? id;
  final String? idBarang;
  final String? namaBarang;
  final double? harga;
  int? quantity;
  final String? image;

  Cart({
    required this.id,
    required this.idBarang,
    required this.namaBarang,
    required this.harga,
    required this.quantity,
    required this.image,
  });

  factory Cart.fromMap(Map<dynamic, dynamic> data) {
    return Cart(
      id:         data['id'],
      idBarang:   data['id_barang'].toString(),
      namaBarang: data['nama_barang'],
      harga:      double.parse(data['harga'].toString()),
      quantity:   data['quantity'],
      image:      data['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':          id,
      'id_barang':   idBarang,
      'nama_barang': namaBarang,
      'harga':       harga,
      'quantity':    quantity,
      'image':       image,
    };
  }
}