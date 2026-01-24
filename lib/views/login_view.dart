import 'package:flutter/material.dart';
import 'package:kasir/services/user.dart';
import 'package:kasir/widgets/alert.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final UserService user = UserService();
  final formKey = GlobalKey<FormState>();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isLoading = false;
  bool showpass = true;

  // ================= INPUT STYLE =================
  InputDecoration elegantInput(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE50914), Color(0xFFB20710)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ===== TITLE =====
                const Text(
                  "Sir Kasir",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login to your account",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 32),

                // ===== CARD =====
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // EMAIL
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              elegantInput("Email", Icons.email_outlined),
                          validator: (v) =>
                              v!.isEmpty ? 'Email wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        // PASSWORD
                        TextFormField(
                          controller: password,
                          obscureText: showpass,
                          decoration: elegantInput(
                            "Password",
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                showpass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => showpass = !showpass);
                              },
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Password wajib diisi' : null,
                        ),

                        const SizedBox(height: 28),

                        // BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  )
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LINK REGISTER
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    "Belum punya akun? Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGIC (TETAP) =================
  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final result = await user.loginUser({
        "email": email.text,
        "password": password.text,
      });

      if (!mounted) return;

      if (result.status == true) {
        AlertMessage().showAlert(
          context,
          result.message ?? "Login berhasil",
          true,
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        });
      } else {
        AlertMessage().showAlert(
          context,
          result.message ?? "Login gagal",
          false,
        );
      }
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      AlertMessage()
          .showAlert(context, "Terjadi kesalahan saat login", false);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
