import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mana_lanche/screens/login_screens.dart';
import 'package:mana_lanche/screens/carrinho_screens.dart';
import 'dart:async';
class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() =>
      _ClientScreenState();
}



class _ClientScreenState extends State<ClientScreen> {

  String nomeCliente = "";
  bool carregando = true;

  List<Map<String, dynamic>> carrinho = [];

  String categoriaSelecionada = "todos";

  int animatingIndex = -1;

  int fraseIndex = 0;

  final pesquisaController = TextEditingController();

  String pesquisa = "";

  final PageController bannerController = PageController();

  int bannerAtual = 0;

  StreamSubscription? pedidosSub; // ✅ CORRIGIDO (com espaço)

  String? ultimoStatus;

  String? pedidoIdAtual;

  final List<String> banners = [
    "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
    "https://images.unsplash.com/photo-1513104890138-7c749659a591",
    "https://images.unsplash.com/photo-1550547660-d9450f859349",
  ];

  final List<String> frases = [
    "🔥 Impossível resistir",
    "🍔 Fome bateu? A gente resolve!",
    "😋 Sabor que conquista no primeiro pedaço",
    "🚀 Peça agora e mate sua fome!",
    "💥 Promoções imperdíveis",
    "🍟 Combos que valem a pena",
  ];

  @override
  void initState() {
    super.initState();

    carregarNome();
    iniciarFrases();
    iniciarBanner();
    
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    bannerController.dispose();

    pedidosSub?.cancel(); // 🔥 IMPORTANTE

    super.dispose();
  }

  // 🔥 ESCUTAR MUDANÇA DO PEDIDO
  void escutarPedidoUnico() {
  if (pedidoIdAtual == null) return;

  pedidosSub = FirebaseFirestore.instance
      .collection("pedidos")
      .doc(pedidoIdAtual)
      .snapshots()
      .listen((doc) {

    final data = doc.data();
    if (data == null) return;

    final status = data["status"];

    if (ultimoStatus != status) {
      ultimoStatus = status;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(

  SnackBar(

    behavior: SnackBarBehavior.floating,

    backgroundColor: Colors.transparent,

    elevation: 0,

    duration: const Duration(seconds: 3),

    content: Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [

            Color(0xFF7A2323),
            Color(0xFFB33939),

          ],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withValues(alpha: 0.25),

            blurRadius: 10,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(

              color: Colors.white.withValues(alpha: 0.15),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(

              status == "Entregue"
                  ? Icons.check_circle
                  : status == "Saiu entrega"
                      ? Icons.delivery_dining
                      : Icons.restaurant,

              color: Colors.white,

              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [

                const Text(

                  "Pedido Atualizado",

                  style: TextStyle(

                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(

                  "Seu pedido agora está: $status",

                  style: const TextStyle(

                    color: Colors.white70,
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
  });
}
  // 🔥 FRASES
  void iniciarFrases() {

    Future.doWhile(() async {

      await Future.delayed(
        const Duration(seconds: 4),
      );

      if (!mounted) return false;

      setState(() {

        fraseIndex =
            (fraseIndex + 1) %
                frases.length;
      });

      return true;
    });
  }

  // 🔥 BANNER AUTO
  void iniciarBanner() {

    Future.doWhile(() async {

      await Future.delayed(
        const Duration(seconds: 4),
      );

      if (!mounted) return false;

      bannerAtual++;

      if (bannerAtual >=
          banners.length) {

        bannerAtual = 0;
      }

      bannerController.animateToPage(

        bannerAtual,

        duration:
            const Duration(
          milliseconds: 600,
        ),

        curve: Curves.easeInOut,
      );

      return true;
    });
  }

  // 🔥 NOME USUÁRIO
  Future<void> carregarNome() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(user.uid)
            .get();

    if (!mounted) return;

    setState(() {

      nomeCliente = doc.exists
          ? doc["nome"] ?? "Cliente"
          : "Cliente";

      carregando = false;
    });
  }

  // 🔥 CARRINHO
  void adicionarAoCarrinho(
  String nome,
  dynamic preco,
  int index,
  String imagem,
) async {

  setState(() {
    animatingIndex = index;
  });

  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  setState(() {

    final i = carrinho.indexWhere(
      (item) => item["nomeProduto"] == nome,
    );

    if (i >= 0) {

      carrinho[i]["quantidade"]++;

    } else {

      carrinho.add({
        "nomeProduto": nome,
        "preco": preco,
        "quantidade": 1,

        // 🔥 ISSO É O MAIS IMPORTANTE
        "imagem": imagem,
      });
    }

    animatingIndex = -1;
  });


    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        backgroundColor:
            const Color(0xFF7A2323),

        content: Text(
          "🍔 $nome adicionado ao carrinho",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(

      extendBodyBehindAppBar: true,

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        centerTitle: true,

        title: const Text(

          "MANÁ LANCHES",

          style: TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,

            letterSpacing: 1,
          ),
        ),

        leading: Padding(

          padding:
              const EdgeInsets.only(
            left: 12,
          ),

          child: Container(

            decoration:
                BoxDecoration(

              color: Colors.white
                  .withValues(alpha: 0.10),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: IconButton(

              icon: const Icon(

                Icons.logout,

                color: Colors.white,
              ),

              onPressed: () {

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const LoginScreen(),
                  ),
                );
              },
            ),
          ),
        ),

        actions: [

          Padding(

            padding:
                const EdgeInsets.only(
              right: 12,
            ),

            child: Stack(

              children: [

                Container(

                  decoration:
                      BoxDecoration(

                    color: Colors.white
                        .withValues(
                            alpha: 0.10),

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  child: IconButton(

                    icon: const Icon(

                      Icons.shopping_cart,

                      color: Colors.white,
                    ),

                    onPressed: () async {

                    final pedidoId = await Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              CarrinhoScreen(

                            carrinho:
                                carrinho,

                            nomeCliente: nomeCliente,
                          ),
                        ),
                      );
                      if (pedidoId != null) {

                        pedidoIdAtual = pedidoId;

                        escutarPedidoUnico();
                      }
                    },
                  ),
                ),

                if (carrinho.isNotEmpty)

                  Positioned(

                    right: 2,
                    top: 2,

                    child: Container(

                      padding:
                          const EdgeInsets.all(
                        5,
                      ),

                      decoration:
                          BoxDecoration(

                        color: Colors.red,

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Text(

                        carrinho.length
                            .toString(),

                        style:
                            const TextStyle(

                          color:
                              Colors.white,

                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Container(

        width: double.infinity,

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: isDark
                ? [

                    const Color(
                        0xFF111111),

                    const Color(
                        0xFF1B1B1B),

                    const Color(
                        0xFF252525),
                  ]
                : [

                    const Color(
                        0xFF5C1A1B),

                    const Color(
                        0xFF7A2323),

                    const Color(
                        0xFF9B2C2C),

                    const Color(
                        0xFFB33939),
                  ],

            begin: Alignment.topLeft,

            end:
                Alignment.bottomRight,
          ),
        ),

        child: SafeArea(

          child: Padding(

            padding:
                const EdgeInsets.all(
              20,
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  carregando
                      ? "Carregando..."
                      : "Olá, $nomeCliente 👋",

                  style: const TextStyle(

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                AnimatedSwitcher(

                  duration:
                      const Duration(
                    milliseconds: 500,
                  ),

                  child: Text(

                    frases[fraseIndex],

                    key: ValueKey(
                      frases[fraseIndex],
                    ),

                    style:
                        const TextStyle(

                      color:
                          Colors.white70,

                      fontSize: 16,

                      fontStyle:
                          FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 CARROSSEL
                SizedBox(

                  height: 220,

                  child:
                      PageView.builder(

                    controller:
                        bannerController,

                    itemCount:
                        banners.length,

                    itemBuilder:
                        (_, index) {

                      return Container(

                        margin:
                            const EdgeInsets.only(
                          right: 8,
                        ),

                        decoration:
                            BoxDecoration(

                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),

                          boxShadow: [

                            BoxShadow(

                              color: Colors
                                  .black
                                  .withValues(
                                      alpha:
                                          0.30),

                              blurRadius:
                                  20,

                              offset:
                                  const Offset(
                                0,
                                10,
                              ),
                            ),
                          ],
                        ),

                        child: ClipRRect(

                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),

                          child: Stack(

                            children: [

                              Positioned.fill(

                                child:
                                    Image.network(

                                  banners[
                                      index],

                                  fit:
                                      BoxFit.cover,
                                ),
                              ),

                              Positioned.fill(

                                child:
                                    Container(

                                  decoration:
                                      BoxDecoration(

                                    gradient:
                                        LinearGradient(

                                      begin:
                                          Alignment.topCenter,

                                      end:
                                          Alignment.bottomCenter,

                                      colors: [

                                        Colors.black.withValues(
                                            alpha:
                                                0.15),

                                        Colors.black.withValues(
                                            alpha:
                                                0.80),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(

                                left: 24,
                                bottom: 24,

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    const Text(

                                      "MANÁ LANCHES 🍔",

                                      style:
                                          TextStyle(

                                        color:
                                            Colors.white,

                                        fontSize:
                                            28,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            8),

                                    Text(

                                      "Peça agora e receba rápido",

                                      style:
                                          TextStyle(

                                        color: Colors
                                            .white
                                            .withValues(
                                                alpha:
                                                    0.80),

                                        fontSize:
                                            15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 PESQUISA
                Container(

                  decoration:
                      BoxDecoration(

                    color: Colors.white
                        .withValues(
                            alpha: 0.10),

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),

                    border: Border.all(
                      color:
                          Colors.white24,
                    ),
                  ),

                  child: TextField(

                    controller:
                        pesquisaController,

                    onChanged: (value) {

                      setState(() {

                        pesquisa = value
                            .toLowerCase();
                      });
                    },

                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),

                    decoration:
                        const InputDecoration(

                      hintText:
                          "Pesquisar produto...",

                      hintStyle:
                          TextStyle(
                        color:
                            Colors.white60,
                      ),

                      prefixIcon:
                          Icon(

                        Icons.search,

                        color:
                            Colors.white70,
                      ),

                      border:
                          InputBorder.none,

                      contentPadding:
                          EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // 🔥 CATEGORIAS
                SizedBox(

                  height: 52,

                  child: ListView(

                    scrollDirection:
                        Axis.horizontal,

                    children: [

                      categoriaChip(
                          "todos"),

                      categoriaChip(
                          "Hamburguer"),

                      categoriaChip(
                          "pizza"),

                      categoriaChip(
                          "bebida"),

                      categoriaChip(
                          "combos"),

                      categoriaChip(
                          "batatas"),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(

                  "Produtos",

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(

                  child: StreamBuilder<
                      QuerySnapshot>(

                    stream:
                        FirebaseFirestore
                            .instance
                            .collection(
                                "produtos")
                            .orderBy(
                                "nome")
                            .snapshots(),

                    builder:
                        (context, snapshot) {

                      if (!snapshot
                          .hasData) {

                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      final docs =
                          snapshot
                              .data!
                              .docs;

                      final filtrados =
                          docs.where((doc) {

                        final data =
                            doc.data()
                                as Map<
                                    String,
                                    dynamic>;

                        final categoria =
                            (data["categoria"] ??
                                    "")
                                .toString()
                                .toLowerCase();

                        final nome =
                            (data["nome"] ??
                                    "")
                                .toString()
                                .toLowerCase();

                        final categoriaOk =
                            categoriaSelecionada ==
                                    "todos"
                                ? true
                                : categoria == categoriaSelecionada.toLowerCase();

                        final pesquisaOk =
                            nome.contains(
                                pesquisa);

                        return categoriaOk &&
                            pesquisaOk;

                      }).toList();

                      return ListView.builder(

                        itemCount:
                            filtrados.length,

                        itemBuilder:
                            (context, index) {

                          final doc =
                              filtrados[index];

                          final data =
                              doc.data()
                                  as Map<
                                      String,
                                      dynamic>;

                          return foodItem(

                            data["nome"] ??
                                "",

                            data["preco"] ??
                                0,

                            data["imagem"] ??
                                "",

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

  // 🔥 CHIP CATEGORIA
  Widget categoriaChip(
      String titulo) {

    final selecionado =
        categoriaSelecionada
                .toLowerCase() ==
            titulo.toLowerCase();

    return GestureDetector(

      onTap: () {

        setState(() {

          categoriaSelecionada =
              titulo.toLowerCase();
        });
      },

      child: AnimatedContainer(

        duration:
            const Duration(
          milliseconds: 250,
        ),

        margin:
            const EdgeInsets.only(
          right: 12,
        ),

        padding:
            const EdgeInsets.symmetric(

          horizontal: 22,
          vertical: 12,
        ),

        decoration: BoxDecoration(

          gradient: selecionado
              ? const LinearGradient(

                  colors: [

                    Color(
                        0xFFFFD166),

                    Color(
                        0xFFFFB703),
                  ],
                )
              : null,

          color: selecionado
              ? null
              : Colors.white
                  .withValues(
                      alpha: 0.10),

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border: Border.all(

            color: Colors.white
                .withValues(
                    alpha: 0.12),
          ),
        ),

        child: Text(

          titulo,

          style: TextStyle(

            color: selecionado
                ? Colors.black
                : Colors.white,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🔥 CARD PRODUTO
  Widget foodItem(

    String nome,

    dynamic preco,

    String imagem,

    int index,
  ) {

    final isAnimating =
        animatingIndex == index;

    return AnimatedScale(

      duration:
          const Duration(
        milliseconds: 200,
      ),

      scale:
          isAnimating ? 0.97 : 1,

      child: Container(

        margin:
            const EdgeInsets.only(
          bottom: 20,
        ),

        decoration: BoxDecoration(

          color: Colors.white
              .withValues(
                  alpha: 0.10),

          borderRadius:
              BorderRadius.circular(
            28,
          ),

          border: Border.all(

            color: Colors.white
                .withValues(
                    alpha: 0.12),
          ),

          boxShadow: [

            BoxShadow(

              color: Colors.black
                  .withValues(
                      alpha: 0.18),

              blurRadius: 18,

              offset:
                  const Offset(
                0,
                8,
              ),
            ),
          ],
        ),

        child: Row(

          children: [

            ClipRRect(

              borderRadius:
                  const BorderRadius.only(

                topLeft:
                    Radius.circular(
                        28),

                bottomLeft:
                    Radius.circular(
                        28),
              ),

              child: Image.network(

                imagem,

                width: 120,
                height: 120,

                fit: BoxFit.cover,

                errorBuilder:
                    (_, __, ___) {

                  return Container(

                    width: 120,
                    height: 120,

                    color:
                        Colors.black12,

                    child: const Icon(

                      Icons.fastfood,

                      color:
                          Colors.white,

                      size: 40,
                    ),
                  );
                },
              ),
            ),

            Expanded(

              child: Padding(

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(

                      nome,

                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                        fontSize:
                            20,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Container(

                      padding:
                          const EdgeInsets.symmetric(

                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(

                        color: const Color(
                          0xFFFFD166,
                        ).withValues(
                            alpha:
                                0.18),

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),

                      child: Text(

                        "R\$ ${double.parse(preco.toString()).toStringAsFixed(2)}",

                        style:
                            const TextStyle(

                          color: Color(
                              0xFFFFD166),

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    SizedBox(

                      width:
                          double.infinity,

                      height: 46,

                      child:
                          ElevatedButton(

                        style:
                            ElevatedButton.styleFrom(

                          backgroundColor:
                              const Color(
                            0xFF7A2323,
                          ),

                          elevation: 6,

                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        onPressed: () {

                          adicionarAoCarrinho(

                            nome,

                            preco,
                            
                            index,

                            imagem,

                          );
                        },

                        child: Text(

                          isAnimating
                              ? "✔ Adicionado"
                              : "Adicionar",

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
