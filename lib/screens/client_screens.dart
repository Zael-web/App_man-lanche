import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mana_lanche/screens/login_screens.dart';
import 'package:mana_lanche/screens/carrinho_screen.dart'; // 🔥 NOVO

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {

  String nomeCliente = "";
  bool carregando = true;

  // 🛒 CARRINHO
  List<Map<String, dynamic>> carrinho = [];

  @override
  void initState() {
    super.initState();
    carregarNome();
  }

  Future<void> carregarNome() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      nomeCliente = doc.exists ? doc["nome"] ?? "Cliente" : "Cliente";
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          },
        ),

        // 🛒 BOTÃO DO CARRINHO
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarrinhoScreen(
                        carrinho: carrinho,
                        nomeCliente: nomeCliente,
                      ),
                    ),
                  );
                },
              ),

              if (carrinho.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      carrinho.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],

        title: const Text("MANÁ LANCHES"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                carregando
                    ? "Carregando..."
                    : "Olá, $nomeCliente 👋",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "O que vai pedir hoje?",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    "Promoção do Dia 🍔",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Mais pedidos",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 LISTA DE PRODUTOS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("produtos")
                    .orderBy("nome")
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("Nenhum produto encontrado");
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return foodItem(
                        data["nome"],
                        data["preco"],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 CARD DO PRODUTO
  Widget foodItem(String nome, dynamic preco) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.fastfood),
        ),
        title: Text(nome),
        subtitle: Text("R\$ ${preco.toString()}"),

        trailing: ElevatedButton(
          onPressed: () {
            setState(() {
              carrinho.add({
                "nome": nome,
                "preco": preco,
              });
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Adicionado ao carrinho")),
            );
          },
          child: const Text("Pedir"),
        ),
      ),
    );
  }
}