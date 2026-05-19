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

  final nomeAddController = TextEditingController();
  final precoAddController = TextEditingController();
  final categoriaAddController = TextEditingController();
  final imagemAddController = TextEditingController();

  @override
  void dispose() {
    nomeAddController.dispose();
    precoAddController.dispose();
    categoriaAddController.dispose();
    imagemAddController.dispose();
    super.dispose();
  }

  Future<void> adicionarProduto(
    TextEditingController nomeController,
    TextEditingController precoController,
    TextEditingController categoriaController,
    TextEditingController imagemController,
  ) async {
    try {
      final nome = nomeController.text.trim();
      final precoTexto = precoController.text.trim();
      if (nome.isEmpty || precoTexto.isEmpty) {
        return;
      }

      final preco = double.parse(precoTexto.replaceAll(",", "."));

      await FirebaseFirestore.instance.collection("produtos").add({
        "nome": nome,
        "preco": preco,
        "categoria": categoriaController.text.trim(),
        "imagem": imagemController.text.trim(),
      });

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Produto adicionado!")));

      nomeController.clear();
      precoController.clear();
      categoriaController.clear();
      imagemController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao adicionar produto: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> mostrarDialogAdicionarProduto() async {
    final nomeController = TextEditingController();
    final precoController = TextEditingController();
    final categoriaController = TextEditingController();
    final imagemController = TextEditingController();

    try {
      await showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: const Color.fromARGB(0, 221, 4, 4),
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF232323),
                          const Color(0xFF2B2B2B),
                        ]
                      : [
                          const Color(0xFFFFFBF7),
                          const Color(0xFFF8EFEA),
                          const Color(0xFFF3E4DE),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B0000).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF8B0000),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Adicionar Produto",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Preencha os dados do novo produto",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nomeController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Nome do produto",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey.shade600,
                        ),
                        prefixIcon: const Icon(
                          Icons.fastfood_rounded,
                          color: Color(0xFF8B0000),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: precoController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Preço",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey.shade600,
                        ),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Color(0xFFD2691E),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: categoriaController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Categoria (opcional)",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey.shade600,
                        ),
                        prefixIcon: const Icon(
                          Icons.label_outline,
                          color: Color(0xFFD2691E),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: imagemController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "URL da imagem (opcional)",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey.shade600,
                        ),
                        prefixIcon: const Icon(
                          Icons.image,
                          color: Color(0xFFD2691E),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD2691E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => adicionarProduto(
                          nomeController,
                          precoController,
                          categoriaController,
                          imagemController,
                        ),
                        child: const Text(
                          "Adicionar Produto",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      nomeController.dispose();
      precoController.dispose();
      categoriaController.dispose();
      imagemController.dispose();
    }
  }

  // 🔥 EDITAR PRODUTO
  Future<void> editarProduto(
    String id,
    String nomeAtual,
    String precoAtual,
  ) async {
    final nomeEditController = TextEditingController(text: nomeAtual);
    final precoEditController = TextEditingController(text: precoAtual);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color.fromARGB(0, 221, 4, 4),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF232323),
                        const Color(0xFF2B2B2B),
                      ]
                    : [
                        const Color(0xFFFFFBF7),
                        const Color(0xFFF8EFEA),
                        const Color(0xFFF3E4DE),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ÍCONE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF8B0000),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                // TÍTULO
                Text(
                  "Editar Produto",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Atualize as informações do produto",
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                // CAMPO NOME
                TextField(
                  controller: nomeEditController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Nome do produto",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                    ),
                    prefixIcon: const Icon(
                      Icons.fastfood_rounded,
                      color: Color(0xFF8B0000),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: Color(0xFFD2691E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // CAMPO PREÇO
                TextField(
                  controller: precoEditController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Preço",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                    ),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFFD2691E),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: Color(0xFFD2691E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // BOTÕES
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD2691E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final novoNome = nomeEditController.text;
                            final novoPreco = double.parse(
                              precoEditController.text.replaceAll(",", "."),
                            );

                            await FirebaseFirestore.instance
                                .collection("produtos")
                                .doc(id)
                                .update({"nome": novoNome, "preco": novoPreco});

                            if (!mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Produto atualizado!"),
                              ),
                            );
                          },
                          child: const Text(
                            "Salvar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              editarProduto(id, nome, preco.toString());
            },
          ),

          // 🗑 DELETAR
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (_) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    title: const Text(
                      "Confirmar exclusão",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      "Tem certeza que deseja excluir o produto '$nome'? Esta ação não pode ser desfeita.",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("produtos")
                              .doc(id)
                              .delete();

                          if (!mounted) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Produto deletado"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: const Text(
                          "Excluir",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: mostrarDialogAdicionarProduto,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
        backgroundColor: const Color(0xFFD2691E),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.white),
        title: Text(
          "PRODUTOS",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF111111),
                    Color(0xFF1A1A1A),
                    Color(0xFF222222),
                    Color(0xFF2C2C2C),
                  ]
                : const [
                    Color(0xFF7A2323),
                    Color(0xFF8B1F1F),
                    Color(0xFF9B2C2C),
                    Color(0xFFB33939),
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
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.10),

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),

                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        pesquisa = value.toLowerCase();
                      });
                    },

                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.white,
                    ),

                    cursorColor: Colors.white,

                    decoration: InputDecoration(
                      hintText: "Pesquisar produto...",

                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),

                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),

                      // 🔥 REMOVE O FUNDO BRANCO
                      filled: true,
                      fillColor: Colors.transparent,

                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,

                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
