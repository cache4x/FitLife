import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_service.dart';
import '../../models/workout_plan.dart';
import '../../theme.dart';

/// Tela de formulário que permite ao usuário criar um novo plano de treino.
class WorkoutCreateScreen extends StatefulWidget {
  const WorkoutCreateScreen({super.key});
  @override State<WorkoutCreateScreen> createState() => _WorkoutCreateScreenState();
}

/// Estado da tela de criação de planos de treino.
class _WorkoutCreateScreenState extends State<WorkoutCreateScreen> {
  // Chave de validação do formulário e controladores do estado da UI.
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _goal    = 'Hipertrofia'; // Objetivo inicial padrão.
  bool _saving    = false; // Controle de loading no botão.

  // Objetivos esportivos pré-definidos para classificação do treino.
  final _goals = ['Hipertrofia', 'Força', 'Resistência', 'Emagrecimento'];

  /// Executa validações básicas, constrói a entidade do modelo e persiste os dados no SQLite.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    
    final plan  = WorkoutPlan(
      id: const Uuid().v4(),
      userId: prefs.getString('userId') ?? '',
      name: _nameCtrl.text.trim(),
      goal: _goal,
      createdAt: DateTime.now(),
    );
    
    await DatabaseService().insertWorkoutPlan(plan);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Plano "${plan.name}" criado!'),
        backgroundColor: const Color(0xFF1F3A26)));
      Navigator.pop(context); // Fecha a tela de cadastro e retorna à listagem.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Plano de Treino')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Campo de input para o título do plano de treino.
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do Plano'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            
            // Seletor dinâmico de objetivos por meio de Wrap de ChoiceChips.
            const Text('Objetivo', style: TextStyle(color: kMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _goals.map((g) => ChoiceChip(
              label: Text(g),
              selected: _goal == g,
              onSelected: (_) => setState(() => _goal = g),
              selectedColor: kYellow,
              labelStyle: TextStyle(
                color: _goal == g ? kBg : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            )).toList()),
            const SizedBox(height: 32),
            
            // Botão de salvar contendo controle de estado visual de carregamento.
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kBg))
                             : const Text('Criar Plano', style: TextStyle(fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }
}
