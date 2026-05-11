import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mana_lanche/screens/login_screens.dart';

class ProdutosAdminScreen extends StatefulWidget {
  const ProdutosAdminScreen({super.key});

  @override
  State<ProdutosAdminScreen> createState() => _ProdutosAdminScreenState();
}

class _ProdutosAdminScreenState extends State<ProdutosAdminScreen> {

  final nomeController = TextEditingController();
  final precoController = TextEditingController();

  // 🔥 ADICIONAR PRODUTO
  Future<void> adicionarProduto() async {

    try {

      if (nomeController.text.trim().isEmpty ||
          precoController.text.trim().isEmpty) {
        return;
      }

      final preco = double.parse(
        precoController.text.replaceAll(",", "."),
      );

      await FirebaseFirestore.instance
          .collection("produtos")
          .add({

        "nome": nomeController.text.trim(),
        "preco": preco,

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Produto adicionado!"),
        ),
      );

      nomeController.clear();
      precoController.clear();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Erro ao adicionar produto"),
        ),
      );
    }
  }

  // EXCLUIR PRODUTO
  Future<void> excluirProduto(String id) async {

    await FirebaseFirestore.instance
        .collection("produtos")
        .doc(id)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Produto removido"),
      ),
    );
  }


  //EDITAR PRODUTO PREMIUM
Future<void> editarProduto(
  String id,
  String nomeAtual,
  String precoAtual,
) async {

  final nomeEditController =
      TextEditingController(text: nomeAtual);

  final precoEditController =
      TextEditingController(text: precoAtual);

  final isDark =
      Theme.of(context).brightness ==
          Brightness.dark;

  showDialog(

    context: context,

    barrierColor: Colors.black54,

    builder: (_) {

      return Dialog(

        backgroundColor: const Color.fromARGB(0, 221, 4, 4),
        insetPadding: const EdgeInsets.all(20),

        child: Container(

          padding: const EdgeInsets.all(28),

          decoration: BoxDecoration(

            gradient: LinearGradient(

              colors: isDark
                  ? [

                      const Color(0xFF1A1A1A),
                      const Color(0xFF232323),
                      const Color(0xFF2B2B2B),

                    ]
                  : [

                      const Color(0xFFFFFBF7),
                      const Color(0xFFF8EFEA),
                      const Color(0xFFF3E4DE),

                    ],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius:
                BorderRadius.circular(32),

            border: Border.all(

              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
            ),

            boxShadow: [

              BoxShadow(

                color: Colors.black.withValues(alpha: 0.25),

                blurRadius: 30,

                offset: const Offset(0, 15),
              ),
            ],
          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              // iCONE
              Container(

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: const Color(0xFF8B0000)
                      .withValues(alpha: 0.12),

                  borderRadius:
                      BorderRadius.circular(22),
                ),

                child: const Icon(

                  Icons.edit_rounded,

                  color: Color(0xFF8B0000),

                  size: 34,
                ),
              ),

              const SizedBox(height: 18),

              // 🔥 TÍTULO
              Text(

                "Editar Produto",

                style: TextStyle(

                  color: isDark
                      ? Colors.white
                      : Colors.black87,

                  fontSize: 24,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(

                "Atualize as informaçoes do produto",

                style: TextStyle(

                  color: isDark
                      ? Colors.white60
                      : Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // CAMPO NOME
              TextField(

                controller: nomeEditController,

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),

                decoration: InputDecoration(

                  hintText: "Nome do produto",

                  hintStyle: TextStyle(

                    color: isDark
                        ? Colors.white38
                        : Colors.grey.shade600,
                  ),

                  prefixIcon: const Icon(

                    Icons.fastfood_rounded,

                    color: Color(0xFF8B0000),
                  ),

                  filled: true,

                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,

                  contentPadding:
                      const EdgeInsets.symmetric(

                    vertical: 20,
                    horizontal: 18,
                  ),

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(22),

                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(22),

                    borderSide: BorderSide(

                      color: Colors.white
                          .withValues(alpha: 0.08),
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(22),

                    borderSide: const BorderSide(

                      color: Color(0xFFD2691E),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CAMPO PREÇO
              TextField(

                controller: precoEditController,

                keyboardType:
                    TextInputType.number,

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),

                decoration: InputDecoration(

                  hintText: "Preço",

                  hintStyle: TextStyle(

                    color: isDark
                        ? Colors.white38
                        : Colors.grey.shade600,
                  ),

                  prefixIcon: const Icon(

                    Icons.attach_money,

                    color: Color(0xFFD2691E),
                  ),

                  filled: true,

                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,

                  contentPadding:
                      const EdgeInsets.symmetric(

                    vertical: 20,
                    horizontal: 18,
                  ),

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(22),

                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(22),

                    borderSide: BorderSide(

                      color: Colors.white
                          .withValues(alpha: 0.08),
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(22),

                    borderSide: const BorderSide(

                      color: Color(0xFFD2691E),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // BOTÕES
              Row(

                children: [

                  Expanded(

                    child: SizedBox(

                      height: 50,

                      child: OutlinedButton(

                        onPressed: () {

                          Navigator.pop(context);
                        },

                        style:
                            OutlinedButton.styleFrom(

                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius
                                    .circular(16),
                          ),
                        ),

                        child: Text(

                          "Cancelar",

                          style: TextStyle(

                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: SizedBox(

                      height: 50,

                      child: ElevatedButton(

                        style:
                            ElevatedButton
                                .styleFrom(

                          backgroundColor:
                              const Color(
                                  0xFFD2691E),

                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius
                                    .circular(16),
                          ),
                        ),

                        onPressed: () async {

                          final novoNome =
                              nomeEditController
                                  .text;

                          final novoPreco = double
                              .parse(
                            precoEditController
                                .text
                                .replaceAll(
                                    ",", "."),
                          );

                          await FirebaseFirestore
                              .instance
                              .collection(
                                  "produtos")
                              .doc(id)
                              .update({
                            "nome": novoNome,
                            "preco": novoPreco,
                          });

                          if (!mounted) return;

                          Navigator.pop(
                              context);

                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(

                            const SnackBar(

                              content: Text(
                                "Produto atualizado!",
                              ),
                            ),
                          );
                        },

                        child: const Text(

                          "Salvar",

                          style: TextStyle(

                            color: Colors.white,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // LOGOUT
  Future<void> logout() async {

    try {

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(

        MaterialPageRoute(

          builder: (_) => const LoginScreen(),
        ),

        (route) => false,
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("Erro ao fazer logout"),
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

      extendBodyBehindAppBar: true,

      appBar: AppBar(

        backgroundColor: Colors.transparent,
        elevation: 0,

        centerTitle: true,

        title: const Text(

          "PRODUTOS",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        actions: [

          // SAIR
          IconButton(

            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),

            onPressed: logout,
          ),
        ],
      ),

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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
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
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
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

                

                const SizedBox(height: 8),

                Text(
                  "Cadastre novos produtos e gerencie o estoque", 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: nomeController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Nome do produto",
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.54)
                                : Colors.grey.shade600,
                          ),
                          prefixIcon: const Icon(
                            Icons.fastfood,
                            color: Color(0xFF8B0000),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.96),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFD2691E),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: precoController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Preço",
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade600,
                          ),
                          prefixIcon: const Icon(
                            Icons.attach_money,
                            color: Color(0xFFD2691E),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.96),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFD2691E),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFD4A017),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: adicionarProduto,
                          child: const Text(
                            "Adicionar Produto",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Produtos cadastrados",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("produtos")
                      .orderBy("nome")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Nenhum produto encontrado",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF000000).withValues(alpha: 0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8B0000),
                                      Color(0xFFB22222),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.fastfood_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data["nome"],
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 255, 255, 255)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "R\$ ${data["preco"]}",
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 202, 202, 202),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Color.fromARGB(255, 255, 153, 0),
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        editarProduto(
                                          doc.id,
                                          data["nome"],
                                          data["preco"].toString(),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        excluirProduto(doc.id);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
