import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../db/database_service.dart';
import '../../services/audio_service.dart';
import '../../theme.dart';

// Tela de autenticação/login do usuário
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();            // Chave global para validação do formulário
  final _emailCtrl    = TextEditingController();       // Controlador do campo de e-mail
  final _passwordCtrl = TextEditingController();       // Controlador do campo de senha
  bool _loading = false;                               // Estado de carregamento do botão entrar
  bool _obscure = true;                                // Estado de visibilidade da senha

  // Gera o hash SHA-256 da senha digitada para comparação segura
  String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

  // Executa o processo de login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final db   = DatabaseService();
      // Consulta o usuário pelo e-mail inserido
      final user = await db.getUserByEmail(_emailCtrl.text.trim().toLowerCase());
      
      // Valida se o usuário existe e se o hash da senha coincide
      if (user == null || user.passwordHash != _hash(_passwordCtrl.text)) {
        _showError('E-mail ou senha inválidos.');
        return;
      }
      
      // Salva o estado de login na sessão persistida do app
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId',   user.id);
      await prefs.setString('userName', user.name);
      
      // Toca o áudio de sucesso e navega para o painel principal
      await AudioService().playLoginSuccess();
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Exibe mensagem de erro na parte inferior da tela
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
                      style: TextStyle(color: kYellow, fontWeight: FontWeight.w900,
                          fontSize: 22, letterSpacing: 3)),
                  const SizedBox(height: 40),
                  const Text('Bem-vindo de volta',
                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Entre com sua conta para continuar',
                      style: TextStyle(color: kMuted)),
                  const SizedBox(height: 32),
                  // Input de e-mail com validação básica
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  // Input de senha com botão para alternar visibilidade
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: kMuted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Digite a senha' : null,
                  ),
                  const SizedBox(height: 24),
                  // Botão de submissão do formulário
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kBg))
                        : const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  // Link alternativo para criação de conta
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Não tem conta? ', style: TextStyle(color: kMuted)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Cadastre-se',
                          style: TextStyle(color: kYellow, fontWeight: FontWeight.w700)),
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
