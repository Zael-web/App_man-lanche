import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (nomeController.text.isEmpty || precoController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("produtos").add({
      "nome": nomeController.text,
      "preco": double.parse(precoController.text),
    });

    nomeController.clear();
    precoController.clear();
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
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar produto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeEditController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                ),
              ),
              TextField(
                controller: precoEditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Preço",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("produtos")
                    .doc(id)
                    .update({
                  "nome": nomeEditController.text,
                  "preco": double.parse(precoEditController.text),
                });

                Navigator.pop(context);
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ADMIN - Produtos"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            // 🔹 FORMULÁRIO
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

            // 🔥 LISTA DE PRODUTOS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("produtos")
                    .orderBy("nome")
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data["nome"]),
                        subtitle: Text("R\$ ${data["preco"]}"),

                        // 🔥 CLICAR = EDITAR
                        onTap: () {
                          editarProduto(
                            doc.id,
                            data["nome"],
                            data["preco"].toString(),
                          );
                        },

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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