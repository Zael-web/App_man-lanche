import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class CarrinhoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrinho;
  final String nomeCliente;

  const CarrinhoScreen({
    super.key,
    required this.carrinho,
    required this.nomeCliente,
  });

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  double converterPreco(dynamic preco) {
    if (preco is String) {
      return double.tryParse(preco.replaceAll(",", ".")) ?? 0;
    } else if (preco is num) {
      return preco.toDouble();
    }
    return 0;
  }

  double get total {
    return widget.carrinho.fold(0.0, (total, item) {
      return total +
          (converterPreco(item["preco"]) * item["quantidade"]);
    });
  }

  void aumentar(int i) {
    setState(() => widget.carrinho[i]["quantidade"]++);
  }

  void diminuir(int i) {
    setState(() {
      if (widget.carrinho[i]["quantidade"] > 1) {
        widget.carrinho[i]["quantidade"]--;
      } else {
        widget.carrinho.removeAt(i);
      }
    });
  }

  // 🔥 FINALIZAR PEDIDO + WHATSAPP
  Future<void> finalizar() async {
    final user = FirebaseAuth.instance.currentUser;

    if (widget.carrinho.isEmpty) return;

    // 🔥 ITENS PEDIDO
    List<Map<String, dynamic>> itensPedido = [];

    // 🔥 MENSAGEM WHATSAPP
    String mensagem =
        "🍔 *NOVO PEDIDO - MANÁ LANCHES* \n\n";

    for (var item in widget.carrinho) {
      itensPedido.add({
        "nomeProduto": item["nomeProduto"],
        "preco": item["preco"],
        "quantidade": item["quantidade"],
        "imagem": item["imagem"] ?? "",
      });

      mensagem +=
          "• ${item["nomeProduto"]} x${item["quantidade"]}\n";
    }

    mensagem +=
        "\n💰 *Total:* R\$ ${total.toStringAsFixed(2)}";

    mensagem +=
        "\n\n👤 Cliente: ${widget.nomeCliente}";

    // 🔥 SALVAR NO FIREBASE
    final pedidoRef = await FirebaseFirestore.instance
        .collection("pedidos")
        .add({
      "itens": itensPedido,
      "usuarioId": user!.uid,
      "telefone": user.phoneNumber ?? "",
      "status": "Pendente",
      "total": total,
      "data": FieldValue.serverTimestamp(),
    });

    final pedidoId = pedidoRef.id;

    // 🔥 COLOQUE SEU NÚMERO AQUI
    final numero = "5571999999999";

    // 🔥 LINK WHATSAPP
    final url =
        "https://wa.me/$numero?text=${Uri.encodeComponent(mensagem)}";

    // 🔥 ABRIR WHATSAPP
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pedido enviado com sucesso!"),
      ),
    );

    setState(() {
      widget.carrinho.clear();
    });

    Navigator.pop(context, pedidoId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seu carrinho"),
        centerTitle: true,
      ),

      body: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF121212),
                    const Color(0xFF0D0D0D),
                  ]
                : [
                    const Color(0xFFDB1F26),
                    const Color(0xFFB70F1D),
                  ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: widget.carrinho.isEmpty
              ? const Center(
                  child: Text(
                    "Carrinho vazio",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )

              : Column(
                  children: [
                    // 🔥 LISTA ITENS
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),

                        itemCount: widget.carrinho.length,

                        itemBuilder: (context, i) {
                          final item =
                              widget.carrinho[i];

                          final preco =
                              converterPreco(
                                  item["preco"]);

                          return Container(
                            margin:
                                const EdgeInsets.only(
                                    bottom: 10),

                            padding:
                                const EdgeInsets.all(
                                    14),

                            decoration: BoxDecoration(
                              color: theme.cardColor,

                              borderRadius:
                                  BorderRadius
                                      .circular(16),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(
                                          alpha: 0.08),

                                  blurRadius: 16,

                                  offset:
                                      const Offset(
                                          0, 8),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                // 🔥 IMAGEM PRODUTO
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),

                                  child: Image.network(
                                    item["imagem"] ??
                                        "",

                                    width: 70,
                                    height: 70,

                                    fit: BoxFit.cover,

                                    errorBuilder:
                                        (_, __, ___) {
                                      return Container(
                                        width: 70,
                                        height: 70,

                                        color: Colors
                                            .grey,

                                        child:
                                            const Icon(
                                          Icons
                                              .fastfood,

                                          color: Colors
                                              .white,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(
                                    width: 12),

                                // 🔥 INFO PRODUTO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      Text(
                                        item["nomeProduto"]
                                            .toString(),

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,

                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 4),

                                      Text(
                                        "R\$ ${preco.toStringAsFixed(2)}",

                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🔥 CONTROLE QUANTIDADE
                                Container(
                                  decoration:
                                      BoxDecoration(
                                    color: isDark
                                        ? Colors
                                            .grey[800]
                                        : Colors
                                            .grey[200],

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                20),
                                  ),

                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon:
                                            const Icon(
                                          Icons.remove,
                                        ),

                                        onPressed:
                                            () =>
                                                diminuir(
                                                    i),
                                      ),

                                      Text(
                                        item["quantidade"]
                                            .toString(),

                                        style:
                                            const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),

                                      IconButton(
                                        icon:
                                            const Icon(
                                          Icons.add,
                                        ),

                                        onPressed:
                                            () =>
                                                aumentar(
                                                    i),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // 🔥 TOTAL + FINALIZAR
                    Container(
                      padding:
                          const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: theme.cardColor,

                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                                    alpha: 0.06),

                            blurRadius: 12,

                            offset:
                                const Offset(0, -4),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              const Text(
                                "Total",

                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),

                              Text(
                                "R\$ ${total.toStringAsFixed(2)}",

                                style: TextStyle(
                                  fontSize: 20,

                                  fontWeight:
                                      FontWeight.bold,

                                  color: theme
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 50,

                            child: ElevatedButton.icon(
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.green,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              12),
                                ),
                              ),

                              onPressed: finalizar,

                             icon: const Icon(
                             Icons.shopping_bag,
                             color: Colors.white,
                            ),

                              label: const Text(
                                "Enviar Pedido",

                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}