import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kasir/models/user_login.dart';
import '../models/response_data_map.dart';
import 'url.dart';

class TransaksiService {
  final UserLogin _userLogin = UserLogin();

  // ===== CHECKOUT =====
  // Endpoint: POST /user/transaksi
  // Body: { "pesan": [ { "barang_id": x, "qty": y } ] }
  Future<ResponseDataMap> checkout(List<Map<String, dynamic>> items) async {
    var user = await _userLogin.getUserLogin();

    if (user.status == false) {
      return ResponseDataMap(status: false, message: "Silakan login terlebih dahulu");
    }

    try {
      var body = json.encode({"pesan": items});

      print("CHECKOUT URL  : $BaseUrl/user/transaksi");
      print("CHECKOUT BODY : $body");

      var response = await http.post(
        Uri.parse("$BaseUrl/user/transaksi"),
        headers: {
          "Authorization": "Bearer ${user.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      print("CHECKOUT STATUS : ${response.statusCode}");
      print("CHECKOUT BODY   : ${response.body}");

      if (!response.body.trimLeft().startsWith("{")) {
        return ResponseDataMap(status: false, message: "Server tidak mengirim JSON");
      }

      var jsonData = jsonDecode(response.body);
      return ResponseDataMap(
        status: jsonData["status"] ?? false,
        message: jsonData["message"] ?? "",
        data: jsonData["data"],
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Error: $e");
    }
  }

  // ===== HISTORY TRANSAKSI =====
  // Endpoint: GET /user/history_trans
  Future<ResponseDataMap> getHistory() async {
    var user = await _userLogin.getUserLogin();

    if (user.status == false) {
      return ResponseDataMap(status: false, message: "Silakan login terlebih dahulu");
    }

    try {
      var response = await http.get(
        Uri.parse("$BaseUrl/user/history_trans"),
        headers: {
          "Authorization": "Bearer ${user.token}",
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 15));

      print("HISTORY STATUS : ${response.statusCode}");
      print("HISTORY BODY   : ${response.body.substring(0, response.body.length.clamp(0, 300))}");

      if (!response.body.trimLeft().startsWith("{")) {
        return ResponseDataMap(status: false, message: "Server tidak mengirim JSON");
      }

      var jsonData = jsonDecode(response.body);
      return ResponseDataMap(
        status: jsonData["status"] ?? false,
        message: jsonData["message"] ?? "",
        data: jsonData["data"],
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: "Error: $e");
    }
  }
}