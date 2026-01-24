import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool status;
  String? token;
  String? role;
  String? message;
  int? id;
  String? name;
  String? email;

  UserLogin({
    this.status = false,
    this.token,
    this.role,
    this.message,
    this.id,
    this.name,
    this.email,
  });

  // SIMPAN SESSION
  Future<void> prefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('status', status);
    await prefs.setString('token', token ?? '');
    await prefs.setString('role', role ?? '');
    await prefs.setInt('id', id ?? 0);
    await prefs.setString('name', name ?? '');
    await prefs.setString('email', email ?? '');
  }

  // AMBIL SESSION
  Future<UserLogin> getUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return UserLogin(
      status: prefs.getBool('status') ?? false,
      token: prefs.getString('token'),
      role: prefs.getString('role'),
      id: prefs.getInt('id'),
      name: prefs.getString('name'),
      email: prefs.getString('email'),
    );
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
