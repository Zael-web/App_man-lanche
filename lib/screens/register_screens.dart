import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;
Future<void> cadastrar() async {
  if (senhaController.text != confirmarSenhaController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("As senhas não coincidem")),
    );
    return;
  }

  if (senhaController.text.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Senha deve ter no mínimo 6 caracteres")),
    );
    return;
  }

  try {
    setState(() => carregando = true);

    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: senhaController.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(userCredential.user!.uid)
        .set({
      "nome": nomeController.text.trim(),
      "email": emailController.text.trim(),
      "telefone": telefoneController.text.trim(),
      "tipo": "cliente", // 🔥 IMPORTANTE
      "createdAt": Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cadastro realizado com sucesso!")),
    );

    Navigator.pop(context);

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro inesperado")),
    );
  } finally {
    if (mounted) {
      setState(() => carregando = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : const Color(0xFFB23A3A),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // LOGO
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      // NOME
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          hintText: "Nome completo",
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // EMAIL
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "E-mail",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // TELEFONE
                      TextField(
                        controller: telefoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Telefone",
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // SENHA
                      TextField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Senha",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // CONFIRMAR SENHA
                      TextField(
                        controller: confirmarSenhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Confirmar senha",
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // BOTÃO
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: carregando ? null : cadastrar,
                          child: carregando
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Cadastrar",
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Já tem conta? ENTRAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
}