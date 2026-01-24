import 'package:flutter/material.dart';
import 'package:kasir/views/dashboard.dart';
import 'package:kasir/views/login_view.dart';
import 'package:kasir/views/register.dart';

/// GLOBAL KEY (INI KUNCI UTAMA)
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// ⬇️ INI WAJIB
      scaffoldMessengerKey: messengerKey,

      initialRoute: '/register',
      routes: {
        '/register': (context) =>  RegisterUserView(),
        '/login': (context) =>  LoginView(),
        '/dashboard': (context) => DashboardView(),
      },
    );
  }
}
