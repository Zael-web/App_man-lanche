import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mana_lanche/screens/login_screens.dart';
import 'package:mana_lanche/screens/pedidos_admin_screens.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

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

  // 🔥 EXCLUIR PRODUTO
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


// 🔥 EDITAR PRODUTO PREMIUM
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
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7),
            ),

            boxShadow: [

              BoxShadow(

                color: Colors.black.withOpacity(0.25),

                blurRadius: 30,

                offset: const Offset(0, 15),
              ),
            ],
          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              // 🔥 ÍCONE
              Container(

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: const Color(0xFF8B0000)
                      .withOpacity(0.12),

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

                "Atualize as informações do produto",

                style: TextStyle(

                  color: isDark
                      ? Colors.white60
                      : Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 CAMPO NOME
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
                      ? Colors.white.withOpacity(0.05)
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
                          .withOpacity(0.08),
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

              const SizedBox(height: 18),

              // 🔥 CAMPO PREÇO
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

                    Icons.attach_money_rounded,

                    color: Color(0xFFD2691E),
                  ),

                  filled: true,

                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
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
                          .withOpacity(0.08),
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

              // 🔥 BOTÕES
              Row(

                children: [

                  // CANCELAR
                  Expanded(

                    child: OutlinedButton(

                      style:
                          OutlinedButton.styleFrom(

                        side: BorderSide(

                          color: isDark
                              ? Colors.white24
                              : Colors.black12,
                        ),

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 18,
                        ),

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(
                                18,
                              ),
                        ),
                      ),

                      onPressed: () {

                        Navigator.pop(context);
                      },

                      child: Text(

                        "Cancelar",

                        style: TextStyle(

                          color: isDark
                              ? Colors.white70
                              : Colors.black87,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // SALVAR
                  Expanded(

                    child: ElevatedButton(

                      style:
                          ElevatedButton.styleFrom(

                        elevation: 0,

                        backgroundColor:
                            const Color(
                              0xFF8B0000,
                            ),

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 18,
                        ),

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(
                                18,
                              ),
                        ),
                      ),

                      onPressed: () async {

                        final preco =
                            double.parse(

                          precoEditController.text
                              .replaceAll(",", "."),
                        );

                        await FirebaseFirestore
                            .instance
                            .collection("produtos")
                            .doc(id)
                            .update({

                          "nome":
                              nomeEditController.text
                                  .trim(),

                          "preco": preco,
                        });

                        if (!mounted) return;

                        Navigator.pop(context);

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(

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

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 16,
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

  // 🔥 LOGOUT
  Future<void> logout() async {

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
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

          "ADMIN • MANÁ LANCHES",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          // 🔥 PEDIDOS
          IconButton(

            icon: const Icon(
              Icons.receipt_long,
              color: Colors.white,
            ),

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (_) =>
                      const PedidosAdminScreen(),
                ),
              );
            },
          ),

          // 🔥 SAIR
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

        decoration: BoxDecoration(

          // 🪵 FUNDO AMADEIRADO
          gradient: LinearGradient(

            colors: isDark
                ? [

                    const Color(0xFF111111),
                    const Color(0xFF1B1B1B),
                    const Color(0xFF252525),

                  ]
                : [

                    const Color(0xFF5C1A1B),
                    const Color(0xFF7A2323),
                    const Color(0xFF9B2C2C),
                    const Color(0xFFB33939),

                  ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(

          child: Padding(

            padding: const EdgeInsets.all(18),

            child: Column(

              children: [

                const SizedBox(height: 10),

                // 🔥 FORMULÁRIO
                Container(

                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(

                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        
                        : Colors.white.withOpacity(0.92),

                    borderRadius:
                        BorderRadius.circular(28),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black12,

                        blurRadius: 18,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(

                    children: [

                      // 🔥 NOME
                      TextField(

  controller: nomeController,

  style: TextStyle(
    color: isDark
        ? Colors.white
        : Colors.black,
  ),

  decoration: InputDecoration(

    hintText: "Nome do produto",

    
    prefixIcon: const Icon(
      Icons.fastfood,
      color: Color(0xFF8B0000),
    ),

    filled: true,

    fillColor: isDark
        // ignore: deprecated_member_use
        ? Colors.white.withOpacity(0.06)
        // ignore: deprecated_member_use
        : Colors.white.withOpacity(0.96),

    contentPadding:
        const EdgeInsets.symmetric(
      vertical: 18,
      horizontal: 18,
    ),

    border: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(20),

      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(20),

      borderSide: BorderSide(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.08),
      ),
    ),

    focusedBorder: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(20),

      borderSide: const BorderSide(
        color: Color(0xFFD2691E),
        width: 2,
      ),
    ),
  ),
),

                      // 🔥 PREÇO
                      TextField(

  controller: precoController,

  keyboardType: TextInputType.number,

  style: TextStyle(
    color: isDark
        ? Colors.white
        : Colors.black,
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
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.96),

    contentPadding:
        const EdgeInsets.symmetric(
      vertical: 18,
      horizontal: 18,
    ),

    border: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(20),

      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(20),

      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.08),
      ),
    ),

    focusedBorder: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(20),

      borderSide: const BorderSide(
        color: Color(0xFFD2691E),
        width: 2,
      ),
    ),
  ),
),

                      const SizedBox(height: 22),

                      // 🔥 BOTÃO
                      SizedBox(

                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton(

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                const Color(0xFF8B0000),

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius.circular(
                                    18,
                                  ),
                            ),
                          ),

                          onPressed:
                              adicionarProduto,

                          child: const Text(

                            "Adicionar Produto",

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

                const SizedBox(height: 25),

                // 🔥 LISTA DE PRODUTOS
Expanded(
  child: StreamBuilder<QuerySnapshot>(
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

        return const Center(
          child: Text(
            "Nenhum produto encontrado",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(

        padding: const EdgeInsets.only(
          bottom: 20,
        ),

        itemCount:
            snapshot.data!.docs.length,

        itemBuilder: (context, index) {

          final doc =
              snapshot.data!.docs[index];

          final data =
              doc.data()
                  as Map<String, dynamic>;

          return Container(

            margin: const EdgeInsets.only(
              bottom: 14,
            ),

            padding:
                const EdgeInsets.all(14),

            decoration: BoxDecoration(

  color: isDark
      ? Colors.white.withOpacity(0.05)
      : Colors.white.withOpacity(0.18),

  borderRadius:
      BorderRadius.circular(24),

  border: Border.all(

    color: Colors.white.withOpacity(0.15),

    width: 1.2,
  ),

  boxShadow: [

    BoxShadow(

      color: Colors.black.withOpacity(0.10),

      blurRadius: 14,

      offset: const Offset(0, 6)
    ),
  ],
),

            child: Row(

              children: [

                // 🔥 ÍCONE
                Container(

                  width: 60,
                  height: 60,

                  decoration: BoxDecoration(

                    gradient:
                        const LinearGradient(

                      colors: [

                        Color(0xFF8B0000),
                        Color(0xFFB22222),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),

                  child: const Icon(

                    Icons.fastfood_rounded,

                    color: Colors.white,

                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                // 🔥 INFO
                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        data["nome"],

                        style: TextStyle(

                          color: isDark
                              ? Colors.white
                              : Colors.black87,

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(

                        padding:
                            const EdgeInsets.symmetric(

                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(

                          color: const Color(
                            0xFFD2691E,
                          ).withOpacity(0.12),

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: Text(

                          "R\$ ${data["preco"]}",

                          style: const TextStyle(

                            color:
                                Color(0xFFD2691E),

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔥 AÇÕES
                Column(

                  children: [

                    // EDITAR
                    Container(

                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(

                        color: Colors.orange
                            .withOpacity(0.12),

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),

                      child: IconButton(

                        icon: const Icon(

                          Icons.edit_rounded,

                          color: Colors.orange,

                          size: 22,
                        ),

                        onPressed: () {

                          editarProduto(

                            doc.id,

                            data["nome"],

                            data["preco"]
                                .toString(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // EXCLUIR
                    Container(

                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(

                        color: Colors.red
                            .withOpacity(0.12),

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),

                      child: IconButton(

                        icon: const Icon(

                          Icons.delete_rounded,

                          color: Colors.red,

                          size: 22,
                        ),

                        onPressed: () {

                          excluirProduto(
                            doc.id,
                          );
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
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
                  
             