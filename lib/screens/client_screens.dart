import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mana_lanche/screens/login_screens.dart';
import 'package:mana_lanche/screens/carrinho_screens.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  String nomeCliente = "";
  bool carregando = true;

  List<Map<String, dynamic>> carrinho = [];

  String categoriaSelecionada = "todos";

  int animatingIndex = -1;
  int fraseIndex = 0;

  final List<String> frases = [
    "🔥 Impossível resistir",
    "🍔 Fome bateu? a gente resolve!",
    "😋 Sabor que conquista no primeiro pedaço",
    "🚀 Peça agora e mate sua fome!",
    "💥 Promoções que você não pode perder",
    "🍟 Combos que valem a pena!",
    "🥤 Complete sua refeição com estilo",
  ];

  @override
  void initState() {
    super.initState();
    carregarNome();
    iniciarFrases();
  }

  void iniciarFrases() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return false;

      setState(() {
        fraseIndex = (fraseIndex + 1) % frases.length;
      });

      return true;
    });
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

  void adicionarAoCarrinho(String nome, dynamic preco, int index) async {
    setState(() {
      animatingIndex = index;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      final i = carrinho.indexWhere((item) => item["nomeProduto"] == nome);

      if (i >= 0) {
        carrinho[i]["quantidade"]++;
      } else {
        carrinho.add({
          "nomeProduto": nome,
          "preco": preco,
          "quantidade": 1,
        });
      }

      animatingIndex = -1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF7A2323),
        content: Text("🍔 $nome adicionado ao carrinho"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),

        title: const Text(
          "MANÁ LANCHES",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart,
                    color: Colors.white),
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
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
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
      ),

      extendBodyBehindAppBar: true,

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF111111),
                    const Color(0xFF1B1B1B),
                    const Color(0xFF252525),
                  ]
                : [
                    const Color(0xFF5C1A1B),
                    const Color(0xFF7A2323),
                    const Color(0xFFB33939),
                  ],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  carregando
                      ? "Carregando..."
                      : "Olá, $nomeCliente 👋",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    frases[fraseIndex],
                    key: ValueKey(frases[fraseIndex]),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      categoriaChip("Todos"),
                      categoriaChip("Hamburguer"),
                      categoriaChip("Pizza"),
                      categoriaChip("Bebida"),
                      categoriaChip("Combos"),
                      categoriaChip("Batatas"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Produtos",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

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

                      final docs = snapshot.data!.docs;

                      final filtrados = docs.where((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;

                        final categoria =
                            (data["categoria"] ?? "")
                                .toString()
                                .toLowerCase();

                        if (categoriaSelecionada == "todos") {
                          return true;
                        }

                        return categoria ==
                            categoriaSelecionada.toLowerCase();
                      }).toList();

                      return ListView.builder(
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          final doc = filtrados[index];
                          final data =
                              doc.data() as Map<String, dynamic>;

                          return foodItem(
                            data["nome"] ?? "",
                            data["preco"] ?? 0,
                            index,
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
      ),
    );
  }

  // 🍔 CATEGORIA CHIP
  Widget categoriaChip(String titulo) {
    final selecionado =
        categoriaSelecionada.toLowerCase() ==
        titulo.toLowerCase();

    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSelecionada = titulo.toLowerCase();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFFFFD166)
              : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: selecionado ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🍔 CARD PRODUTO
  Widget foodItem(String nome, dynamic preco, int index) {
    final isAnimating = animatingIndex == index;

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isAnimating ? 0.97 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF7A2323),
            child: Icon(Icons.fastfood, color: Colors.white),
          ),

          title: Text(nome),

          subtitle: Text("R\$ $preco"),

          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isAnimating ? Colors.green : const Color(0xFF8B0000),
            ),
            onPressed: () {
              adicionarAoCarrinho(nome, preco, index);
            },
            child: Text(
              isAnimating ? "✔" : "Adicionar",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}