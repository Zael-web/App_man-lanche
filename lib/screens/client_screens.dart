import 'package:flutter/material.dart';
import 'package:mana_lanche/screens/login_screens.dart';

class ClientScreen extends StatelessWidget {
  const ClientScreen({super.key});

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

  title: const Text("MANÁ LANCHES"),
  centerTitle: true,
),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Olá, Cliente 👋",
                style: TextStyle(
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

              // BANNER
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

              foodItem("X-Burguer", "R\$ 15,00"),
              foodItem("X-Bacon", "R\$ 20,00"),
              foodItem("X-Tudo", "R\$ 25,00"),
              foodItem("Batata Frita", "R\$ 12,00"),
            ],
          ),
        ),
      ),
    );
  }

  Widget foodItem(String nome, String preco) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.fastfood),
        ),
        title: Text(nome),
        subtitle: Text(preco),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text("Pedir"),
        ),
      ),
    );
  }
}