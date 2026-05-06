import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarrinhoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrinho;
  final String nomeCliente;

  const CarrinhoScreen({
    super.key,
    required this.carrinho,
    required this.nomeCliente,
  });

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {

  double converterPreco(dynamic preco) {
    if (preco is String) {
      return double.tryParse(preco.replaceAll(",", ".")) ?? 0;
    } else if (preco is num) {
      return preco.toDouble();
    }
    return 0;
  }

  double get total {
    return widget.carrinho.fold(0.0, (total, item) {
      return total +
          (converterPreco(item["preco"]) * item["quantidade"]);
    });
  }

  void aumentar(int i) {
    setState(() => widget.carrinho[i]["quantidade"]++);
  }

  void diminuir(int i) {
    setState(() {
      if (widget.carrinho[i]["quantidade"] > 1) {
        widget.carrinho[i]["quantidade"]--;
      } else {
        widget.carrinho.removeAt(i);
      }
    });
  }

  // 🔥 FINALIZAR PEDIDO (CORRETO)
  Future<void> finalizar() async {
    final user = FirebaseAuth.instance.currentUser;

    if (widget.carrinho.isEmpty) return;

    await FirebaseFirestore.instance.collection("pedidos").add({
      "itens": widget.carrinho,
      "usuarioId": user!.uid,
      "nomeCliente": widget.nomeCliente,
      "status": "pendente",
      "total": total,
      "data": Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pedido enviado com sucesso!")),
    );

    setState(() => widget.carrinho.clear());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seu carrinho"),
        centerTitle: true,
      ),

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E1E1E), const Color(0xFF000000)]
                : [const Color(0xFFB23A3A), const Color(0xFF7A1F1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: widget.carrinho.isEmpty
              ? const Center(
                  child: Text(
                    "Carrinho vazio",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  children: [

                    // 🔥 LISTA DE ITENS
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: widget.carrinho.length,
                        itemBuilder: (context, i) {
                          final item = widget.carrinho[i];
                          final preco = converterPreco(item["preco"]);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                )
                              ],
                            ),

                            child: Row(
                              children: [

                                const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.fastfood,
                                      color: Colors.white),
                                ),

                                const SizedBox(width: 10),

                                // 🔥 INFO DO PRODUTO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (item["nomeProduto"] ?? "Produto")
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "R\$ ${preco.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🔥 CONTROLE DE QUANTIDADE
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [

                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => diminuir(i),
                                      ),

                                      Text(
                                        item["quantidade"].toString(),
                                        style:
                                            const TextStyle(fontSize: 16),
                                      ),

                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => aumentar(i),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // 🔥 TOTAL + BOTÃO FINALIZAR
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness ==
                                Brightness.dark
                            ? Colors.grey[900]
                            : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),

                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                "R\$ ${total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: finalizar,
                              child: const Text(
                                "Finalizar Pedido",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}