import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produk_model.dart';
import '../models/response_data_list.dart';
import 'url.dart';

class ProdukServices {
  Future<ResponseDataList> getProduk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      print("TOKEN DARI PREF: $token");

      var uri = Uri.parse("$BaseUrl/admin/getbarang");

      var response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("PRODUK STATUS: ${response.statusCode}");
      print("PRODUK BODY: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData["status"] == true) {
          List<ProdukModel> produk = (jsonData["data"] as List)
              .map((e) => ProdukModel.fromJson(e))
              .toList();

          return ResponseDataList(
            status: true,
            message: "success",
            data: produk,
          );
        } else {
          return ResponseDataList(
            status: false,
            message: jsonData["message"],
          );
        }
      } else {
        return ResponseDataList(
          status: false,
          message: "Unauthorized / Token invalid",
        );
      }
    } catch (e) {
      print("ERROR GET PRODUK: $e");

      return ResponseDataList(
        status: false,
        message: "Terjadi error: $e",
      );
    }
  }
}