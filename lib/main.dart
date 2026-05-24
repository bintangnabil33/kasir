import 'package:flutter/material.dart';
import 'package:kasir/views/cart_screen.dart';
import 'package:kasir/views/dashboard.dart';
import 'package:kasir/views/history_view.dart';
import 'package:kasir/views/produk_view.dart';
import 'package:kasir/views/register.dart';
import 'package:kasir/views/transaksi_view.dart';
import 'views/login_view.dart';

// ===== IMPORT UNTUK SQFLITE DI WINDOWS/LINUX/MACOS =====
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi sqflite FFI untuk Windows, Linux, MacOS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/register',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterUserView(),
        '/dashboard': (context) => const DashboardView(),
        '/produk': (context) => const ProdukView(),
        '/transaksi': (context) => const TransaksiView(),
        '/cart': (context) => const CartScreen(),
        '/history': (context) => const HistoryView(),
      },
    );
  }
}
