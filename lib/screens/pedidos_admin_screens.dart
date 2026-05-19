import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  bool showHistory = true;

  Future<void> atualizarStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection("pedidos").doc(id).update({
      "status": status,
    });
  }

  Future<void> removerPedido(String id) async {
    await FirebaseFirestore.instance.collection("pedidos").doc(id).delete();
  }

  Future<void> confirmarRemocao(String id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover pedido'),
          content: const Text('Tem certeza que deseja remover este pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      await removerPedido(id);
    }
  }

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

  String formatPedidoData(dynamic timestamp) {
    if (timestamp == null) return "Data não informada";

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

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return "$day/$month/$year $hour:$minute";
  }

  Widget dashboardCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : const Color.fromARGB(137, 243, 243, 243),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Painel de Pedidos",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("pedidos")
                .orderBy("data", descending: true)
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              final visibleDocs = showHistory
                  ? docs
                        .where(
                          (d) =>
                              (d["status"] as String? ?? "").toLowerCase() ==
                              "entregue",
                        )
                        .toList()
                  : docs;

              // 📊 métricas estilo dashboard
              final total = visibleDocs.length;
              final preparando = visibleDocs
                  .where((d) => (d["status"] as String? ?? "") == "Preparando")
                  .length;
              final entrega = visibleDocs
                  .where(
                    (d) => (d["status"] as String? ?? "") == "Saiu entrega",
                  )
                  .length;
              final entregues = visibleDocs
                  .where((d) => (d["status"] as String? ?? "") == "Entregue")
                  .length;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        filterButton(
                          "Histórico",
                          showHistory,
                          () => setState(() => showHistory = true),
                        ),
                        const SizedBox(width: 8),
                        filterButton(
                          "Todos",
                          !showHistory,
                          () => setState(() => showHistory = false),
                        ),
                      ],
                    ),
                  ),
                  // 📊 DASHBOARD TOP
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            dashboardCard(
                              "Total",
                              "$total",
                              Icons.receipt_long,
                              Colors.white,
                            ),
                            dashboardCard(
                              "Preparando",
                              "$preparando",
                              Icons.restaurant,
                              Colors.orange,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            dashboardCard(
                              "Entrega",
                              "$entrega",
                              Icons.delivery_dining,
                              Colors.blue,
                            ),
                            dashboardCard(
                              "Entregues",
                              "$entregues",
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📦 LISTA DE PEDIDOS
                  Expanded(
                    child: visibleDocs.isEmpty
                        ? Center(
                            child: Text(
                              showHistory
                                  ? 'Nenhum pedido entregue encontrado.'
                                  : 'Nenhum pedido disponível.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: visibleDocs.length,
                            itemBuilder: (context, index) {
                              final doc = visibleDocs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final itens = List.from(data["itens"] ?? []);

                              double totalPedido = 0;

                              for (var item in itens) {
                                totalPedido +=
                                    (item["preco"] ?? 0) *
                                    (item["quantidade"] ?? 1);
                              }

                              final status = data["status"] ?? "Desconhecido";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 👤 CLIENTE + STATUS
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: corStatus(status),
                                          child: Icon(
                                            iconStatus(status),
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data["nomeCliente"] ??
                                                    "Cliente",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${itens.length} itens",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formatPedidoData(data["data"]),
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: corStatus(status),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // 🧾 ITENS
                                    ...itens.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.fastfood,
                                              color: Colors.white70,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item["nomeProduto"] ?? "",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "x${item["quantidade"]}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    const SizedBox(height: 10),

                                    // 💰 TOTAL
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "Total: R\$ ${totalPedido.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // 🎯 AÇÕES
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if (status.toLowerCase() != "entregue")
                                          actionButton(
                                            "Entregue",
                                            Colors.green,
                                            () => atualizarStatus(
                                              doc.id,
                                              "Entregue",
                                            ),
                                          ),
                                        actionButton(
                                          "Remover",
                                          Colors.red,
                                          () => confirmarRemocao(doc.id),
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

  Widget filterButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? Colors.white24 : Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget actionButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }
}
