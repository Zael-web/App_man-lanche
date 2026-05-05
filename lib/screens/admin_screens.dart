import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

      await FirebaseFirestore.instance.collection("produtos").add({
        "nome": nomeController.text,
        "preco": preco,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto adicionado!")),
      );

      nomeController.clear();
      precoController.clear();

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao adicionar produto")),
      );
    }
  }

  // 🔥 EXCLUIR PRODUTO
  Future<void> excluirProduto(String id) async {
    await FirebaseFirestore.instance
        .collection("produtos")
        .doc(id)
        .delete();
  }

  // 🔥 EDITAR PRODUTO
  Future<void> editarProduto(
    String id,
    String nomeAtual,
    String precoAtual,
  ) async {
    final nomeEditController = TextEditingController(text: nomeAtual);
    final precoEditController = TextEditingController(text: precoAtual);

    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          title: const Text("Editar produto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeEditController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: precoEditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Preço"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final preco = double.parse(
                    precoEditController.text.replaceAll(",", "."),
                  );

                  await FirebaseFirestore.instance
                      .collection("produtos")
                      .doc(id)
                      .update({
                    "nome": nomeEditController.text,
                    "preco": preco,
                  });

                  if (!mounted) return;

                  Navigator.pop(contextDialog);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Produto atualizado!")),
                  );

                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erro ao editar produto")),
                  );
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ADMIN - Produtos"),

        // 🔥 BOTÃO VER PEDIDOS
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            tooltip: "Ver pedidos",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PedidosAdminScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome do produto",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Preço",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: adicionarProduto,
              child: const Text("Adicionar Produto"),
            ),

            const SizedBox(height: 20),

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
                      child: Text("Nenhum produto encontrado"),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data["nome"]),
                        subtitle: Text("R\$ ${data["preco"]}"),

                        onTap: () {
                          editarProduto(
                            doc.id,
                            data["nome"],
                            data["preco"].toString(),
                          );
                        },

                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            excluirProduto(doc.id);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}