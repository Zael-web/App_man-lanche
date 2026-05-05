import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidosAdminScreen extends StatelessWidget {
  const PedidosAdminScreen({super.key});

  // 🔥 ATUALIZAR STATUS
  Future<void> atualizarStatus(String id, String novoStatus) async {
    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(id)
        .update({
      "status": novoStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pedidos")
            .orderBy("data", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Nenhum pedido encontrado"),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data["nomeProduto"]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Preço: R\$ ${data["preco"]}"),
                      Text("Status: ${data["status"]}"),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      atualizarStatus(doc.id, value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "pendente",
                        child: Text("Pendente"),
                      ),
                      const PopupMenuItem(
                        value: "preparando",
                        child: Text("Preparando"),
                      ),
                      const PopupMenuItem(
                        value: "entregue",
                        child: Text("Entregue"),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}