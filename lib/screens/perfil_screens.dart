import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  Future<void> carregarPerfil() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final doc = await _firestore.collection("usuarios").doc(user.uid).get();

    if (!mounted) return;

    setState(() {
      nome = doc.data()?['nome']?.toString() ?? user.displayName ?? 'Cliente';
      email = doc.data()?['email']?.toString() ?? user.email ?? '';
      telefone = doc.data()?['telefone']?.toString() ?? user.phoneNumber ?? 'Não informado';
      endereco = doc.data()?['endereco']?.toString() ?? 'Não informado';
      fotoUrl = user.photoURL ?? '';
      _carregando = false;
    });
  }

  Future<void> sair() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void abrirEdicao() async {
    final atualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          nome: nome,
          telefone: telefone == 'Não informado' ? '' : telefone,
          endereco: endereco == 'Não informado' ? '' : endereco,
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
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
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: theme.colorScheme.primary,
                            backgroundImage:
                                fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                            child: fotoUrl.isEmpty
                                ? Text(
                                    nome.isNotEmpty ? nome[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: abrirEdicao,
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar perfil'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dados de contato',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _infoLinha(Icons.phone, 'Telefone', telefone),
                          const SizedBox(height: 12),
                          _infoLinha(Icons.location_on, 'Endereço', endereco),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: abrirEdicao,
                          icon: const Icon(Icons.edit_location),
                          label: const Text('Editar perfil'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: sair,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sair'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Histórico de pedidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _auth.currentUser == null
                        ? const Stream.empty()
                        : _firestore
                            .collection('pedidos')
                            .where('usuarioId', isEqualTo: _auth.currentUser!.uid)
                            .orderBy('data', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Nenhum pedido encontrado ainda.'),
                        );
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data();
                          final status = data['status']?.toString() ?? 'Desconhecido';
                          final total = data['total']?.toString() ?? '0,00';
                          final timestamp = data['data'] as Timestamp?;
                          final pedidoData = timestamp != null
                              ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
                              : null;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              title: Text('Pedido ${doc.id.substring(0, 6)}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Status: $status'),
                                  const SizedBox(height: 4),
                                  Text('Total: R\$ $total'),
                                  if (pedidoData != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Data: ${pedidoData.day.toString().padLeft(2, '0')}/${pedidoData.month.toString().padLeft(2, '0')}/${pedidoData.year}'),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {},
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
        ),
      ),    );
  }

  Widget _infoLinha(IconData icon, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    nomeController.text = widget.nome;
    telefoneController.text = widget.telefone;
    enderecoController.text = widget.endereco;
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    final user = _auth.currentUser;

    if (user == null) return;

    if (nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome não pode ficar vazio.')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      await _firestore.collection('usuarios').doc(user.uid).update({
        'nome': nomeController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'endereco': enderecoController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: telefoneController,
              decoration: InputDecoration(
                labelText: 'Telefone',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: enderecoController,
              decoration: InputDecoration(
                labelText: 'Endereço',
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _salvando ? null : salvar,
                child: _salvando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
