import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../db/database_service.dart';
import '../../models/user.dart';
import '../../services/audio_service.dart';
import '../../theme.dart';

// Tela de cadastro de novos usuários no aplicativo
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();            // Chave global do formulário para validação
  final _nameCtrl     = TextEditingController();           // Controlador do campo de nome
  final _emailCtrl    = TextEditingController();           // Controlador do campo de e-mail
  final _passCtrl     = TextEditingController();           // Controlador do campo de senha
  final _confirmCtrl  = TextEditingController();           // Controlador de confirmação de senha
  bool _loading = false;                                   // Flag do indicador de progresso
  bool _obscure = true;                                    // Flag de visibilidade da senha

  // Gera o hash SHA-256 da senha digitada
  String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

  // Executa a validação e o cadastro do novo usuário
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      _showError('As senhas não coincidem.');
      return;
    }
    setState(() => _loading = true);
    try {
      final db = DatabaseService();
      // Valida se o e-mail inserido já existe no banco de dados SQLite
      if (await db.getUserByEmail(_emailCtrl.text.trim().toLowerCase()) != null) {
        _showError('Este e-mail já está cadastrado.');
        return;
      }
      // Cria a nova instância do objeto de Usuário
      final user = User(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().toLowerCase(),
        passwordHash: _hash(_passCtrl.text),
        createdAt: DateTime.now(),
      );
      // Insere no banco de dados
      await db.insertUser(user);
      
      // Salva os dados de login nas preferências persistidas
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId',   user.id);
      await prefs.setString('userName', user.name);
      
      // Toca áudio e envia para a tela de dashboard
      await AudioService().playLoginSuccess();
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Mostra aviso snackbar na parte inferior da tela
  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Logotipo visual
                  const Icon(Icons.fitness_center, color: kYellow, size: 56),
                  const SizedBox(height: 8),
                  const Text('MUSCLEHELPER', textAlign: TextAlign.center,
                      style: TextStyle(color: kYellow, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 3)),
                  const SizedBox(height: 40),
                  const Text('Criar conta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Comece sua jornada fitness agora', style: TextStyle(color: kMuted)),
                  const SizedBox(height: 32),
                  // Campo para Nome
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome completo'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 16),
                  // Campo para E-mail com validação básica de arroba
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  // Campo de Senha primária
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Senha (mín. 6 caracteres)',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: kMuted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  // Campo de confirmação da mesma senha
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirmar senha'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Confirme a senha' : null,
                  ),
                  const SizedBox(height: 24),
                  // Botão para criação de conta
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kBg))
                        : const Text('Criar conta', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  // Link para voltar para tela de Login
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Já tem conta? ', style: TextStyle(color: kMuted)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Entrar', style: TextStyle(color: kYellow, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
