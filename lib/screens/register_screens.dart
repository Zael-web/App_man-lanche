import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final nomeController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final telefoneController =
      TextEditingController();

  final senhaController =
      TextEditingController();

  final confirmarSenhaController =
      TextEditingController();

  bool carregando = false;

  // 🔥 CADASTRO
  Future<void> cadastrar() async {

    if (senhaController.text !=
        confirmarSenhaController.text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text(
                "As senhas não coincidem",
              ),
            ),
          );

      return;
    }

    if (senhaController.text.length < 6) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text(
                "Senha deve ter no mínimo 6 caracteres",
              ),
            ),
          );

      return;
    }

    try {

      setState(() => carregando = true);

      UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email:
                    emailController.text.trim(),

                password:
                    senhaController.text.trim(),
              );

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .set({

            "nome":
                nomeController.text.trim(),

            "email":
                emailController.text.trim(),

            "telefone":
                telefoneController.text.trim(),

            "tipo": "cliente",

            "createdAt":
                Timestamp.now(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text(
                "Cadastro realizado com sucesso!",
              ),
            ),
          );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      String mensagem =
          "Erro ao cadastrar";

      if (e.code ==
          'email-already-in-use') {

        mensagem =
            "Email já está em uso";

      } else if (e.code ==
          'invalid-email') {

        mensagem =
            "Email inválido";

      } else if (e.code ==
          'weak-password') {

        mensagem =
            "Senha muito fraca";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text(mensagem),
            ),
          );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text(
                "Erro inesperado",
              ),
            ),
          );

    } finally {

      if (mounted) {
        setState(() => carregando = false);
      }
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
        height: double.infinity,

        decoration: BoxDecoration(

          // 🪵 FUNDO PREMIUM AMADEIRADO
          gradient: LinearGradient(

            colors: isDark
                ? [

                    // 🌑 DARK
                    const Color(0xFF111111),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF222222),
                    const Color(0xFF2C2C2C),

                  ]
                : [

                    // 🪵 VERMELHO AMADEIRADO
                    const Color(0xFF3E0F12),
                    const Color(0xFF5A171B),
                    const Color(0xFF7A2323),
                    const Color(0xFFA63A3A),

                  ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(

          child: SingleChildScrollView(

            physics:
                const BouncingScrollPhysics(),

            padding:
                const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 30,
                ),

            child: Column(

              children: [

                const SizedBox(height: 10),

                // 🔥 LOGO
                Container(

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    boxShadow: [

                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.35),

                        blurRadius: 25,

                        offset:
                            const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: ClipOval(

                    child: Image.asset(
                      "assets/images/logo.png",

                      width: 140,
                      height: 140,

                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 🔥 TÍTULO
                const Text(

                  "Crie sua conta",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(

                  "Cadastre-se e peça seus lanches favoritos",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    color:
                        Colors.white.withValues(alpha: 0.78),

                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                // 🔥 NOME
                campoInput(
                  controller: nomeController,
                  hint: "Nome completo",
                  icon: Icons.person,
                  isDark: isDark,
                ),

                const SizedBox(height: 18),

                // 🔥 EMAIL
                campoInput(
                  controller: emailController,
                  hint: "E-mail",
                  icon: Icons.email,
                  isDark: isDark,
                ),

                const SizedBox(height: 18),

                // 🔥 TELEFONE
                campoInput(
                  controller: telefoneController,
                  hint: "Telefone",
                  icon: Icons.phone,
                  isDark: isDark,
                ),

                const SizedBox(height: 18),

                // 🔥 SENHA
                campoInput(
                  controller: senhaController,
                  hint: "Senha",
                  icon: Icons.lock,
                  obscure: true,
                  isDark: isDark,
                ),

                const SizedBox(height: 18),

                // 🔥 CONFIRMAR SENHA
                campoInput(
                  controller:
                      confirmarSenhaController,

                  hint: "Confirmar senha",

                  icon: Icons.lock_outline,

                  obscure: true,

                  isDark: isDark,
                ),

                const SizedBox(height: 30),

                // 🔥 BOTÃO
                SizedBox(

                  width: double.infinity,
                  height: 60,

                  child: ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                          elevation: 0,

                          backgroundColor:
                              const Color(
                                0xFFD4A017,
                              ),

                          shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                      18,
                                    ),
                              ),
                        ),

                    onPressed:
                        carregando
                            ? null
                            : cadastrar,

                    child:
                        carregando

                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )

                            : const Text(

                                "Cadastrar",

                                style: TextStyle(

                                  fontSize: 20,

                                  fontWeight:
                                      FontWeight.bold,

                                  color: Colors.white,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 VOLTAR LOGIN
                GestureDetector(

                  onTap: () {
                    Navigator.pop(context);
                  },

                  child: Text(

                    "Já possui conta? ENTRAR",

                    style: TextStyle(

                      color:
                          Colors.white.withValues(alpha: 0.92),

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 CAMPO PERSONALIZADO
// 🔥 CAMPO ESTILO LOGIN
Widget campoInput({

  required TextEditingController controller,

  required String hint,

  required IconData icon,

  required bool isDark,

  bool obscure = false,

}) {

  return TextField(

    controller: controller,

    obscureText: obscure,

    style: TextStyle(
      color:
          isDark
              ? Colors.white
              : Colors.white,
    ),

    decoration: InputDecoration(

      hintText: hint,

      hintStyle: TextStyle(
        color:
            Colors.white.withValues(alpha: 0.60),
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(
          0xFFFFD166,
        ),
      ),

      filled: true,

      fillColor:
          isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.12),

      contentPadding:
          const EdgeInsets.symmetric(
            vertical: 20,
          ),

      border: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
              18,
            ),

        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
              18,
            ),

        borderSide: BorderSide(

          color:
              Colors.white.withValues(alpha: 0.08),
        ),
      ),

      focusedBorder: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
              18,
            ),

        borderSide: const BorderSide(

          color: Color(
            0xFFFFD166,
          ),

          width: 1.5,
        ),
      ),
    ),
  );
}
}
