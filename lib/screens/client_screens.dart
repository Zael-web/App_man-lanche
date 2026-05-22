import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



import 'package:mana_lanche/screens/carrinho_screens.dart';
import 'package:mana_lanche/screens/perfil_screens.dart';



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

  final pesquisaController = TextEditingController();

  String pesquisa = "";

  final PageController bannerController = PageController();

  int bannerAtual = 0;

  StreamSubscription? pedidosSub;

  String? ultimoStatus;

  String? pedidoIdAtual;

  bool _notificacoesIniciadas = false;

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

  Future.microtask(() async {
    if (_notificacoesIniciadas) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _notificacoesIniciadas = true;
      await _initNotificationsSafe(user.uid);
    }
  });
}

  @override
  void dispose() {
    pesquisaController.dispose();
    bannerController.dispose();

    pedidosSub?.cancel();

    super.dispose();
  }

  // 🔥 ESCUTAR PEDIDO
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

ScaffoldMessenger.of(context).clearSnackBars();

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    behavior: SnackBarBehavior.floating,

    margin: const EdgeInsets.only(
      top: 20,
      left: 12,
      right: 12,
      bottom: 700,
    ),

    backgroundColor: const Color.fromARGB(255, 230, 215, 0),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),

    duration: const Duration(seconds: 4),

    content: Row(
      children: [
        const Icon(
          Icons.notifications_active,
          color: Colors.white,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            "🍔 Seu pedido agora está: $status",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return false;

      setState(() {
        fraseIndex = (fraseIndex + 1) % frases.length;
      });

      return mounted;
    });
  }

  // 🔥 BANNER
  void iniciarBanner() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return false;

      if (!bannerController.hasClients) return false;

      bannerAtual++;

      if (bannerAtual >= banners.length) {
        bannerAtual = 0;
      }

      await bannerController.animateToPage(
        bannerAtual,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      return mounted;
    });
  }

  // 🔥 CARREGAR NOME
  Future<void> carregarNome() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
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
Future<void> _initNotificationsSafe(String uid) async {
  try {
    final messaging = FirebaseMessaging.instance;

    // 🔥 NÃO trava se usuário recusar
    final permission = await messaging.requestPermission();

    if (permission.authorizationStatus ==
        AuthorizationStatus.denied) {
      debugPrint("Usuário negou notificações");
      return;
    }

    final token = await messaging.getToken();

    if (token == null) {
      debugPrint("Token nulo");
      return;
    }

    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .set({
      "fcmToken": token,
    }, SetOptions(merge: true));

  } catch (e) {
    debugPrint("FCM ignorado (seguro): $e");
  }
}
  // 🔥 ADICIONAR AO CARRINHO
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
          "imagem": imagem,
        });
      }

      animatingIndex = -1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF7A2323),
        content: Text("🍔 $nome adicionado"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "MANÁ LANCHES",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerfilScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),

                  onPressed: () async {
                    final pedidoId =
                        await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarrinhoScreen(
                          carrinho: carrinho,
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

                if (carrinho.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,

                    child: Container(
                      padding: const EdgeInsets.all(5),

                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Text(
                        carrinho.length.toString(),

                        style: const TextStyle(
                          color: Colors.white,
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
                    const Color(0xFF111111),
                    const Color(0xFF1B1B1B),
                    const Color(0xFF252525),
                  ]
                : [
                    const Color(0xFF5C1A1B),
                    const Color(0xFF7A2323),
                    const Color(0xFF9B2C2C),
                    const Color(0xFFB33939),
                  ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),

            slivers: [
              // 🔥 TOPO
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),

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
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 500,
                        ),

                        child: Text(
                          frases[fraseIndex],

                          key: ValueKey(
                            frases[fraseIndex],
                          ),

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 🔥 BANNER
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,

                  child: PageView.builder(
                    controller: bannerController,

                    itemCount: banners.length,

                    itemBuilder: (_, index) {
                      return Container(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.30),

                              blurRadius: 20,

                              offset:
                                  const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(30),

                          child: Stack(
                            fit: StackFit.expand,

                            children: [
                              Image.network(
                                banners[index],
                                fit: BoxFit.cover,
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  gradient:
                                      LinearGradient(
                                    begin:
                                        Alignment.topCenter,

                                    end:
                                        Alignment.bottomCenter,

                                    colors: [
                                      Colors.black
                                          .withValues(alpha: 0.15),

                                      Colors.black
                                          .withValues(alpha: 0.80),
                                    ],
                                  ),
                                ),
                              ),

                              const Positioned(
                                left: 20,
                                bottom: 20,

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    Text(
                                      "MANÁ LANCHES 🍔",

                                      style: TextStyle(
                                        color:
                                            Colors.white,

                                        fontSize: 24,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      "Peça agora e receba rápido",

                                      style: TextStyle(
                                        color:
                                            Colors.white70,
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
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              // 🔥 PESQUISA
              SliverToBoxAdapter(
                child: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),

  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.10), // 🔥 transparência
      borderRadius: BorderRadius.circular(18),

      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
      ),
    ),

    child: TextField(
      controller: pesquisaController,

      onChanged: (value) {
        setState(() {
          pesquisa = value.toLowerCase();
        });
      },

      style: const TextStyle(
        color: Colors.white,
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

        filled: true,

        
        fillColor: Colors.transparent,

        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
      ),
    ),
  ),
),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 18),
              ),

              // 🔥 CATEGORIAS
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 45,

                  child: ListView(
                    scrollDirection:
                        Axis.horizontal,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

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
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 18),
              ),

              // 🔥 TÍTULO
              const SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: Text(
                    "Produtos",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),

              // 🔥 PRODUTOS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore
                    .instance
                    .collection("produtos")
                    .orderBy("nome")
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    );
                  }

                  final docs =
                      snapshot.data!.docs;

                  final filtrados =
                      docs.where((doc) {
                    final data =
                        doc.data()
                            as Map<String, dynamic>;

                    final categoria =
                        (data["categoria"] ?? "")
                            .toString()
                            .toLowerCase();

                    final nome =
                        (data["nome"] ?? "")
                            .toString()
                            .toLowerCase();

                    final categoriaOk =
                        categoriaSelecionada ==
                                "todos"
                            ? true
                            : categoria ==
                                categoriaSelecionada;

                    final pesquisaOk =
                        nome.contains(pesquisa);

                    return categoriaOk &&
                        pesquisaOk;
                  }).toList();

                  return SliverList(
                    delegate:
                        SliverChildBuilderDelegate(
                      (context, index) {
                        final data =
                            filtrados[index].data()
                                as Map<
                                  String,
                                  dynamic
                                >;

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

child: foodItem(
  data["nome"] ?? "",
  data["preco"] ?? 0,
  data["imagem"] ?? "",
  index,
  data["descricao"] ?? "",
  data["ingredientes"] ?.toString() ?? "",
),
                        );
                      },

                      childCount:
                          filtrados.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 CATEGORIAS
  Widget categoriaChip(String titulo) {
    final selecionado =
        categoriaSelecionada == titulo;

    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSelecionada = titulo;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),

        margin:
            const EdgeInsets.only(right: 12),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          gradient: selecionado
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFFD166),
                    Color(0xFFFFB703),
                  ],
                )
              : null,

          color: selecionado
              ? null
              : Colors.white.withValues(alpha: 0.10),

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: Colors.white24,
          ),
        ),

        child: Text(
          titulo,

          style: TextStyle(
            color: selecionado
                ? Colors.black
                : Colors.white,

            fontWeight: FontWeight.bold,
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
  String descricao,
  String ingredientes,
) {
  final isAnimating =
      animatingIndex == index;

  return AnimatedScale(
    duration:
        const Duration(milliseconds: 180),

    scale: isAnimating ? 0.97 : 1,

    child: Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color:
            Colors.white.withValues(alpha: 0.10),

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: Colors.white24,
        ),
      ),

      child: Column(
        children: [

          // 🔥 CONTEÚDO PRINCIPAL
          Row(
            children: [

              // 🔥 IMAGEM
              ClipRRect(
                borderRadius:
                    const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft:
                      Radius.circular(22),
                ),

                child: Image.network(
                  imagem,

                  width: 95,
                  height: 120,

                  fit: BoxFit.cover,

                  errorBuilder:
                      (_, __, ___) {
                    return Container(
                      width: 95,
                      height: 120,

                      color: Colors.black12,

                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),

              // 🔥 TEXTO
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // 🔥 NOME
                      Text(
                        nome,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 🔥 DESCRIÇÃO
                      Text(
                        descricao,

                        maxLines: 2,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            TextStyle(
                          color: Colors.white
                              .withValues(alpha: 0.75),

                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔥 PREÇO
                      Text(
                        "R\$ ${double.parse(preco.toString()).toStringAsFixed(2)}",

                        style:
                            const TextStyle(
                          color:
                              Color(0xFFFFD166),

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔥 BOTÕES
                      Row(
                        children: [

                          // 🔥 VER INGREDIENTES
                          Expanded(
  child: OutlinedButton(
    style: OutlinedButton.styleFrom(
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.30),
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
    ),

    onPressed: () {
      showModalBottomSheet(
        context: context,

        backgroundColor: const Color(
          0xFF1E1E1E,
        ),

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),

        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  "Ingredientes de $nome",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                ...ingredientes.split(",").map(
                  (item) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.check_circle,

                            color: Color(
                              0xFFFFD166,
                            ),

                            size: 20,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              item.toString(),

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },

    child: const Icon(
      Icons.menu_book,
      color: Colors.white,
      size: 22,
    ),
  ),
),

                          const SizedBox(width: 10),

                          // 🔥 ADICIONAR
Expanded(
  child: SizedBox(
    height: 45,

    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            const Color.fromARGB(
          144,
          16,
          155,
          11,
        ),

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
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

      child: FittedBox(
        fit: BoxFit.scaleDown,

        child: Text(
          isAnimating
              ? "✔"
              : "Adicionar",

          maxLines: 1,

          style: const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    ),
  ),
)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
 }
}