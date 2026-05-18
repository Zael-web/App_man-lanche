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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool mostrarSenha = false;

  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  // 🔥 LOGIN
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
    }
  }

  // 🔐 RECUPERAR SENHA
  Future<void> recuperarSenha() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite seu email")),
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email enviado")),
    );
  }

  // 🔥 LOGIN GOOGLE
  Future<void> loginGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "962981084599-isekijibn1be2rsk1cerhsoq204dmml4.apps.googleusercontent.com",
      );

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth =
          await googleUser.authentication;

      final credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance
              .signInWithCredential(credential);

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
        MaterialPageRoute(
          builder: (_) => const ClientScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro Google Login: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final size = MediaQuery.of(context).size;

    final largura = MediaQuery.of(context).size.width;
    final altura = MediaQuery.of(context).size.height;

    final isSmall = size.height < 700;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),

          // 🍔 HAMBÚRGUER
          FloatingFood(
            image: "assets/images/hamburguer.png",
            left: largura * 0.08,
            top: altura * 0.12,
            size: largura * 0.15,
            duration: const Duration(seconds: 3),
          ),

          // 🍟 BATATA
          FloatingFood(
            image: "assets/images/batata.png",
            left: largura * 0.72,
            top: altura * 0.38,
            size: largura * 0.15,
            duration: const Duration(seconds: 3),
          ),

          // 🍕 PIZZA
          FloatingFood(
            image: "assets/images/pizza.png",
            left: largura * 0.10,
            top: altura * 0.38,
            size: largura * 0.15,
            duration: const Duration(seconds: 3),
          ),

          // 🥤 REFRIGERANTE
          FloatingFood(
            image: "assets/images/refrigerantes.png",
            left: largura * 0.70,
            top: altura * 0.12,
            size: largura * 0.16,
            duration: const Duration(seconds: 3),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          size.height -
                              MediaQuery.of(context)
                                  .padding
                                  .top,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(15),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        MyApp.of(context)
                                            ?.toggleTheme();
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              const FloatingLogo(),

                              const SizedBox(height: 18),

                              Text(
                                "Bem-vindo de volta!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      isSmall ? 22 : 26,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Entre para continuar",
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.85),
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 22),

                              Container(
                                padding: EdgeInsets.all(
                                  isSmall ? 16 : 24,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white
                                          .withOpacity(0.06)
                                      : Colors.white
                                          .withOpacity(0.18),
                                  borderRadius:
                                      BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller:
                                          emailController,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      decoration:
                                          InputDecoration(
                                        hintText:
                                            "E-mail",
                                        prefixIcon:
                                            const Icon(
                                          Icons.email,
                                          color: Color(0xFF7D2035),
                                        ),
                                        filled: true,
                                        fillColor: isDark
                                            ? Colors.white
                                                .withOpacity(0.08)
                                            : Colors.white
                                                .withOpacity(0.9),
                                        border:
                                            OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide:
                                              BorderSide.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    TextField(
                                      controller:
                                          senhaController,
                                      obscureText:
                                          !mostrarSenha,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      decoration:
                                          InputDecoration(
                                        hintText:
                                            "Senha",
                                        prefixIcon:
                                            const Icon(
                                          Icons.lock,
                                          color: Color(0xFFB8860B),
                                        ),
                                        suffixIcon: Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                mostrarSenha
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  mostrarSenha =
                                                      !mostrarSenha;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              onPressed:
                                                  recuperarSenha,
                                              child:
                                                  const Text(
                                                "Esqueceu?",
                                              ),
                                            ),
                                          ],
                                        ),
                                        filled: true,
                                        fillColor: isDark
                                            ? Colors.white
                                                .withOpacity(0.08)
                                            : Colors.white
                                                .withOpacity(0.9),
                                        border:
                                            OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide:
                                              BorderSide.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    SizedBox(
                                      width: double.infinity,
                                      height:
                                          isSmall ? 50 : 56,
                                      child: ElevatedButton(
                                        style:
                                            ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFC107),
                                          foregroundColor:
                                              Colors.white,
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                        onPressed: login,
                                        child: const Text(
                                          'Entrar',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Não tem uma conta?",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Cadastre-se",
                                      style: TextStyle(
                                        color:
                                            Color(0xFFFFE082),
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),
                             SizedBox(
  width: double.infinity,
  height: 56,

  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          Colors.white.withOpacity(0.10),

      foregroundColor: Colors.white,

      elevation: 0,

      side: BorderSide(
        color: Colors.white.withOpacity(0.15),
      ),

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
    ),

    onPressed: loginGoogle,

    icon: Image.asset(
      "assets/images/google.png",
      width: 30,
      height: 30,
    ),

    label: const Text(
      "Entrar com o Google",

      style: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget socialButton(
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    final size = MediaQuery.of(context).size;

    final isSmall = size.height < 700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmall ? 50 : 58,
        height: isSmall ? 50 : 58,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius:
              BorderRadius.circular(18),
          border:
              Border.all(color: Colors.white24),
        ),
        child: Icon(
          icon,
          color: color,
          size: isSmall ? 28 : 34,
        ),
      ),
    );
  }
}

// 🌌 FUNDO
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() =>
      _AnimatedBackgroundState();
}

class _AnimatedBackgroundState
    extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + controller.value,
                -1,
              ),
              end: Alignment(
                1,
                1 - controller.value,
              ),
              colors: isDark
                  ? const [
                      Color(0xFF050505),
                      Color(0xFF111111),
                      Color(0xFF1A1A1A),
                      Color(0xFF222222),
                    ]
                  : const [
                      Color(0xFF4A0E0F),
                      Color(0xFF7A2323),
                      Color(0xFFB33939),
                      Color(0xFF7A2323),
                    ],
            ),
          ),
        );
      },
    );
  }
}

// 🍔 ALIMENTOS FLUTUANDO
class FloatingFood extends StatefulWidget {
  final String image;
  final double left;
  final double top;
  final double size;
  final Duration duration;

  const FloatingFood({
    super.key,
    required this.image,
    required this.left,
    required this.top,
    required this.size,
    required this.duration,
  });

  @override
  State<FloatingFood> createState() =>
      _FloatingFoodState();
}

class _FloatingFoodState
    extends State<FloatingFood>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: -20,
      end: 20,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          top: widget.top + animation.value,
          child: Opacity(
            opacity: 0.18,
            child: Image.asset(
              widget.image,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

// ✨ LOGO
class FloatingLogo extends StatefulWidget {
  const FloatingLogo({super.key});

  @override
  State<FloatingLogo> createState() =>
      _FloatingLogoState();
}

class _FloatingLogoState
    extends State<FloatingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  Colors.red.withOpacity(0.35),
              blurRadius: 35,
              spreadRadius: 5,
            ),
          ],
          image: const DecorationImage(
            image: AssetImage(
              "assets/images/logo.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}