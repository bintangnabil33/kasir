import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produk_model.dart';
import '../models/response_data_list.dart';
import '../models/response_data_map.dart';
import 'url.dart';

class ProdukServices {

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ================= GET =================
  // Endpoint: GET /admin/getbarang
  Future<ResponseDataList<ProdukModel>> getProduk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var uri = Uri.parse("$BaseUrl/admin/getbarang");
      var response = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      }).timeout(const Duration(seconds: 15));

      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData["status"] == true) {
        List<ProdukModel> produk = (jsonData["data"] as List)
            .map((e) => ProdukModel.fromJson(e))
            .toList();
        return ResponseDataList(status: true, message: jsonData["message"], data: produk);
      }
      return ResponseDataList(status: false, message: jsonData["message"]);
    } catch (e) {
      return ResponseDataList(status: false, message: "Error: $e");
    }
  }

  // ================= CREATE & UPDATE =================
  // Insert : POST /admin/insertbarang         (id == null)
  // Update : POST /admin/updatebarang/{id}    (id != null)
  // Keduanya pakai MultipartRequest agar bisa kirim foto sekaligus
  Future<ResponseDataMap> simpanProduk({
    required String nama,
    required String harga,
    required String stok,
    required String deskripsi,
    File? foto,
    int? id, // null = insert, ada = update
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      Uri uri;
      if (id == null) {
        uri = Uri.parse("$BaseUrl/admin/insertbarang");
      } else {
        uri = Uri.parse("$BaseUrl/admin/updatebarang/$id");
      }

      var request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields["nama_barang"] = nama;
      request.fields["harga"]       = harga;
      request.fields["stok"]        = stok;
      request.fields["deskripsi"]   = deskripsi;

      if (foto != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", foto.path),
        );
      }

      var streamed  = await request.send().timeout(const Duration(seconds: 30));
      var response  = await http.Response.fromStream(streamed);

      print("STATUS CODE : ${response.statusCode}");
      print("BODY        : ${response.body}");

      // Tangkap kalau server kirim HTML (bukan JSON)
      if (!response.body.trimLeft().startsWith("{")) {
        return ResponseDataMap(
          status: false,
          message: "Server tidak mengirim JSON (error backend)",
        );
      }

      var jsonData = jsonDecode(response.body);

      return ResponseDataMap(
        status: jsonData["status"] ?? false,
        message: jsonData["message"] ?? "",
        data: jsonData,
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Error: $e");
    }
  }

  // ================= DELETE =================
  // Endpoint: DELETE /admin/hapusbarang/{id}
  Future<ResponseDataMap> hapusProduk(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var uri = Uri.parse("$BaseUrl/admin/hapusbarang/$id");
      var response = await http.delete(uri, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      }).timeout(const Duration(seconds: 15));

      print("DELETE STATUS : ${response.statusCode}");
      print("DELETE BODY   : ${response.body}");

      var jsonData = jsonDecode(response.body);

      return ResponseDataMap(
        status: jsonData["status"] ?? false,
        message: jsonData["message"] ?? "",
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Error: $e");
    }
  }
}