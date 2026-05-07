import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mana_lanche/screens/login_screens.dart';
import 'package:mana_lanche/screens/carrinho_screens.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {

  String nomeCliente = "";
  bool carregando = true;

  // 🛒 CARRINHO
  List<Map<String, dynamic>> carrinho = [];

  @override
  void initState() {
    super.initState();
    carregarNome();
  }

  Future<void> carregarNome() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(user.uid)
            .get();

    if (!mounted) return;

    setState(() {

      nomeCliente =
          doc.exists
              ? doc["nome"] ?? "Cliente"
              : "Cliente";

      carregando = false;
    });
  }

  // 🛒 ADICIONAR AO CARRINHO
  void adicionarAoCarrinho(
    String nome,
    dynamic preco,
  ) {

    setState(() {

      final index =
          carrinho.indexWhere(
            (item) =>
                item["nomeProduto"] == nome,
          );

      if (index >= 0) {

        carrinho[index]["quantidade"]++;

      } else {

        carrinho.add({

          "nomeProduto": nome,
          "preco": preco,
          "quantidade": 1,
        });
      }
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Adicionado ao carrinho 🛒",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),

          onPressed: () {

            Navigator.pushReplacement(
              context,

              MaterialPageRoute(
                builder:
                    (_) =>
                        const LoginScreen(),
              ),
            );
          },
        ),

        title: const Text(
          "MANÁ LANCHES",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [

          Stack(

            children: [

              IconButton(

                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:
                          (_) =>
                              CarrinhoScreen(

                                carrinho:
                                    carrinho,

                                nomeCliente:
                                    nomeCliente,
                              ),
                    ),
                  );
                },
              ),

              if (carrinho.isNotEmpty)

                Positioned(

                  right: 5,
                  top: 5,

                  child: Container(

                    padding:
                        const EdgeInsets.all(5),

                    decoration: BoxDecoration(

                      color: Colors.red,

                      borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                    ),

                    child: Text(

                      carrinho.length
                          .toString(),

                      style: const TextStyle(

                        color: Colors.white,

                        fontSize: 12,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      extendBodyBehindAppBar: true,

      body: Container(

        width: double.infinity,

        decoration: BoxDecoration(

          // 🪵 FUNDO AMADEIRADO
          gradient: LinearGradient(

            colors: isDark
                ? [

                    // 🌑 DARK MODE
                    const Color(
                      0xFF111111,
                    ),

                    const Color(
                      0xFF1B1B1B,
                    ),

                    const Color(
                      0xFF252525,
                    ),

                  ]
                : [

                    // 🪵 VERMELHO AMADEIRADO
                    const Color(
                      0xFF5C1A1B,
                    ),

                    const Color(
                      0xFF7A2323,
                    ),

                    const Color(
                      0xFF9B2C2C,
                    ),

                    const Color(
                      0xFFB33939,
                    ),
                  ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(

          child: Padding(

            padding:
                const EdgeInsets.all(18),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(
                  height: 10,
                ),

                // 👋 NOME
                Text(

                  carregando
                      ? "Carregando..."
                      : "Olá, $nomeCliente 👋",

                  style: const TextStyle(

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(

                  "Escolha seu lanche favorito",

                  style: TextStyle(

                    color: Colors.white70,

                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // 🍔 BANNER PREMIUM
                Container(

                  height: 170,
                  width: double.infinity,

                  decoration: BoxDecoration(

                    borderRadius:
                        BorderRadius.circular(
                          28,
                        ),

                    gradient: LinearGradient(

                      colors: isDark
                          ? [

                              const Color(
                                0xFF2B2B2B,
                              ),

                              const Color(
                                0xFF1E1E1E,
                              ),
                            ]
                          : [

                              const Color(
                                0xFF6D1F1F,
                              ),

                              const Color(
                                0xFF9B2C2C,
                              ),
                            ],

                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    boxShadow: [

                      BoxShadow(

                        color:
                            Colors.black26,

                        blurRadius: 20,

                        offset:
                            const Offset(
                              0,
                              10,
                            ),
                      ),
                    ],
                  ),

                  child: Padding(

                    padding:
                        const EdgeInsets.all(
                          22,
                        ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: const [

                        Text(
                          "🍔 Promoção Especial",

                          style: TextStyle(

                            color:
                                Colors.white,

                            fontSize: 28,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        Text(

                          "Os melhores lanches com sabor artesanal.",

                          style: TextStyle(

                            color:
                                Colors.white70,

                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                const Text(

                  "Mais pedidos",

                  style: TextStyle(

                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // 🔥 LISTA
                Expanded(

                  child:
                      StreamBuilder<QuerySnapshot>(

                    stream:
                        FirebaseFirestore.instance
                            .collection(
                              "produtos",
                            )
                            .orderBy("nome")
                            .snapshots(),

                    builder:
                        (context, snapshot) {

                      if (snapshot
                              .connectionState ==
                          ConnectionState
                              .waiting) {

                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot
                              .hasData ||
                          snapshot.data!.docs
                              .isEmpty) {

                        return const Center(

                          child: Text(

                            "Nenhum produto encontrado",

                            style: TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                        );
                      }

                      return ListView(

                        children:
                            snapshot.data!.docs.map(
                          (doc) {

                            final data =
                                doc.data()
                                    as Map<String,
                                        dynamic>;

                            return foodItem(

                              data["nome"] ??
                                  "",

                              data["preco"] ??
                                  0,
                            );
                          },
                        ).toList(),
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

  // 🍔 CARD PRODUTO
  Widget foodItem(
    String nome,
    dynamic preco,
  ) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(

      margin:
          const EdgeInsets.only(
            bottom: 16,
          ),

      decoration: BoxDecoration(

        color: isDark
    ? const Color(0xFF232323)
    : const Color(0xFFFFFBF7),

        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(

            color: Colors.black12,

            blurRadius: 15,

            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),

      child: ListTile(

        contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),

        leading: CircleAvatar(

          radius: 28,

          backgroundColor:
              const Color(
                0xFF7A2323,
              ),

          child: const Icon(
            Icons.fastfood,
            color: Colors.white,
          ),
        ),

        title: Text(

          nome,

          style: TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 18,

            color: isDark
                ? Colors.white
                : Colors.black87,
          ),
        ),

        subtitle: Padding(

          padding:
              const EdgeInsets.only(
                top: 6,
              ),

          child: Text(

            "R\$ ${preco.toString()}",

            style: const TextStyle(

              color: Color(
                0xFF7A2323,
              ),

              fontWeight:
                  FontWeight.bold,

              fontSize: 16,
            ),
          ),
        ),

        trailing: ElevatedButton(

          style:
              ElevatedButton.styleFrom(

            backgroundColor:
           const Color(0xFF8B0000),
            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
          ),

          onPressed: () {

            adicionarAoCarrinho(
              nome,
              preco,
            );
          },

          child: const Text(

            "Pedir",

            style: TextStyle(

              color: Colors.white,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}