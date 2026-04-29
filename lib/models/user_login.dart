import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool? status;
  String? token;
  int? id;
  String? name;
  String? email;
  String? role;

  UserLogin({
    this.status,
    this.token,
    this.id,
    this.name,
    this.email,
    this.role,
  });

  // ===== SIMPAN LOGIN =====
  Future<void> prefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("status", status ?? false);
    await pref.setString("token", token ?? "");
    await pref.setInt("id", id ?? 0);
    await pref.setString("name", name ?? "");
    await pref.setString("email", email ?? "");
    await pref.setString("role", role ?? "");
  }

  // ===== AMBIL DATA LOGIN =====
  Future<UserLogin> getUserLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    return UserLogin(
      status: pref.getBool("status") ?? false,
      token: pref.getString("token"),
      id: pref.getInt("id"),
      name: pref.getString("name"),
      email: pref.getString("email"),
      role: pref.getString("role"),
    );
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}