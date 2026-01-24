import 'package:flutter/material.dart';
import 'package:kasir/services/user.dart';
import 'package:kasir/widgets/alert.dart';

class RegisterUserView extends StatefulWidget {
  const RegisterUserView({super.key});

  @override
  State<RegisterUserView> createState() => _RegisterUserViewState();
}

class _RegisterUserViewState extends State<RegisterUserView> {
  final UserService user = UserService();
  final formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  List<String> roleChoice = ["Admin", "User"];
  String? role;

  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

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

  // ================= UI =================
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
                const SizedBox(height: 30),

                // ===== LOGO / TITLE =====
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
                  "Create your account",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),

                // ===== CARD FORM =====
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
                        TextFormField(
                          controller: name,
                          decoration:
                              elegantInput("Nama Lengkap", Icons.person),
                          validator: (v) =>
                              v!.isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              elegantInput("Email", Icons.email_outlined),
                          validator: (v) =>
                              v!.isEmpty ? 'Email wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: role,
                          decoration:
                              elegantInput("Role", Icons.admin_panel_settings),
                          items: roleChoice
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => role = v),
                          validator: (v) => v == null ? 'Pilih role' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: password,
                          obscureText: !isPasswordVisible,
                          decoration: elegantInput(
                            "Password",
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(
                                  () => isPasswordVisible = !isPasswordVisible),
                            ),
                          ),
                          validator: (v) =>
                              v!.length < 6 ? 'Minimal 6 karakter' : null,
                        ),
                        const SizedBox(height: 28),

                        // ===== BUTTON =====
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : _handleRegister,
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
                                    "REGISTER",
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

                // ===== LOGIN LINK =====
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Sudah punya akun? Login",
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
  Future<void> _handleRegister() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final result = await user.registerUser({
        "name": name.text,
        "email": email.text,
        "role": role!.toLowerCase(),
        "password": password.text,
      });

      if (!mounted) return;

      if (result.status == true) {
        AlertMessage().showAlert(
          context,
          "Register berhasil, silakan login",
          true,
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        AlertMessage().showAlert(context, result.message, false);
      }
    } catch (e) {
      AlertMessage().showAlert(context, "Terjadi kesalahan", false);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
