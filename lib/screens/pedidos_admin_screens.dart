import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() =>
      _PedidosAdminScreenState();
}

class _PedidosAdminScreenState
    extends State<PedidosAdminScreen> {

  // 🔥 ALTERAR STATUS
  Future<void> atualizarStatus(
    String id,
    String status,
  ) async {

    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(id)
        .update({
      "status": status,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        backgroundColor: Colors.green,

        content: Text(
          "Pedido atualizado para $status",
        ),
      ),
    );
  }

  // 🔥 COR STATUS
  Color corStatus(String status) {

    switch (status) {

      case "Preparando":
        return Colors.orange;

      case "Saiu entrega":
        return Colors.blue;

      case "Entregue":
        return Colors.green;

      default:
        return Colors.grey;
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

          "PEDIDOS",

          style: TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,

            letterSpacing: 1,
          ),
        ),
      ),

      body: Container(

        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: isDark
                ? [

                    const Color(0xFF111111),
                    const Color(0xFF1B1B1B),
                    const Color(0xFF252525),

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

          child: StreamBuilder<QuerySnapshot>(

            stream: FirebaseFirestore.instance
                .collection("pedidos")
                .orderBy(
                  "data",
                  descending: true,
                )
                .snapshots(),

            builder: (context, snapshot) {

              // 🔥 LOADING
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {

                return const Center(

                  child:
                      CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              // 🔥 SEM PEDIDOS
              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {

                return const Center(

                  child: Text(

                    "Nenhum pedido encontrado",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                );
              }

              return ListView.builder(

                padding:
                    const EdgeInsets.all(18),

                itemCount:
                    snapshot.data!.docs.length,

                itemBuilder: (context, index) {

                  final doc =
                      snapshot.data!.docs[index];

                  final data =
                      doc.data()
                          as Map<String, dynamic>;

                  final itens =
                      data["itens"] as List;

                  double total = 0;

                  for (var item in itens) {

                    total +=
                        (item["preco"] ?? 0) *
                        (item["quantidade"] ?? 1);
                  }

                  return Container(

                    margin:
                        const EdgeInsets.only(
                      bottom: 22,
                    ),

                    padding:
                        const EdgeInsets.all(20),

                    decoration: BoxDecoration(

                      color: isDark
                          ? Colors.white
                              .withValues(alpha: 0.05)
                          : Colors.white
                              .withValues(alpha: 0.12),

                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),

                      border: Border.all(

                        color: Colors.white
                            .withValues(alpha: 0.08),
                      ),

                      boxShadow: [

                        BoxShadow(

                          color: Colors.black
                              .withValues(alpha: 0.18),

                          blurRadius: 20,

                          offset:
                              const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // 🔥 TOPO CLIENTE
                        Row(

                          children: [

                            Container(

                              width: 60,
                              height: 60,

                              decoration:
                                  BoxDecoration(

                                gradient:
                                    const LinearGradient(

                                  colors: [

                                    Color(0xFFD2691E),
                                    Color(0xFFFF9800),

                                  ],
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),

                              child: const Icon(

                                Icons.person,

                                color: Colors.white,

                                size: 30,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    data["nomeCliente"] ??
                                        "Cliente",

                                    style:
                                        const TextStyle(

                                      color:
                                          Colors.white,

                                      fontSize: 20,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Text(

                                    "${itens.length} item(ns)",

                                    style:
                                        const TextStyle(

                                      color:
                                          Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🔥 STATUS
                            Container(

                              padding:
                                  const EdgeInsets.symmetric(

                                horizontal: 14,
                                vertical: 8,
                              ),

                              decoration:
                                  BoxDecoration(

                                color: corStatus(
                                  data["status"],
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),

                              child: Text(

                                data["status"],

                                style:
                                    const TextStyle(

                                  color: Colors.white,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // 🔥 LISTA PRODUTOS
                        ...List.generate(

                          itens.length,

                          (i) {

                            final item =
                                itens[i];

                            final imagem = (item["imagem"] ?? "").toString();

                            return Container(

                              margin:
                                  const EdgeInsets.only(
                                bottom: 15,
                              ),

                              padding:
                                  const EdgeInsets.all(
                                14,
                              ),

                              decoration:
                                  BoxDecoration(

                                color: Colors.black
                                    .withValues(
                                        alpha: 0.12),

                                borderRadius:
                                    BorderRadius.circular(
                                  22,
                                ),
                              ),

                              child: Row(

                                children: [

                                  // 🔥 IMAGEM
                                  ClipRRect(

                                    borderRadius:
                                        BorderRadius.circular(
                                      18,
                                    ),

                                    child:
                                        imagem.isNotEmpty

                                            ? Image.network(

                                                imagem,

                                                width: 85,
                                                height: 85,

                                                fit: BoxFit.cover,

                                                errorBuilder:
                                                    (_, __, ___) {

                                                  return Container(

                                                    width: 85,
                                                    height: 85,

                                                    color:
                                                        Colors.grey,

                                                    child:
                                                        const Icon(

                                                      Icons.fastfood,

                                                      color:
                                                          Colors.white,
                                                    ),
                                                  );
                                                },
                                              )

                                            : Container(

                                                width: 85,
                                                height: 85,

                                                color: Colors.grey,

                                                child:
                                                    const Icon(

                                                  Icons.fastfood,

                                                  color:
                                                      Colors.white,
                                                ),
                                              ),
                                  ),

                                  const SizedBox(
                                      width: 16),

                                  // 🔥 INFO PRODUTO
                                  Expanded(

                                    child: Column(

                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [

                                        Text(

                                          item["nomeProduto"],

                                          style:
                                              const TextStyle(

                                            color:
                                                Colors.white,

                                            fontSize:
                                                18,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 8),

                                        Text(

                                          "Quantidade: ${item["quantidade"]}",

                                          style:
                                              const TextStyle(

                                            color:
                                                Colors.white70,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 6),

                                        Text(

                                          "Preço: R\$ ${item["preco"]}",

                                          style:
                                              const TextStyle(

                                            color: Color(
                                                0xFFFFD54F),

                                            fontWeight:
                                                FontWeight.bold,

                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // 🔥 TOTAL
                        Align(

                          alignment:
                              Alignment.centerRight,

                          child: Container(

                            padding:
                                const EdgeInsets.symmetric(

                              horizontal: 18,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(

                              color: const Color(
                                0xFFD4A017,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),

                            child: Text(

                              "Total: R\$ ${total.toStringAsFixed(2)}",

                              style:
                                  const TextStyle(

                                color: Colors.white,

                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // 🔥 BOTÕES STATUS
                        Wrap(

                          spacing: 10,
                          runSpacing: 10,

                          children: [

                            statusButton(
                              doc.id,
                              "Preparando",
                              Colors.orange,
                            ),

                            statusButton(
                              doc.id,
                              "Saiu entrega",
                              Colors.blue,
                            ),

                            statusButton(
                              doc.id,
                              "Entregue",
                              Colors.green,
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
      ),
    );
  }

  // 🔥 BOTÃO STATUS
  Widget statusButton(
    String id,
    String status,
    Color cor,
  ) {

    return ElevatedButton(

      style: ElevatedButton.styleFrom(

        backgroundColor: cor,

        elevation: 5,

        padding:
            const EdgeInsets.symmetric(

          horizontal: 18,
          vertical: 14,
        ),

        shape: RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(16),
        ),
      ),

      onPressed: () {

        atualizarStatus(id, status);
      },

      child: Text(

        status,

        style: const TextStyle(

          color: Colors.white,

          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}