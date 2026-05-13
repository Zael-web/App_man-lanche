import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProdutosAdminScreen extends StatefulWidget {
  const ProdutosAdminScreen({super.key});

  @override
  State<ProdutosAdminScreen> createState() => _ProdutosAdminScreenState();
}

class _ProdutosAdminScreenState extends State<ProdutosAdminScreen> {
  String pesquisa = "";
  String categoriaSelecionada = "todos";

  // 🔥 CHIP CATEGORIA
  Widget categoriaChip(String titulo) {
    final selecionado =
        categoriaSelecionada.toLowerCase() == titulo.toLowerCase();

    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSelecionada = titulo.toLowerCase();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFFFFB703)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
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

  // 🔥 CARD PRODUTO (MELHORADO)
  Widget produtoCard(Map<String, dynamic> data, String id) {
    final nome = data["nome"] ?? "Sem nome";
    final categoria = data["categoria"] ?? "sem categoria";
    final imagem = data["imagem"] ?? "";
    final preco = data["preco"];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          // 🖼 IMAGEM
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imagem.isNotEmpty
                ? Image.network(
                    imagem,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.black26,
                        child: const Icon(Icons.fastfood, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.black26,
                    child: const Icon(Icons.fastfood, color: Colors.white),
                  ),
          ),

          const SizedBox(width: 12),

          // 📦 INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Categoria: $categoria",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 6),

                Text(
                  "R\$ ${(preco ?? 0).toString()}",
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // ✏️ EDITAR
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: abrir modal editar produto
            },
          ),

          // 🗑 DELETAR
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("produtos")
                  .doc(id)
                  .delete();

              if (!mounted) return;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Produto deletado")));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "PRODUTOS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3E0F12),
              Color(0xFF5A171B),
              Color(0xFF7A2323),
              Color(0xFFA63A3A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔎 PESQUISA
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        pesquisa = value.toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: "Pesquisar produto...",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🍕 CATEGORIAS
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      categoriaChip("todos"),
                      categoriaChip("hamburguer"),
                      categoriaChip("pizza"),
                      categoriaChip("bebida"),
                      categoriaChip("combos"),
                      categoriaChip("batatas"),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 📦 LISTA
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("produtos")
                        .orderBy("nome")
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      final filtrados = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final nome = (data["nome"] ?? "")
                            .toString()
                            .toLowerCase();

                        final categoria = (data["categoria"] ?? "")
                            .toString()
                            .toLowerCase();

                        final matchCategoria = categoriaSelecionada == "todos"
                            ? true
                            : categoria == categoriaSelecionada.toLowerCase();

                        final matchPesquisa = nome.contains(pesquisa);

                        return matchCategoria && matchPesquisa;
                      }).toList();

                      if (filtrados.isEmpty) {
                        return const Center(
                          child: Text(
                            "Nenhum produto encontrado",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          final doc = filtrados[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return produtoCard(data, doc.id);
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
}
