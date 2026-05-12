import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mana_lanche/screens/client_screens.dart';
import 'package:mana_lanche/screens/admin_screens.dart';
import 'package:mana_lanche/screens/register_screens.dart';
import 'package:mana_lanche/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final senhaController =
      TextEditingController();
      bool mostrarSenha = false;

  // 🔥 LOGIN
  Future<void> login() async {

    try {

      final cred =
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email:
                    emailController.text
                        .trim(),

                password:
                    senhaController.text
                        .trim(),
              );

final user = cred.user;

final uid = user!.uid;

var doc =
    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

if (!doc.exists) {

  await FirebaseFirestore.instance
      .collection("usuarios")
      .doc(uid)
      .set({

    "nome": "Usuário",
    "email": user.email,
    "tipo": "cliente",
  });

  doc =
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get();
}

      final tipo = doc["tipo"];

      if (!mounted) return;

      if (tipo == "admin") {

        Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder:
                (_) =>
                    const AdminScreen(),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder:
                (_) =>
                    const ClientScreen(),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {

      String erro =
          "Erro ao entrar";

      if (e.code ==
          'user-not-found') {

        erro =
            "Usuário não encontrado";

      } else if (e.code ==
          'wrong-password') {

        erro =
            "Senha incorreta";

      } else if (e.code ==
          'invalid-email') {

        erro =
            "Email inválido";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text(erro),
            ),
          );
    }
  }

  // 🔐 RECUPERAR SENHA
  Future<void> recuperarSenha() async {

    if (emailController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text(
                "Digite seu email",
              ),
            ),
          );

      return;
    }

    await FirebaseAuth.instance
        .sendPasswordResetEmail(
          email:
              emailController.text
                  .trim(),
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            content: Text(
              "Email enviado",
            ),
          ),
        );
  }

  @override
  void dispose() {

    emailController.dispose();

    senhaController.dispose();

    super.dispose();
  }
                      Future<void> loginGoogle() async {

  try {

   final GoogleSignIn googleSignIn =
    GoogleSignIn(

  clientId:
  "962981084599-isekijibn1be2rsk1cerhsoq204dmml4.apps.googleusercontent.com",

);

final GoogleSignInAccount? googleUser =
    await googleSignIn.signIn();

    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential =
        GoogleAuthProvider.credential(

      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance
            .signInWithCredential(
              credential,
            );

    final user = userCredential.user;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get();

    // 🔥 cria usuário automaticamente
    if (!doc.exists) {

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .set({

        "nome":
            user.displayName ??
            "Usuário",

        "email": user.email,

        "tipo": "cliente",
      });
    }

    if (!mounted) return;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder: (_) =>
            const ClientScreen(),
      ),
    );

  } catch (e) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(
          "Erro Google Login: $e",
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(

      body: Container(
        width: double.infinity,

        decoration: BoxDecoration(

          // 🔥 BACKGROUND PREMIUM
        gradient: LinearGradient(

  colors: isDark
      ? [

          // 🌑 DARK MODE
          Color(0xFF111111),
          Color(0xFF1B1B1B),
          Color(0xFF252525),

        ]
      : [

          // 🪵 VERMELHO AMADEIRADO
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

  child: Center(

    child: Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 12,
      ),

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          // 🔥 DARK MODE
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,

            children: [

              Container(

                decoration:
                    BoxDecoration(

                      color:
                          Colors.white
                              .withValues(alpha: 0.12),

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

                    MyApp.of(
                      context,
                    )?.toggleTheme();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔥 CONTEÚDO
          Expanded(

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                // 🔥 LOGO
                Container(

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    boxShadow: [

                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.30),

                        blurRadius: 30,

                        offset:
                            const Offset(0, 15),
                      ),
                    ],
                  ),

                  child: ClipOval(

                    child: Image.asset(
                      "assets/images/logo.png",

                      width: 115,
                      height: 115,

                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // 🔥 TÍTULO
                const Text(

                  "Bem-vindo de volta!",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 26,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(

                  "Entre para continuar",

                  style: TextStyle(

                    color:
                        Colors.white.withValues(
                          alpha: 0.85,
                        ),

                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 22),

                // 🔥 CARD LOGIN
                Container(

                  padding:
                      const EdgeInsets.all(
                        24,
                      ),

                  decoration:
                      BoxDecoration(

                        // 🔥 GLASS EFFECT
                        color: isDark
                            ? Colors.white
                                .withValues(alpha: 0.06)
                            : Colors.white
                                .withValues(alpha: 0.18),

                        borderRadius:
                            BorderRadius.circular(
                              30,
                            ),

                        border: Border.all(

                          color:
                              Colors.white
                                  .withValues(alpha: 0.15),

                          width: 1.2,
                        ),

                        boxShadow: [

                          BoxShadow(

                            color:
                                Colors.black
                                    .withValues(alpha: 0.18),
                            blurRadius: 25,

                            spreadRadius: 2,

                            offset:
                                const Offset(
                                  0,
                                  12,
                                ),
                          ),
                        ],
                      ),

                  child: Column(

                    children: [

                      // 🔥 EMAIL
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

                              hintStyle:
                                  TextStyle(

                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey,
                                  ),

                              prefixIcon:
                                  const Icon(

                                    Icons.email,

                                    color: Color(
                                      0xFF7D2035,
                                    ),
                                  ),

                              filled: true,

                              fillColor: isDark
                                  ? Colors.white
                                      .withValues(alpha: 0.04)
                                  : Colors.white
                                      .withValues(alpha: 0.92),

                              border:
                                  OutlineInputBorder(

                                    borderRadius:
                                        BorderRadius.circular(
                                          18,
                                        ),

                                    borderSide:
                                        BorderSide.none,
                                  ),
                            ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // 🔥 SENHA
                      TextField(

                        controller:
                            senhaController,

                        obscureText: !mostrarSenha,

                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),

                        decoration:
                            InputDecoration(

                              hintText:
                                  "Senha",

                              hintStyle:
                                  TextStyle(

                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey,
                                  ),

                              prefixIcon:
                                  const Icon(

                                    Icons.lock,

                                    color: Color(
                                      0xFFB8860B,
                                    ),
                                  ),

                              suffixIcon: Row(

  mainAxisSize: MainAxisSize.min,

  children: [

    IconButton(

      icon: Icon(

        mostrarSenha
            ? Icons.visibility_off
            : Icons.visibility,

        color: Colors.grey,
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
                                      .withValues(alpha: 0.04)
                                  : Colors.white
                                      .withValues(alpha: 0.92),

                              border:
                                  OutlineInputBorder(

                                    borderRadius:
                                        BorderRadius.circular(
                                          18,
                                        ),

                                    borderSide:
                                        BorderSide.none,
                                  ),
                            ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      // 🔥 BOTÃO
                      SizedBox(

                        width:
                            double.infinity,

                        height: 58,

                        child:
                            ElevatedButton(

                              style:
                                  ElevatedButton.styleFrom(

                                    elevation: 8,

                                    shadowColor:
                                        Colors.black45,

                                    backgroundColor:
                                   const Color(0xFF7A2323),

                                    shape:
                                        RoundedRectangleBorder(

                                          borderRadius:
                                              BorderRadius.circular(
                                                18,
                                              ),
                                        ),
                                  ),

                              onPressed:
                                  login,

                              child:
                                  const Text(
                                    "Entrar",

                                    style:
                                        TextStyle(

                                          fontSize:
                                              22,

                                          fontWeight:
                                              FontWeight.bold,

                                          color:
                                              Colors.white,
                                        ),
                                  ),
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                // 🔥 CADASTRO
                Row(

                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    const Text(
                      "Não tem uma conta?",

                      style: TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),

                    TextButton(

                      onPressed: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    const RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Cadastre-se",

                        style: TextStyle(

                          color: Color(
                            0xFFFFE082,
                          ),

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                // 🔥 DIVISOR
                Row(

                  children: const [

                    Expanded(
                      child: Divider(
                        color:
                            Colors.white54,
                      ),
                    ),

                    Padding(

                      padding:
                          EdgeInsets.symmetric(
                            horizontal: 10,
                          ),

                      child: Text(

                        "ou entre com",

                        style: TextStyle(
                          color:
                              Colors.white,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        color:
                            Colors.white54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                // 🔥 SOCIAL
                Row(

                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    socialButton(
                      Icons.facebook,
                      Colors.blue,
                    ),

                    const SizedBox(
                      width: 18,
                    ),

                    socialButton(
                    Icons.g_mobiledata,
                  Colors.orange,

                   onTap: () async {

                  await loginGoogle();
                     },
                     ),

                    const SizedBox(
                      width: 18,
                    ),

                    socialButton(
                      Icons.camera_alt,
                      Colors.pink,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 30,
                ),
               
                        ]
                      ),
                    ),
                  ],
               ),
             ),
           ),
        ),
      ),
    );
  }
}



  // 🔥 BOTÃO SOCIAL
  Widget socialButton(
  IconData icon,
  Color color, {
  VoidCallback? onTap,
}) {

  return GestureDetector(

    onTap: onTap,

    child: Container(

      width: 58,
      height: 58,

      decoration: BoxDecoration(

        color: Colors.white.withValues(alpha: 0.10),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white24,
        ),
      ),

      child: Icon(
        icon,
        color: color,
        size: 34,
      ),
    ),
  );
}