import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // 🔥 CONTROLLERS
  final enderecoController = TextEditingController();
  final observacaoController = TextEditingController();

  String formaPagamento = "Dinheiro";
  bool _enderecoCarregado = false;

  @override
  void initState() {
    super.initState();
    _carregarEnderecoUsuario();
  }

  Future<void> _carregarEnderecoUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    final dados = doc.data();
    final endereco = dados?['endereco']?.toString().trim() ?? '';

    if (endereco.isNotEmpty && enderecoController.text.trim().isEmpty) {
      enderecoController.text = endereco;
    }

    setState(() {
      _enderecoCarregado = true;
    });
  }

  @override
  void dispose() {
    enderecoController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  double converterPreco(dynamic preco) {
    if (preco is String) {
      return double.tryParse(
            preco.replaceAll(",", "."),
          ) ??
          0;
    } else if (preco is num) {
      return preco.toDouble();
    }

    return 0;
  }

  double get total {
    return widget.carrinho.fold(0.0, (total, item) {
      return total +
          (converterPreco(item["preco"]) *
              item["quantidade"]);
    });
  }

  void aumentar(int i) {
    setState(() {
      widget.carrinho[i]["quantidade"]++;
    });
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

  // 🔥 ABRIR MODAL
  Future<void> abrirFormularioPedido() async {

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {

        final isDark =
            Theme.of(context).brightness ==
                Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        20,
              ),

              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B1B1B)
                    : Colors.white,

                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Center(
                      child: Container(
                        width: 60,
                        height: 5,

                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Finalizar Pedido 🍔",

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,

                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 ENDEREÇO
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Endereço de entrega",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            enderecoController.clear();
                          },
                          icon: const Icon(
                            Icons.edit_location,
                          ),
                          label: const Text(
                            "Trocar",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller:
                          enderecoController,

                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),

                      decoration: InputDecoration(
                        labelText: "Endereço",
                        hintText:
                            "Use o endereço cadastrado ou altere aqui",

                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : Colors.black54,
                        ),

                        prefixIcon: const Icon(
                          Icons.location_on,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔥 FORMA PAGAMENTO
                    DropdownButtonFormField<String>(
                      value: formaPagamento,

                      dropdownColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.white,

                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),

                      decoration: InputDecoration(
                        labelText:
                            "Forma de pagamento",

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),

                        prefixIcon: const Icon(
                          Icons.payment,
                        ),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "Dinheiro",
                          child: Text("Dinheiro"),
                        ),
                        DropdownMenuItem(
                          value: "Pix",
                          child: Text("Pix"),
                        ),
                        DropdownMenuItem(
                          value: "Cartão",
                          child: Text("Cartão"),
                        ),
                      ],

                      onChanged: (value) {
                        setModalState(() {
                          formaPagamento =
                              value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔥 OBS
                    TextField(
                      controller:
                          observacaoController,

                      maxLines: 4,

                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),

                      decoration: InputDecoration(
                        labelText: "Observação",

                        hintText:
                            "Ex: sem cebola, troco para 50...",

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),

                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(
                            bottom: 70,
                          ),
                          child: Icon(
                            Icons.edit_note,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        onPressed: () async {

                          Navigator.pop(context);

                          await finalizar();
                        },

                        icon: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                        ),

                        label: const Text(
                          "Confirmar Pedido",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 FINALIZAR PEDIDO
  Future<void> finalizar() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (widget.carrinho.isEmpty) return;

    if (enderecoController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Por favor, informe o endereço de entrega antes de finalizar.",
          ),
        ),
      );
      return;
    }

    try {

      List<Map<String, dynamic>>
          itensPedido = [];

      // 🔥 TEXTO WHATSAPP
      String mensagem =
          "🍔 *NOVO PEDIDO - MANÁ LANCHES* \n\n";

      for (var item in widget.carrinho) {

        itensPedido.add({
          "nomeProduto":
              item["nomeProduto"],
          "preco": item["preco"],
          "quantidade":
              item["quantidade"],
          "imagem":
              item["imagem"] ?? "",
        });

        mensagem +=
            "• ${item["nomeProduto"]} ${item["quantidade"]}\n";
      }

      mensagem +=
          "\n💰 *Total:* R\$ ${total.toStringAsFixed(2)}";

      mensagem +=
          "\n\n👤 *Cliente:* ${widget.nomeCliente}";

      mensagem +=
          "\n📍 *Endereço:* ${enderecoController.text}";

      mensagem +=
          "\n💳 *Pagamento:* $formaPagamento";

      if (observacaoController
          .text
          .trim()
          .isNotEmpty) {

        mensagem +=
            "\n📝 *Observação:* ${observacaoController.text}";
      }

      // 🔥 SALVAR FIREBASE
      final pedidoRef =
          await FirebaseFirestore.instance
              .collection("pedidos")
              .add({

        "itens": itensPedido,
        "usuarioId": user!.uid,
        "telefone":
            user.phoneNumber ?? "",

        "nomeCliente":
            widget.nomeCliente,

        "endereco":
            enderecoController.text,

        "formaPagamento":
            formaPagamento,

        "observacao":
            observacaoController.text,

        "status": "Pendente",

        "total": total,

        "data":
            FieldValue.serverTimestamp(),
      });

      final pedidoId = pedidoRef.id;

      // 🔥 NÚMERO
      final numero = "5595984131557";

      // 🔥 APP WHATSAPP
      final Uri whatsappUrl = Uri.parse(
        "whatsapp://send?phone=$numero&text=${Uri.encodeComponent(mensagem)}",
      );

      // 🔥 WEB
      final Uri webUrl = Uri.parse(
        "https://wa.me/$numero?text=${Uri.encodeComponent(mensagem)}",
      );

      bool abriuWhatsapp = false;

      // 🔥 ABRIR APP
      if (await canLaunchUrl(
        whatsappUrl,
      )) {

        abriuWhatsapp =
            await launchUrl(
          whatsappUrl,
          mode:
              LaunchMode.externalApplication,
        );
      }

      // 🔥 FALLBACK WEB
      if (!abriuWhatsapp) {

        abriuWhatsapp =
            await launchUrl(
          webUrl,
          mode:
              LaunchMode.externalApplication,
        );
      }

      if (!mounted) return;

      // 🔥 FEEDBACK
      if (abriuWhatsapp) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            backgroundColor:
                Colors.green,

            content: Text(
              "WhatsApp aberto com sucesso!",
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            backgroundColor:
                Colors.red,

            content: Text(
              "Não foi possível abrir o WhatsApp",
            ),
          ),
        );
      }

      // 🔥 LIMPA CARRINHO
      setState(() {
        widget.carrinho.clear();
      });

      Navigator.pop(
        context,
        pedidoId,
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red,

          content: Text(
            "Erro ao finalizar pedido: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Seu carrinho",
        ),
        centerTitle: true,
      ),

      body: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(
                      0xFF121212,
                    ),
                    const Color(
                      0xFF0D0D0D,
                    ),
                  ]
                : [
                    const Color(
                      0xFFDB1F26,
                    ),
                    const Color(
                      0xFFB70F1D,
                    ),
                  ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(

          child: widget.carrinho.isEmpty

              ? const Center(
                  child: Text(
                    "Carrinho vazio",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                )

              : Column(
                  children: [

                    // 🔥 LISTA
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          10,
                        ),

                        itemCount:
                            widget.carrinho.length,

                        itemBuilder:
                            (context, i) {

                          final item =
                              widget.carrinho[i];

                          final preco =
                              converterPreco(
                            item["preco"],
                          );

                          return Container(
                            margin:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),

                            padding:
                                const EdgeInsets.all(
                              14,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  theme.cardColor,

                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),

                            child: Row(
                              children: [

                                // 🔥 IMAGEM
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),

                                  child:
                                      Image.network(
                                    item["imagem"] ??
                                        "",

                                    width: 70,
                                    height: 70,

                                    fit:
                                        BoxFit.cover,

                                    errorBuilder:
                                        (_, __,
                                            ___) {

                                      return Container(
                                        width: 70,
                                        height: 70,

                                        color: Colors
                                            .grey,

                                        child:
                                            const Icon(
                                          Icons
                                              .fastfood,

                                          color: Colors
                                              .white,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                // 🔥 INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        item[
                                                "nomeProduto"]
                                            .toString(),

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              16,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        "R\$ ${preco.toStringAsFixed(2)}",

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🔥 QUANTIDADE
                                Container(
                                  decoration:
                                      BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[
                                            800]
                                        : Colors.grey[
                                            200],

                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),

                                  child: Row(
                                    children: [

                                      IconButton(
                                        icon:
                                            const Icon(
                                          Icons
                                              .remove,
                                        ),

                                        onPressed:
                                            () {
                                          diminuir(
                                              i);
                                        },
                                      ),

                                      Text(
                                        item[
                                                "quantidade"]
                                            .toString(),

                                        style:
                                            const TextStyle(
                                          fontSize:
                                              16,
                                        ),
                                      ),

                                      IconButton(
                                        icon:
                                            const Icon(
                                          Icons.add,
                                        ),

                                        onPressed:
                                            () {
                                          aumentar(
                                              i);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // 🔥 TOTAL
                    Container(
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),

                      decoration:
                          BoxDecoration(
                        color: theme.cardColor,

                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(
                            24,
                          ),
                        ),
                      ),

                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              const Text(
                                "Total",

                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),

                              Text(
                                "R\$ ${total.toStringAsFixed(2)}",

                                style: TextStyle(
                                  fontSize: 20,

                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  color: theme
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            height: 52,

                            child:
                                ElevatedButton.icon(

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.green,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),

                              onPressed:
                                  abrirFormularioPedido,

                              icon: const Icon(
                                Icons.shopping_bag,
                                color:
                                    Colors.white,
                              ),

                              label: const Text(
                                "Enviar Pedido",

                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
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