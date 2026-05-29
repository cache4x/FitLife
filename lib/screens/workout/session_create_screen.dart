import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_service.dart';
import '../../models/workout_session.dart';
import '../../theme.dart';

/// Tela de formulário que permite criar uma nova sessão de exercícios (Ex: "Treino A - Peito", "Cardio") associada a um plano.
class SessionCreateScreen extends StatefulWidget {
  final String planId;
  const SessionCreateScreen({super.key, required this.planId});
  @override State<SessionCreateScreen> createState() => _SessionCreateScreenState();
}

/// Estado da tela de criação de sessões de treino.
class _SessionCreateScreenState extends State<SessionCreateScreen> {
  // Chave de validação do formulário e controladores do estado local da UI.
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _day     = 'Segunda-feira'; // Dia padrão inicial.

  // Lista dos dias disponíveis para seleção no menu Dropdown.
  final _days = ['Segunda-feira','Terça-feira','Quarta-feira','Quinta-feira','Sexta-feira','Sábado','Domingo','Livre'];

  /// Valida as entradas do formulário e insere a nova sessão no banco de dados SQLite.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final session = WorkoutSession(
      id: const Uuid().v4(), workoutPlanId: widget.planId,
      name: _nameCtrl.text.trim(), dayOfWeek: _day,
    );
    
    await DatabaseService().insertWorkoutSession(session);
    if (mounted) { Navigator.pop(context); } // Retorna para a tela de plano de treino atualizada.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Sessão')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Campo de input para descrever o nome/foco da sessão.
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome da sessão'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            
            // Dropdown de seleção do dia ideal da semana para a realização deste grupo de exercícios.
            DropdownButtonFormField<String>(
              value: _day,
              dropdownColor: kCard,
              decoration: const InputDecoration(labelText: 'Dia da semana'),
              items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _day = v!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Criar Sessão', style: TextStyle(fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }
}
