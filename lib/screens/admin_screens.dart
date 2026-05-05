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