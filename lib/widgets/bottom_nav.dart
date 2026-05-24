import 'package:flutter/material.dart';
import 'package:kasir/models/user_login.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  const BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  UserLogin userLogin = UserLogin();
  String? role;
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    getDataLogin();
  }

  Future<void> getDataLogin() async {
    var user = await userLogin.getUserLogin();
    if (!mounted) return;
    if (user.status == true) {
      setState(() { role = user.role; isChecking = false; });
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void getLink(int index) {
    if (role == "admin") {
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      else if (index == 1) Navigator.pushReplacementNamed(context, '/produk');
    } else {
      // user
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      else if (index == 1) Navigator.pushReplacementNamed(context, '/transaksi');
      else if (index == 2) Navigator.pushReplacementNamed(context, '/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) return const SizedBox();

    // ADMIN: Dashboard | Produk
    if (role == "admin") {
      return BottomNavigationBar(
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: widget.activePage,
        onTap: getLink,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk'),
        ],
      );
    }

    // USER: Dashboard | Pesan | History
    return BottomNavigationBar(
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.grey,
      currentIndex: widget.activePage,
      onTap: getLink,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Pesan'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
    );
  }
}