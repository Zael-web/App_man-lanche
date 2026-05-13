import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mana_lanche/screens/client_screens.dart';
import 'package:mana_lanche/screens/admin_menu_screen.dart';
import 'package:mana_lanche/screens/register_screens.dart';
import 'package:mana_lanche/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool mostrarSenha = false;

  // 🔥 LOGIN EMAIL/SENHA
  Future<void> login() async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = cred.user!;
      final uid = user.uid;

      var doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection("usuarios").doc(uid).set({
          "nome": "Usuário",
          "email": user.email,
          "tipo": "cliente",
        });

        doc = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(uid)
            .get();
      }

      final tipo = doc["tipo"];

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => tipo == "admin"
              ? const AdminMenuScreen()
              : const ClientScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String erro = "Erro ao entrar";

      if (e.code == 'user-not-found') {
        erro = "Usuário não encontrado";
      } else if (e.code == 'wrong-password') {
        erro = "Senha incorreta";
      } else if (e.code == 'invalid-email') {
        erro = "Email inválido";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  // 🔐 RECUPERAR SENHA
  Future<void> recuperarSenha() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Digite seu email")));
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Email enviado")));
  }

  // 🔥 GOOGLE LOGIN
  Future<void> loginGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "962981084599-isekijibn1be2rsk1cerhsoq204dmml4.apps.googleusercontent.com",
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user!;
      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(user.uid)
            .set({
              "nome": user.displayName ?? "Usuário",
              "email": user.email,
              "tipo": "cliente",
            });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro Google Login: $e")));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF111111), Color(0xFF1B1B1B), Color(0xFF252525)]
                : [
                    Color(0xFF5C1A1B),
                    Color(0xFF7A2323),
                    Color(0xFF9B2C2C),
                    Color(0xFFB33939),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🌙 DARK MODE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                MyApp.of(context)?.toggleTheme();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 🔥 LOGO
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: isSmall ? 90 : 115,
                          height: isSmall ? 90 : 115,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        "Bem-vindo de volta!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 22 : 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Entre para continuar",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 🔥 CARD LOGIN
                      Container(
                        padding: EdgeInsets.all(isSmall ? 16 : 24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          children: [
                            // EMAIL
                            TextField(
                              controller: emailController,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "E-mail",
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Color(0xFF7D2035),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // SENHA
                            TextField(
                              controller: senhaController,
                              obscureText: !mostrarSenha,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "Senha",
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Color(0xFFB8860B),
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        mostrarSenha
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          mostrarSenha = !mostrarSenha;
                                        });
                                      },
                                    ),
                                    TextButton(
                                      onPressed: recuperarSenha,
                                      child: const Text("Esqueceu?"),
                                    ),
                                  ],
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // BOTÃO LOGIN
                            SizedBox(
                              width: double.infinity,
                              height: isSmall ? 52 : 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF7A2323),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: login,
                                child: Text(
                                  "Entrar",
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CADASTRO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Não tem uma conta?",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Cadastre-se",
                              style: TextStyle(
                                color: Color(0xFFFFE082),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // SOCIAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          socialButton(Icons.facebook, Colors.blue),
                          const SizedBox(width: 15),
                          socialButton(
                            Icons.g_mobiledata,
                            Colors.orange,
                            onTap: loginGoogle,
                          ),
                          const SizedBox(width: 15),
                          socialButton(Icons.camera_alt, Colors.pink),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 BOTÃO SOCIAL
  Widget socialButton(IconData icon, Color color, {VoidCallback? onTap}) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmall ? 50 : 58,
        height: isSmall ? 50 : 58,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: isSmall ? 28 : 34),
      ),
    );
  }
}
