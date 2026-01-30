import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kasir/models/response_data_map.dart';
import 'package:kasir/models/user_login.dart';
import 'package:kasir/services/url.dart' as url;

class UserService {
  /// ===================== REGISTER =====================
  Future<ResponseDataMap> registerUser(Map<String, dynamic> body) async {
    final uri = Uri.parse("${url.BaseUrl}/auth/register");

    final response = await http.post(uri, body: body);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData["status"] == true) {
        return ResponseDataMap(
          status: true,
          message: jsonData["message"] ?? "Register berhasil",
          data: jsonData,
        );
      } else {
        String message = "";

        // handle validasi backend (laravel-style)
        if (jsonData["message"] is Map) {
          jsonData["message"].forEach((key, value) {
            message += "${value[0]}\n";
          });
        } else {
          message = jsonData["message"].toString();
        }

        return ResponseDataMap(status: false, message: message);
      }
    } else {
      return ResponseDataMap(
        status: false,
        message: "Gagal register (Code ${response.statusCode})",
      );
    }
  }

  /// ===================== LOGIN =====================
  Future<ResponseDataMap> loginUser(Map<String, dynamic> body) async {
    final uri = Uri.parse("${url.BaseUrl}/auth/login");
    final response = await http.post(uri, body: body);

    final jsonData = json.decode(response.body);
   // DEBUGGING
    if (response.statusCode == 200 && jsonData["status"] == true) {
      final user = jsonData["user"]; // ✅ SESUAI BACKEND

      UserLogin userLogin = UserLogin(
        status: true,
        token: jsonData["token"],
        id: user["id"],
        name: user["nama_user"], // ✅ FIX
        email: user["email"],
        role: user["role"],
        message: jsonData["message"],
      );

      await userLogin.prefs();
      
      return ResponseDataMap(
        status: true,
        message: jsonData["message"],
        data: userLogin,
      );
    }

    return ResponseDataMap(
      status: false,
      message: jsonData["message"] ?? "Login gagal",
    );
  }
}
