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
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Pedidos dos Clientes",
        ),
      ),

      body: Container(

        width: double.infinity,

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

        child: StreamBuilder<QuerySnapshot>(

          stream: FirebaseFirestore.instance
              .collection("pedidos")
              .orderBy(
                "data",
                descending: true,
              )
              .snapshots(),

          builder: (context, snapshot) {

            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {

              return const Center(

                child: Text(

                  "Nenhum pedido encontrado",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              );
            }

            return ListView.builder(

              padding:
                  const EdgeInsets.all(15),

              itemCount:
                  snapshot.data!.docs.length,

              itemBuilder: (context, index) {

                final doc =
                    snapshot.data!.docs[index];

                final data =
                    doc.data()
                        as Map<String, dynamic>;

                return Container(

                  margin:
                      const EdgeInsets.only(
                        bottom: 15,
                      ),

                  padding:
                      const EdgeInsets.all(
                        18,
                      ),

                  decoration: BoxDecoration(

                    color: isDark
                        ? Colors.white
                            .withValues(alpha: 0.05)
                        : Colors.white
                            .withValues(alpha: 0.12),

                    borderRadius:
                        BorderRadius.circular(
                          22,
                        ),

                    border: Border.all(
                      color:
                          Colors.white
                              .withValues(alpha: 0.08),
                    ),
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // 👤 CLIENTE
                      Text(

                        data["nomeCliente"] ??
                            "Cliente",

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🍔 PRODUTO
                      Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: List.generate(

                     (data["itens"] as List).length,

                     (index) {

                     final item = data["itens"][index];

                     return Padding(

                    padding: const EdgeInsets.only(bottom: 12),

                     child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                   Text(
                      "Produto: ${item["nomeProduto"]}",

                       style: const TextStyle(
                      color: Colors.white70,
                     fontSize: 16,
                    ),
                    ),

                   const SizedBox(height: 4),

                  Text(
                "Quantidade: ${item["quantidade"]}",
 
                style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 4),

                  Text(
                  "Preço: R\$ ${item["preco"]}",

                        style: const TextStyle(
                           color: Colors.white70,
                            fontSize: 16,
                            ),
                           ),

                      const Divider(
                      color: Colors.white24,
                       height: 20,
                    ),
                   ],
                ),
              );
            },
          ),
        ),

                      const SizedBox(height: 14),

                      // 🚚 STATUS
                      Row(

                        children: [

                          const Text(

                            "Status: ",

                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Container(

                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                            decoration: BoxDecoration(

                              color: Colors.green,

                              borderRadius:
                                  BorderRadius.circular(
                                    20,
                                  ),
                            ),

                            child: Text(

                              data["status"],

                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // 🔥 ALTERAR STATUS
                      Wrap(

                        spacing: 8,

                        children: [

                          statusButton(
                            doc.id,
                            "Preparando",
                          ),

                          statusButton(
                            doc.id,
                            "Saiu entrega",
                          ),

                          statusButton(
                            doc.id,
                            "Entregue",
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
    );
  }

  // 🔥 BOTÃO STATUS
  Widget statusButton(
    String id,
    String status,
  ) {

    return ElevatedButton(

      style: ElevatedButton.styleFrom(
        backgroundColor:
            const Color(0xFFD4A017),
      ),

      onPressed: () {
        atualizarStatus(id, status);
      },

      child: Text(status),
    );
  }
}