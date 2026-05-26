import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

//  TELA DE PRODUTOS - ADMIN

class ProdutosAdminScreen extends StatefulWidget {
  const ProdutosAdminScreen({super.key});

  @override
  State<ProdutosAdminScreen> createState() => _ProdutosAdminScreenState();
}

class _ProdutosAdminScreenState extends State<ProdutosAdminScreen> {
  // ── Estado ──────────────────────────────────────────
  XFile? imagemSelecionada;

  bool carregandoImagem = false;
  String? imagemUrl;
  String pesquisa = "";
  String categoriaSelecionada = "todos";

  // ── Controllers ─────────────────────────────────────
  final nomeAddController = TextEditingController();
  final precoAddController = TextEditingController();
  final categoriaAddController = TextEditingController();

  @override
  void dispose() {
    nomeAddController.dispose();
    precoAddController.dispose();
    categoriaAddController.dispose();
    super.dispose();
  }

  //  IMAGEM

  Future<void> escolherImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (imagem == null) return;
    setState(() => imagemSelecionada = imagem);
    await uploadImagem();
  }

  Future<void> uploadImagem() async {
    if (imagemSelecionada == null) return;
    setState(() => carregandoImagem = true);

    try {
      final uri = Uri.parse(
        "https://api.imgbb.com/1/upload?key=9775633925a7a9aaf191abefeb34e170",
      );
      final request = http.MultipartRequest("POST", uri);
      final bytes = await imagemSelecionada!.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          bytes,
          filename: imagemSelecionada!.name,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      imagemUrl = data["data"]["url"];
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro upload imagem: $e")));
    } finally {
      setState(() => carregandoImagem = false);
    }
  }

  //  ADICIONAR PRODUTO

  Future<void> mostrarDialogAdicionarProduto() async {
    final nomeController = TextEditingController();
    final precoController = TextEditingController();
    final categoriaController = TextEditingController();

    try {
      await showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(20),
                child: _dialogContainer(
                  isDark: isDark,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícone
                        _dialogIcone(Icons.add_circle),
                        const SizedBox(height: 18),

                        // Título
                        _dialogTitulo("Adicionar Produto", isDark),
                        const SizedBox(height: 25),

                        // Campos
                        _campoTexto(
                          controller: nomeController,
                          hint: "Nome do produto",
                          icon: Icons.fastfood,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _campoTexto(
                          controller: precoController,
                          hint: "Preço",
                          icon: Icons.attach_money,
                          isDark: isDark,
                          teclado: TextInputType.number,
                          iconColor: const Color(0xFFD2691E),
                        ),
                        const SizedBox(height: 14),
                        _campoTexto(
                          controller: categoriaController,
                          hint: "Categoria",
                          icon: Icons.category,
                          isDark: isDark,
                          iconColor: const Color(0xFFD2691E),
                        ),
                        const SizedBox(height: 20),

                        // Seletor de imagem
                        _seletorImagem(setStateDialog),
                        const SizedBox(height: 24),

                        // Botão adicionar
                        _botaoPrincipal(
                          texto: "Adicionar Produto",
                          onTap: () async {
                            await _salvarNovoProduto(
                              context,
                              nomeController,
                              precoController,
                              categoriaController,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      nomeController.dispose();
      precoController.dispose();
      categoriaController.dispose();
    }
  }

  Future<void> _salvarNovoProduto(
    BuildContext context,
    TextEditingController nomeCtrl,
    TextEditingController precoCtrl,
    TextEditingController categoriaCtrl,
  ) async {
    if (nomeCtrl.text.trim().isEmpty || precoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha nome e preço")));
      return;
    }

    try {
      final nome = nomeCtrl.text.trim();
      final preco = double.parse(precoCtrl.text.replaceAll(",", "."));

      await FirebaseFirestore.instance.collection("produtos").add({
        "nome": nome,
        "preco": preco,
        "categoria": categoriaCtrl.text.trim(),
        "imagem": imagemUrl ?? "",
      });

      if (!mounted) return;
      Navigator.pop(context);
      imagemSelecionada = null;
      imagemUrl = null;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Produto adicionado!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  //  EDITAR PRODUTO
  Future<void> editarProduto(
    String id,
    String nomeAtual,
    String precoAtual,
    String imagemAtual,
  ) async {
    final nomeCtrl = TextEditingController(text: nomeAtual);
    final precoCtrl = TextEditingController(text: precoAtual);
    final imagemCtrl = TextEditingController(text: imagemAtual);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color.fromARGB(0, 221, 4, 4),
          insetPadding: const EdgeInsets.all(20),
          child: _dialogContainer(
            isDark: isDark,
            comBorda: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone
                _dialogIcone(Icons.edit_rounded),
                const SizedBox(height: 18),

                // Título + subtítulo
                _dialogTitulo("Editar Produto", isDark),
                const SizedBox(height: 8),
                Text(
                  "Atualize as informações do produto",
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                // Campos
                _campoTextoEstilizado(
                  controller: nomeCtrl,
                  hint: "Nome do produto",
                  icon: Icons.fastfood_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _campoTextoEstilizado(
                  controller: precoCtrl,
                  hint: "Preço",
                  icon: Icons.attach_money,
                  isDark: isDark,
                  teclado: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _campoTextoEstilizado(
                  controller: imagemCtrl,
                  hint: "URL da imagem (opcional)",
                  icon: Icons.image,
                  isDark: isDark,
                ),
                const SizedBox(height: 30),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
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
                          onPressed: () => _salvarEdicaoProduto(
                            context,
                            id,
                            nomeCtrl,
                            precoCtrl,
                            imagemCtrl,
                          ),
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

  Future<void> _salvarEdicaoProduto(
    BuildContext context,
    String id,
    TextEditingController nomeCtrl,
    TextEditingController precoCtrl,
    TextEditingController imagemCtrl,
  ) async {
    final novoNome = nomeCtrl.text;
    final novoPreco = double.parse(precoCtrl.text.replaceAll(",", "."));
    final rawImagem = imagemCtrl.text.trim();
    final imagemLink = rawImagem.isEmpty
        ? ""
        : (rawImagem.startsWith(RegExp(r'https?://'))
              ? rawImagem
              : 'https://$rawImagem');

    await FirebaseFirestore.instance.collection("produtos").doc(id).update({
      "nome": novoNome,
      "preco": novoPreco,
      "imagem": imagemLink,
    });

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Produto atualizado!")));
  }

  //  DELETAR PRODUTO

  void confirmarDelecao(BuildContext context, String id, String nome) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            "Confirmar exclusão",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //  WIDGETS REUTILIZÁVEIS

  // Container padrão dos dialogs
  Widget _dialogContainer({
    required bool isDark,
    required Widget child,
    bool comBorda = false,
  }) {
    return Container(
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
        border: comBorda
            ? Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.7),
              )
            : null,
        boxShadow: comBorda
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  // Ícone do dialog
  Widget _dialogIcone(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, color: const Color(0xFF8B0000), size: 34),
    );
  }

  // Título do dialog
  Widget _dialogTitulo(String texto, bool isDark) {
    return Text(
      texto,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Campo simples (dialog adicionar)
  Widget _campoTexto({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType teclado = TextInputType.text,
    Color iconColor = const Color(0xFF8B0000),
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Campo estilizado (dialog editar)
  Widget _campoTextoEstilizado({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade600,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFD2691E)),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
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
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFD2691E), width: 2),
        ),
      ),
    );
  }

  // Seletor de imagem
  Widget _seletorImagem(StateSetter setStateDialog) {
    return GestureDetector(
      onTap: () async {
        await escolherImagem();
        setStateDialog(() {});
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white24),
        ),
        child: carregandoImagem
            ? const Center(child: CircularProgressIndicator())
            : imagemSelecionada != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: kIsWeb
                    ? Image.network(imagemSelecionada!.path, fit: BoxFit.cover)
                    : Image.network(imagemSelecionada!.path, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    "Selecionar imagem",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  // Botão principal
  Widget _botaoPrincipal({required String texto, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD2691E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Chip de categoria
  Widget categoriaChip(String titulo) {
    final selecionado =
        categoriaSelecionada.toLowerCase() == titulo.toLowerCase();

    return GestureDetector(
      onTap: () => setState(() => categoriaSelecionada = titulo.toLowerCase()),
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

  // Card de produto
  Widget produtoCard(Map<String, dynamic> data, String id) {
    final nome = data["nome"] ?? "Sem nome";
    final categoria = data["categoria"] ?? "sem categoria";
    final imagem = data["imagem"] ?? data["image"] ?? "";
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
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imagem.isNotEmpty
                ? Image.network(
                    imagem,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagemFallback(),
                  )
                : _imagemFallback(),
          ),

          const SizedBox(width: 12),

          // Informações
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

          // Editar
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => editarProduto(id, nome, preco.toString(), imagem),
          ),

          // Deletar
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => confirmarDelecao(context, id, nome),
          ),
        ],
      ),
    );
  }

  Widget _imagemFallback() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.black26,
      child: const Icon(Icons.fastfood, color: Colors.white),
    );
  }

  //  BUILD
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: mostrarDialogAdicionarProduto,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
        backgroundColor: const Color(0xFFFFB703),
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                // 🔍 Barra de pesquisa
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
                    onChanged: (value) =>
                        setState(() => pesquisa = value.toLowerCase()),
                    style: const TextStyle(color: Colors.white),

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

                // 🍕 Categorias
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

                // 📦 Lista de produtos
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

                      final filtrados = snapshot.data!.docs.where((doc) {
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

                        return matchCategoria && nome.contains(pesquisa);
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
