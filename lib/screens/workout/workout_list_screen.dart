import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/database_service.dart';
import '../../models/workout_plan.dart';
import '../../widgets/app_drawer.dart';
import '../../theme.dart';

/// Tela que lista os planos de treino cadastrados pelo usuário, permitindo exclusão e visualização detalhada.
class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});
  @override State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

/// Estado da tela de listagem de planos de treino.
class _WorkoutListScreenState extends State<WorkoutListScreen> {
  // Planos carregados do usuário e identificador do usuário ativo.
  List<WorkoutPlan> _plans = [];
  String _userId = '';

  @override void initState() { super.initState(); _load(); }

  /// Carrega os planos de treino do banco de dados assincronamente.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    final plans = await DatabaseService().getWorkoutPlans(_userId);
    if (mounted) setState(() => _plans = plans);
  }

  /// Exibe caixa de diálogo para confirmação antes de excluir o plano de treino selecionado.
  Future<void> _delete(WorkoutPlan p) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: kCard,
      title: const Text('Excluir plano'),
      content: Text('Excluir "${p.name}" e todas as suas sessões?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: kMuted))),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
      ],
    ));
    if (ok == true) { await DatabaseService().deleteWorkoutPlan(p.id); _load(); }
  }

  // Cores dinâmicas associadas a cada objetivo de treino, melhorando a estética.
  static const _goalColors = {'Hipertrofia': Color(0xFF7CB1FF), 'Força': Color(0xFFF56565),
    'Resistência': Color(0xFF52D27A), 'Emagrecimento': Color(0xFFF5D10D)};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Treinos')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await Navigator.pushNamed(context, '/workout/create'); _load(); },
        child: const Icon(Icons.add), // Atalho para criar novo plano.
      ),
      body: _plans.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.fitness_center, color: kMuted, size: 64),
              const SizedBox(height: 16),
              const Text('Nenhum plano criado', style: TextStyle(color: kMuted, fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () async { await Navigator.pushNamed(context, '/workout/create'); _load(); },
                  child: const Text('+ Criar Plano')),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (_, i) {
                final p = _plans[i];
                final color = _goalColors[p.goal] ?? kYellow;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Chip(
                        label: Text(p.goal, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                        backgroundColor: color.withOpacity(.15),
                        side: BorderSide(color: color.withOpacity(.3)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _delete(p)),
                      const Icon(Icons.chevron_right, color: kMuted),
                    ]),
                    onTap: () async {
                      // Abre os detalhes e sessões do plano de treino selecionado.
                      await Navigator.pushNamed(context, '/workout/detail', arguments: {'planId': p.id});
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
