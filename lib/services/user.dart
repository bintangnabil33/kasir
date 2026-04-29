import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/response_data_map.dart';
import 'url.dart';

class UserService {
  // ================= REGISTER =================
  Future<ResponseDataMap> registerUser(Map<String, dynamic> body) async {
    final uri = Uri.parse(BaseUrl + "/auth/register");

    final response = await http.post(uri, body: body);
    print("REGISTER BODY: $body");
    print("REGISTER RESPONSE: ${response.body}");
    final jsonData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonData["status"] == true) {
        return ResponseDataMap(status: true, message: jsonData["message"]);
      } else {
        // Handle error validation (email sudah dipakai dll)
        String errorMessage = "Register gagal";

        if (jsonData["message"] is Map) {
          final msgMap = jsonData["message"] as Map;
          errorMessage = msgMap.values.first.first.toString();
        }

        return ResponseDataMap(status: false, message: errorMessage);
      }
    }

    return ResponseDataMap(status: false, message: "Server error");
  }

  // ================= LOGIN =================
  Future<ResponseDataMap> loginUser(Map<String, dynamic> body) async {
    final uri = Uri.parse(BaseUrl + "/auth/login");

    final response = await http.post(uri, body: body);

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    if (response.statusCode != 200) {
      return ResponseDataMap(
        status: false,
        message: "Server Error ${response.statusCode}",
      );
    }

    if (response.body.isEmpty) {
      return ResponseDataMap(
        status: false,
        message: "Response kosong dari server",
      );
    }

    final jsonData = jsonDecode(response.body);
    
    return ResponseDataMap(
      status: jsonData["status"] ?? false,
      message: jsonData["message"] ?? "Login gagal",
      data: jsonData,
    );
  }
}
