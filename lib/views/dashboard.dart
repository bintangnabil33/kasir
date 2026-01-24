import 'package:flutter/material.dart';
import 'package:kasir/models/user_login.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final UserLogin userLogin = UserLogin();

  String? nama;
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserLogin();
  }

  // ================= CEK LOGIN =================
  Future<void> getUserLogin() async {
    final user = await userLogin.getUserLogin();

    if (!mounted) return;

    if (user.status != true) {
      setState(() => isLoading = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      setState(() {
        nama = user.name;
        role = user.role;
        isLoading = false;
      });
    }
  }

  // ================= LOGOUT =================
  Future<void> handleLogout() async {
    await userLogin.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Sir Kasir",
          style: TextStyle(
            color: Color(0xFFE50914),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: handleLogout,
          ),
        ],
      ),

      // ===== BODY =====
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // ===== TITLE =====
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Ringkasan akun Anda",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 30),

                  // ===== CARD USER INFO =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Akun",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE50914),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _infoRow("Nama", nama ?? "-"),
                        const SizedBox(height: 10),
                        _infoRow("Role", role ?? "-"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ===== LOGOUT BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "LOGOUT",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ===== HELPER INFO ROW =====
  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
