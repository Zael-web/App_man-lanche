import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mana_lanche/screens/login_screens.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _carregando = true;

  String nome = "Cliente";
  String email = "";
  String telefone = "Não informado";
  String endereco = "Não informado";
  String fotoUrl = "";
  String tipoUsuario = "cliente";

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  Future<void> carregarPerfil() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final doc =
        await _firestore.collection("usuarios").doc(user.uid).get();

    if (!mounted) return;

    final dados = doc.data();

    setState(() {
      nome =
          dados?['nome']?.toString() ??
          user.displayName ??
          'Cliente';

      email =
          dados?['email']?.toString() ??
          user.email ??
          '';

      telefone =
          dados?['telefone']?.toString() ??
          user.phoneNumber ??
          'Não informado';

      endereco =
          dados?['endereco']?.toString() ??
          'Não informado';

      fotoUrl = user.photoURL ?? '';

      tipoUsuario =
          dados?['tipo']?.toString() ?? 'cliente';

      _carregando = false;
    });
  }

  Future<void> sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sair da conta"),
          content: const Text(
            "Deseja sair da sua conta?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Sair",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirmar) return;

    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void abrirEdicao() async {
    final atualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          nome: nome,
          telefone:
              telefone == 'Não informado'
                  ? ''
                  : telefone,
          endereco:
              endereco == 'Não informado'
                  ? ''
                  : endereco,
        ),
      ),
    );

    if (atualizado == true) {
      carregarPerfil();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,

        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),

          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF111111),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF222222),
                    const Color(0xFF2C2C2C),
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
          child: _carregando
              ? const Center(
                  child: CircularProgressIndicator(),
                )

              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                    children: [

                      const SizedBox(height: 10),

                      // 🔥 CARD PERFIL
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.08,
                          ),

                          borderRadius:
                              BorderRadius.circular(20),

                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,

                            children: [

                              CircleAvatar(
                                radius: 52,

                                backgroundColor:
                                    theme
                                        .colorScheme
                                        .primary,

                                backgroundImage:
                                    fotoUrl.isNotEmpty
                                        ? NetworkImage(
                                            fotoUrl,
                                          )
                                        : null,

                                child: fotoUrl.isEmpty
                                    ? Text(
                                        nome.isNotEmpty
                                            ? nome[0]
                                                .toUpperCase()
                                            : 'U',

                                        style:
                                            const TextStyle(
                                          fontSize: 36,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : null,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                nome,

                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                email,

                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                      tipoUsuario == "admin"
                                          ? Colors.orange
                                          : Colors.green,

                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Text(
                                  tipoUsuario == "admin"
                                      ? "Administrador"
                                      : "Cliente",

                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white
                                          .withValues(
                                    alpha: 0.12,
                                  ),
                                ),

                                onPressed: abrirEdicao,

                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),

                                label: const Text(
                                  'Editar perfil',

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔥 DADOS
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.08,
                          ),

                          borderRadius:
                              BorderRadius.circular(20),

                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              const Text(
                                'Dados de contato',

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 14),

                              _infoLinha(
                                Icons.phone,
                                'Telefone',
                                telefone,
                              ),

                              const SizedBox(height: 12),

                              _infoLinha(
                                Icons.location_on,
                                'Endereço',
                                endereco,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white
                                        .withValues(
                                  alpha: 0.12,
                                ),
                              ),

                              onPressed:
                                  abrirEdicao,

                              icon: const Icon(
                                Icons.edit_location,
                                color: Colors.white,
                              ),

                              label: const Text(
                                'Editar perfil',

                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              onPressed: sair,
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Sair',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _infoLinha(
    IconData icon,
    String titulo,
    String valor,
  ) {

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Icon(
          icon,
          size: 22,
          color: Colors.white,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                titulo,

                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                valor,

                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 🔥 EDITAR PERFIL
class EditProfileScreen extends StatefulWidget {

  final String nome;
  final String telefone;
  final String endereco;

  const EditProfileScreen({
    super.key,
    required this.nome,
    required this.telefone,
    required this.endereco,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final _auth = FirebaseAuth.instance;
  final _firestore =
      FirebaseFirestore.instance;

  final nomeController =
      TextEditingController();

  final telefoneController =
      TextEditingController();

  final enderecoController =
      TextEditingController();

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    nomeController.text = widget.nome;

    telefoneController.text =
        widget.telefone;

    enderecoController.text =
        widget.endereco;
  }

  Future<void> salvar() async {

    final user = _auth.currentUser;

    if (user == null) return;

    setState(() {
      _salvando = true;
    });

    await _firestore
        .collection('usuarios')
        .doc(user.uid)
        .update({

      'nome':
          nomeController.text.trim(),

      'telefone':
          telefoneController.text.trim(),

      'endereco':
          enderecoController.text.trim(),
    });

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          'Editar perfil',
        ),

        centerTitle: true,

        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),

          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5C1A1B),
              Color(0xFF7A2323),
              Color(0xFF9B2C2C),
              Color(0xFFB33939),
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              children: [

                TextField(
                  controller: nomeController,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(
                    labelText: 'Nome',

                    labelStyle:
                        const TextStyle(
                      color: Colors.white70,
                    ),

                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),

                    filled: true,

                    fillColor:
                        Colors.white.withValues(
                      alpha: 0.08,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                      telefoneController,

                  keyboardType:
                      TextInputType.phone,

                  inputFormatters: [

                    FilteringTextInputFormatter
                        .digitsOnly,

                    LengthLimitingTextInputFormatter(
                      11,
                    ),

                    _TelefoneInputFormatter(),
                  ],

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(
                    labelText: 'Telefone',

                    labelStyle:
                        const TextStyle(
                      color: Colors.white70,
                    ),

                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),

                    filled: true,

                    fillColor:
                        Colors.white.withValues(
                      alpha: 0.08,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                      enderecoController,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(
                    labelText: 'Endereço',

                    labelStyle:
                        const TextStyle(
                      color: Colors.white70,
                    ),

                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),

                    filled: true,

                    fillColor:
                        Colors.white.withValues(
                      alpha: 0.08,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.orange,
                    ),

                    onPressed:
                        _salvando
                            ? null
                            : salvar,

                    child: _salvando
                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )
                        : const Text(
                            'Salvar alterações',
                          ),
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

// 🔥 FORMATADOR TELEFONE
class _TelefoneInputFormatter
    extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    String text =
        newValue.text.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String formatted = '';

    if (text.isNotEmpty) {

      formatted +=
          '(${text.substring(0, text.length >= 2 ? 2 : text.length)}';
    }

    if (text.length >= 3) {

      formatted += ') ';

      formatted += text.substring(
        2,
        text.length >= 7
            ? 7
            : text.length,
      );
    }

    if (text.length >= 8) {

      formatted += '-';

      formatted += text.substring(7);
    }

    return TextEditingValue(
      text: formatted,

      selection:
          TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}