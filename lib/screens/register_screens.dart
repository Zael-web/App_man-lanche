// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mana_lanche/screens/client_screens.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final nomeController = TextEditingController();

  final emailController = TextEditingController();

  final telefoneController = TextEditingController();

  final enderecoController = TextEditingController();

  final senhaController = TextEditingController();
  
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;

  bool obscureSenha = true;
  bool obscureConfirmarSenha = true;
  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  late AnimationController eyeController;
  late Animation<double> eyeAnimation;

  @override
  void initState() {
    super.initState();

    eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    eyeAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: eyeController, curve: Curves.easeInOut));
  }

  Future<void> cadastrar() async {
    if (senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem")));
      return;
    }

    if (senhaController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Senha deve ter no mínimo 6 caracteres")),
      );
      return;
    }

    if (nomeController.text.isEmpty ||
        emailController.text.isEmpty ||
        telefoneController.text.isEmpty ||
        enderecoController.text.isEmpty ||
        senhaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha todos os campos")));
      return;
    }

    try {
      setState(() => carregando = true);

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: senhaController.text.trim(),
          );

      await userCredential.user!.updateDisplayName(nomeController.text.trim());

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .set({
            "uid": userCredential.user!.uid,
            "nome": nomeController.text.trim(),
            "email": emailController.text.trim(),
            "telefone": telefoneController.text.trim(),
            "endereco": enderecoController.text.trim(),
            "tipo": "cliente",
            "createdAt": Timestamp.now(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = "Erro ao cadastrar";

      if (e.code == 'email-already-in-use') {
        mensagem = "Email já está em uso";
      } else if (e.code == 'invalid-email') {
        mensagem = "Email inválido";
      } else if (e.code == 'weak-password') {
        mensagem = "Senha muito fraca";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    eyeController.dispose();

    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();

    super.dispose();
  }

  Widget campoInput(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isDark, {
    bool obscure = false,
    bool showToggle = false,
    VoidCallback? toggleObscure,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD166)),

        suffixIcon: showToggle
            ? ScaleTransition(
                scale: eyeAnimation,
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      key: ValueKey<bool>(obscure),
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                  onPressed: () {
                    toggleObscure?.call();

                    if (eyeController.status == AnimationStatus.completed) {
                      eyeController.reverse();
                    } else {
                      eyeController.forward();
                    }
                  },
                ),
              )
            : null,

        filled: true,
        fillColor: isDark
            ? const Color(0xFF1B1B1B)
            : Colors.white.withValues(alpha: 0.12),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFFD166), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF111111),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF222222),
                    const Color(0xFF2C2C2C),
                  ]
                : [
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Crie sua conta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                campoInput(
                  nomeController,
                  "Nome completo",
                  Icons.person,
                  isDark,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 18),

                campoInput(
                  emailController,
                  "E-mail",
                  Icons.email,
                  isDark,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 18),

                campoInput(
                  telefoneController,
                  "Telefone",
                  Icons.phone,
                  isDark,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    telefoneMask, // 👈 aqui está a máscara
                  ],
                ),

                const SizedBox(height: 18),

                campoInput(
                  enderecoController,
                  "Endereço",
                  Icons.location_on,
                  isDark,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 18),

                campoInput(
                  senhaController,
                  "Senha",
                  Icons.lock,
                  isDark,
                  obscure: obscureSenha,
                  showToggle: true,
                  toggleObscure: () {
                    setState(() => obscureSenha = !obscureSenha);
                  },
                ),

                const SizedBox(height: 18),

                campoInput(
                  confirmarSenhaController,
                  "Confirmar senha",
                  Icons.lock_outline,
                  isDark,
                  obscure: obscureConfirmarSenha,
                  showToggle: true,
                  toggleObscure: () {
                    setState(
                      () => obscureConfirmarSenha = !obscureConfirmarSenha,
                    );
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: carregando ? null : cadastrar,
                    child: carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Cadastrar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Já possui conta? ",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          "ENTRAR",
                          style: TextStyle(
                            color: Color(0xFFFFD166),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
