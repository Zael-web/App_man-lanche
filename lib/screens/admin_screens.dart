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

  // 🔥 EXCLUIR
  Future<void> excluirProduto(String id) async {
    await FirebaseFirestore.instance
        .collection("produtos")
        .doc(id)
        .delete();
  }

  // 🔥 EDITAR
  Future<void> editarProduto(
      String id, String nomeAtual, String precoAtual) async {
    final nomeEditController = TextEditingController(text: nomeAtual);
    final precoEditController = TextEditingController(text: precoAtual);

    showDialog(
      context: context,
      builder: (contextDialog) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: const Text("Editar produto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeEditController,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              TextField(
                controller: precoEditController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "Preço",
                  labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54),
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("ADMIN - Produtos"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF000000)]
                : [const Color(0xFFB23A3A), const Color(0xFF7A1F1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [

                // 🔥 FORMULÁRIO
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [

                      // INPUT NOME
                      TextField(
                        controller: nomeController,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Nome do produto",
                          labelStyle: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // INPUT PREÇO
                      TextField(
                        controller: precoController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Preço",
                          labelStyle: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: adicionarProduto,
                          child: const Text("Adicionar Produto"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 LISTA
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
                          child: Text(
                            "Nenhum produto encontrado",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;

                          return Container(
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),

                            child: ListTile(
                              title: Text(
                                data["nome"],
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                "R\$ ${data["preco"]}",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),

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
        ),
      ),
    );
  }
}