import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() =>
      _PedidosAdminScreenState();
}

class _PedidosAdminScreenState
    extends State<PedidosAdminScreen> {

  // 🔥 ATUALIZAR STATUS
 Future<void> atualizarStatus(
  String id,
  String status,
) async {
  try {
    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(id)
        .update({
      "status": status,
    });

    // 🔥 evita travamento do rebuild
    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    if (!mounted) return;

    setState(() {});
  } catch (e) {
    debugPrint(
      "ERRO AO ATUALIZAR STATUS: $e",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Erro ao atualizar pedido",
        ),
      ),
    );
  }
}

  // 🗑️ REMOVER PEDIDO
  Future<void> removerPedido(String id) async {
    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(id)
        .delete();
  }

  Future<void> confirmarRemocao(
    String id,
  ) async {
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Remover pedido'),

          content: const Text(
            'Tem certeza que deseja remover este pedido?',
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(false),

              child: const Text(
                'Cancelar',
              ),
            ),

            TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(true),

              child:
                  const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      await removerPedido(id);
    }
  }

  // 🎨 COR STATUS
  Color corStatus(String status) {
    switch (status.toLowerCase()) {
      case "preparando":
        return Colors.orange;

      case "saiu entrega":
      case "saiu para entrega":
        return Colors.blue;

      case "entregue":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  // 🔥 ÍCONE STATUS
  IconData iconStatus(String status) {
    switch (status.toLowerCase()) {
      case "preparando":
        return Icons.restaurant;

      case "saiu entrega":
      case "saiu para entrega":
        return Icons.delivery_dining;

      case "entregue":
        return Icons.check_circle;

      default:
        return Icons.info;
    }
  }

  // 📅 FORMATAR DATA
  String formatPedidoData(
    dynamic timestamp,
  ) {
    if (timestamp == null) {
      return "Data não informada";
    }

    DateTime dateTime;

    if (timestamp is Timestamp) {
      dateTime =
          timestamp.toDate().toLocal();
    } else if (timestamp
        is DateTime) {
      dateTime = timestamp.toLocal();
    } else if (timestamp is String) {
      return timestamp;
    } else {
      return "Data inválida";
    }

    final day =
        dateTime.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        dateTime.month.toString().padLeft(
              2,
              '0',
            );

    final year = dateTime.year;

    final hour =
        dateTime.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        dateTime.minute.toString().padLeft(
              2,
              '0',
            );

    return "$day/$month/$year $hour:$minute";
  }

  // 📊 CARD DASHBOARD
  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(
                  alpha: 0.08,
                )
              : Colors.black.withValues(
                  alpha: 0.04,
                ),

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: isDark
                ? Colors.white24
                : Colors.black12,
          ),
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.white70,

                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : const Color
                        .fromARGB(
                        137,
                        243,
                        243,
                        243,
                      ),
              ),
            ),
          ],
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,

        backgroundColor:
            Colors.transparent,

        surfaceTintColor:
            Colors.transparent,

        shadowColor:
            Colors.transparent,

        elevation: 0,
        scrolledUnderElevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,

          ),

          onPressed: () =>
              Navigator.of(context)
                  .pop(),
        ),

        title: const Text(
          "Painel de Pedidos",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
            color: Colors.white,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.history,
            ),

            tooltip: "Histórico",

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const HistoricoPedidosScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF111111),
                    Color(0xFF1B1B1B),
                    Color(0xFF252525),
                  ]
                : const [
                    Color(0xFF7A2323),
                    Color(0xFF8B1F1F),
                    Color(0xFF9B2C2C),
                    Color(0xFFB33939),
                  ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child:
              StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore
                .instance
                .collection("pedidos")

                .snapshots(),

            builder:
                (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final docs = snapshot
                  .data!.docs
                  .where((d) {
                    final data =
                        d.data()
                            as Map<
                              String,
                              dynamic
                            >;

                    final status =
                        (data["status"] ??
                                "")
                            .toString()
                            .toLowerCase();

                    return status !=
                        "entregue";
                  })
                  .toList()
                ..sort((a, b) {
                  final dataA =
                      (a.data() as Map<
                              String,
                              dynamic>)["data"];

                  final dataB =
                      (b.data() as Map<
                              String,
                              dynamic>)["data"];

                  DateTime dateA =
                      dataA is Timestamp
                          ? dataA
                              .toDate()
                          : DateTime.now();

                  DateTime dateB =
                      dataB is Timestamp
                          ? dataB
                              .toDate()
                          : DateTime.now();

                  return dateB.compareTo(
                    dateA,
                  );
                });

              // 📊 MÉTRICAS
              final total =
                  docs.length;

              final preparando = docs
                  .where(
                    (d) =>
                        (d["status"] ??
                            "") ==
                        "Preparando",
                  )
                  .length;

              final entrega = docs
                  .where(
                    (d) =>
                        (d["status"] ??
                            "") ==
                        "Saiu para entrega",
                  )
                  .length;

              final pendentes = docs
                  .where(
                    (d) =>
                        (d["status"] ??
                            "") ==
                        "Pendente",
                  )
                  .length;

              return Column(
                children: [
                  // 📊 DASHBOARD
                  Padding(
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            dashboardCard(
                              "Total",
                              "$total",
                              Icons
                                  .receipt_long,
                              Colors.white,
                            ),

                            dashboardCard(
                              "Pendentes",
                              "$pendentes",
                              Icons
                                  .access_time,
                              Colors.red,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            dashboardCard(
                              "Preparando",
                              "$preparando",
                              Icons
                                  .restaurant,
                              Colors.orange,
                            ),

                            dashboardCard(
                              "Entrega",
                              "$entrega",
                              Icons
                                  .delivery_dining,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // 📦 LISTA
                  Expanded(
                    child: docs.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum pedido disponível.',

                              style: TextStyle(
                                color: Colors
                                    .white70,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.all(
                              12,
                            ),

                            itemCount:
                                docs.length,

                            itemBuilder:
                                (
                                  context,
                                  index,
                                ) {
                              final doc =
                                  docs[index];

                              final data =
                                  doc.data()
                                      as Map<
                                        String,
                                        dynamic
                                      >;

                              final itens =
                                  List.from(
                                data["itens"] ??
                                    [],
                              );

                              double totalPedido =
                                  0;

                              for (var item
                                  in itens) {
                                final preco =
                                    item["preco"] ??
                                        item["Preco"] ??
                                        0;

                                final quantidade =
                                    item["quantidade"] ??
                                        item["Quantidade"] ??
                                        1;

                                totalPedido +=
                                    (preco *
                                        quantidade);
                              }

                              final status =
                                  data["status"] ??
                                      "Desconhecido";

                              final statusFormatado =
                                  status
                                      .toString()
                                      .trim()
                                      .toLowerCase();

                              return Container(
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 16,
                                ),

                                padding:
                                    const EdgeInsets.all(
                                  16,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha:
                                        0.06,
                                  ),

                                  borderRadius:
                                      BorderRadius.circular(
                                    24,
                                  ),

                                  border:
                                      Border.all(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha:
                                          0.1,
                                    ),
                                  ),
                                ),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    // 👤 CLIENTE
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              corStatus(
                                            status,
                                          ),

                                          child:
                                              Icon(
                                            iconStatus(
                                              status,
                                            ),

                                            color:
                                                Colors.white,
                                          ),
                                        ),

                                        const SizedBox(
                                          width:
                                              12,
                                        ),

                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              Text(
                                                data["nomeCliente"] ??
                                                    "Cliente",

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

                                              Text(
                                                "${itens.length} itens",

                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white70,
                                                ),
                                              ),

                                              const SizedBox(
                                                height:
                                                    4,
                                              ),

                                              Text(
                                                formatPedidoData(
                                                  data["data"],
                                                ),

                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white54,

                                                  fontSize:
                                                      12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal:
                                                12,
                                            vertical:
                                                6,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            color:
                                                corStatus(
                                              status,
                                            ),

                                            borderRadius:
                                                BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child:
                                              Text(
                                            status,

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white,

                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height:
                                          12,
                                    ),

                                    // 🧾 ITENS
                                    ...itens.map(
                                      (item) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical:
                                                6,
                                          ),

                                          child:
                                              Row(
                                            children: [
                                              const Icon(
                                                Icons.fastfood,

                                                color:
                                                    Colors.white70,

                                                size:
                                                    18,
                                              ),

                                              const SizedBox(
                                                width:
                                                    8,
                                              ),

                                              Expanded(
                                                child:
                                                    Text(
                                                  item["nomeProduto"] ??
                                                      item["nome"] ??
                                                      "Produto",

                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.white70,
                                                  ),
                                                ),
                                              ),

                                              Text(
                                                "x${item["quantidade"] ?? item["Quantidade"] ?? 1}",

                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(
                                      height:
                                          10,
                                    ),

                                    // 💰 TOTAL
                                    Align(
                                      alignment:
                                          Alignment
                                              .centerRight,

                                      child:
                                          Text(
                                        "Total: R\$ ${totalPedido.toStringAsFixed(2)}",

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.amber,

                                          fontSize:
                                              16,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                          12,
                                    ),

                                    // 🎯 BOTÕES
                                    Wrap(
                                      spacing:
                                          8,
                                      runSpacing:
                                          8,

                                      children: [
                                        if (statusFormatado ==
                                            "pendente")
                                          actionButton(
                                            "Preparando",
                                            Colors.orange,

                                            () async {
                                              await atualizarStatus(
                                                doc.id,
                                                "Preparando",
                                              );

                                              if (!mounted) {
                                                return;
                                              }

                                              ScaffoldMessenger.of(
                                                      context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text(
                                                    "Pedido em preparação 🍔",
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                        if (statusFormatado ==
                                            "preparando")
                                          actionButton(
                                            "Saiu para entrega",
                                            Colors.blue,

                                            () async {
                                              await atualizarStatus(
                                                doc.id,
                                                "Saiu para entrega",
                                              );

                                              if (!mounted) {
                                                return;
                                              }

                                              ScaffoldMessenger.of(
                                                      context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text(
                                                    "Pedido saiu para entrega 🚚",
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

if (statusFormatado != "entregue")
  actionButton(
    "Entregue",
    Colors.green,
    () async {
      try {
        await FirebaseFirestore.instance
            .collection("pedidos")
            .doc(doc.id)
            .update({
          "status": "Entregue",
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Pedido entregue ✅",
            ),
          ),
        );
      } catch (e) {
        debugPrint(
          "ERRO: $e",
        );
      }
    },
  ),

                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 🔥 BOTÃO
  Widget actionButton(
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      style:
          ElevatedButton.styleFrom(
        backgroundColor: color,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),

      onPressed: onTap,
      child: Text(text),
    );
  }
}

// 📜 HISTÓRICO DE PEDIDOS

class HistoricoPedidosScreen extends StatelessWidget {
  const HistoricoPedidosScreen({
    super.key,
  });

  // 📅 FORMATAR DATA
  String formatPedidoData(dynamic timestamp) {
    if (timestamp == null) {
      return "Data não informada";
    }

    DateTime dateTime;

    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate().toLocal();
    } else if (timestamp is DateTime) {
      dateTime = timestamp.toLocal();
    } else if (timestamp is String) {
      return timestamp;
    } else {
      return "Data inválida";
    }

    final day =
        dateTime.day.toString().padLeft(2, '0');

    final month =
        dateTime.month.toString().padLeft(2, '0');

    final year = dateTime.year;

    final hour =
        dateTime.hour.toString().padLeft(2, '0');

    final minute =
        dateTime.minute.toString().padLeft(2, '0');

    return "$day/$month/$year $hour:$minute";
  }

  // 🗑️ LIMPAR HISTÓRICO
  Future<void> limparHistorico(
    BuildContext context,
  ) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("pedidos")
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final status =
            (data["status"] ?? "")
                .toString()
                .toLowerCase();

        if (status == "entregue") {
          await FirebaseFirestore.instance
              .collection("pedidos")
              .doc(doc.id)
              .delete();
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Histórico limpo 🗑️",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "ERRO AO LIMPAR: $e",
      );
    }
  }

  // ❌ REMOVER PEDIDO
  Future<void> removerPedidoHistorico(
    BuildContext context,
    String id,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection("pedidos")
          .doc(id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Pedido removido 🗑️",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "ERRO AO REMOVER: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF111111),
                    Color(0xFF1B1B1B),
                    Color(0xFF252525),
                  ]
                : const [
                    Color(0xFF7A2323),
                    Color(0xFF8B1F1F),
                    Color(0xFF9B2C2C),
                    Color(0xFFB33939),
                  ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // 🔥 TOPO
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        "Histórico de Pedidos",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    // 🗑️ LIMPAR HISTÓRICO
                    ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      onPressed: () async {
                        final confirmar =
                            await showDialog<
                              bool
                            >(
                          context: context,

                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                "Limpar histórico",
                              ),

                              content:
                                  const Text(
                                "Deseja remover todos os pedidos entregues?",
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      false,
                                    );
                                  },

                                  child:
                                      const Text(
                                    "Cancelar",
                                  ),
                                ),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },

                                  child:
                                      const Text(
                                    "Limpar",
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmar ==
                            true) {
                          await limparHistorico(
                            context,
                          );
                        }
                      },

                      icon: const Icon(
                        Icons.delete_sweep,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "Limpar Histórico",

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 📦 LISTA
              Expanded(
                child:
                    StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore
                      .instance
                      .collection("pedidos")
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

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "Nenhum dado encontrado.",

                          style: TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                      );
                    }

                    final docs = snapshot
                        .data!.docs
                        .where((doc) {
                          final data =
                              doc.data()
                                  as Map<
                                    String,
                                    dynamic
                                  >;

                          final status =
                              (data["status"] ??
                                      "")
                                  .toString()
                                  .toLowerCase();

                          return status ==
                              "entregue";
                        })
                        .toList();

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nenhum pedido entregue.",

                          style: TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),

                      itemCount:
                          docs.length,

                      itemBuilder:
                          (context, index) {
                        final doc =
                            docs[index];

                        final data =
                            doc.data()
                                as Map<
                                  String,
                                  dynamic
                                >;

                        final itens =
                            List.from(
                          data["itens"] ??
                              [],
                        );

                        double totalPedido =
                            0;

                        for (var item
                            in itens) {
                          final preco =
                              item["preco"] ??
                                  item["Preco"] ??
                                  0;

                          final quantidade =
                              item["quantidade"] ??
                                  item["Quantidade"] ??
                                  1;

                          totalPedido +=
                              (preco *
                                  quantidade);
                        }

                        return Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),

                          padding:
                              const EdgeInsets.all(
                            16,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white
                                .withValues(
                              alpha: 0.06,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              24,
                            ),

                            border:
                                Border.all(
                              color: Colors
                                  .white
                                  .withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              // 👤 CLIENTE
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    data["nomeCliente"] ??
                                        "Cliente",

                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .white,

                                      fontSize:
                                          18,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    formatPedidoData(
                                      data[
                                          "data"],
                                    ),

                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .white54,

                                      fontSize:
                                          12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // 🧾 ITENS
                              ...itens.map(
                                (item) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical:
                                          6,
                                    ),

                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .fastfood,

                                          color: Colors
                                              .white70,

                                          size:
                                              18,
                                        ),

                                        const SizedBox(
                                          width: 8,
                                        ),

                                        Expanded(
                                          child:
                                              Text(
                                            item["nomeProduto"] ??
                                                item["nome"] ??
                                                "Produto",

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white70,
                                            ),
                                          ),
                                        ),

                                        Text(
                                          "x${item["quantidade"] ?? item["Quantidade"] ?? 1}",

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // 🗑️ REMOVER PEDIDO
                              Align(
                                alignment:
                                    Alignment
                                        .centerRight,

                                child:
                                    ElevatedButton.icon(
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red,
                                  ),

                                  onPressed:
                                      () async {
                                    final confirmar =
                                        await showDialog<
                                          bool
                                        >(
                                      context:
                                          context,

                                      builder:
                                          (
                                            context,
                                          ) {
                                        return AlertDialog(
                                          title:
                                              const Text(
                                            "Remover pedido",
                                          ),

                                          content:
                                              const Text(
                                            "Deseja remover este pedido?",
                                          ),

                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () {
                                                Navigator.pop(
                                                  context,
                                                  false,
                                                );
                                              },

                                              child:
                                                  const Text(
                                                "Cancelar",
                                              ),
                                            ),

                                            TextButton(
                                              onPressed:
                                                  () {
                                                Navigator.pop(
                                                  context,
                                                  true,
                                                );
                                              },

                                              child:
                                                  const Text(
                                                "Remover",
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmar ==
                                        true) {
                                      await removerPedidoHistorico(
                                        context,
                                        doc.id,
                                      );
                                    }
                                  },

                                  icon: const Icon(
                                    Icons.delete,
                                    color:
                                        Colors.white,
                                  ),

                                  label:
                                      const Text(
                                    "Remover",
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // 💰 TOTAL
                              Align(
                                alignment:
                                    Alignment
                                        .centerRight,

                                child: Text(
                                  "Total: R\$ ${totalPedido.toStringAsFixed(2)}",

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.green,

                                    fontSize:
                                        16,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
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
    );
  }
}