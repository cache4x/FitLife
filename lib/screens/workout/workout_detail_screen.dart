import 'package:flutter/material.dart';
import '../../db/database_service.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_session.dart';
import '../../theme.dart';

/// Tela de detalhamento de um Plano de Treino, listando todas as sessões de treino cadastradas para ele.
class WorkoutDetailScreen extends StatefulWidget {
  final String planId;
  const WorkoutDetailScreen({super.key, required this.planId});
  @override State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

/// Estado da tela de detalhes do plano de treino.
class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  // Objeto contendo o plano de treino atual e a lista de sessões/dias cadastrados.
  WorkoutPlan? _plan;
  List<WorkoutSession> _sessions = [];

  @override void initState() { super.initState(); _load(); }

  /// Carrega em paralelo o plano de treino e as sessões associadas do banco SQLite.
  Future<void> _load() async {
    final db = DatabaseService();
    final p  = await db.getWorkoutPlan(widget.planId);
    final s  = await db.getSessionsByPlan(widget.planId);
    if (mounted) setState(() { _plan = p; _sessions = s; });
  }

  // Mapa de cores para facilitar a identificação visual rápida de cada dia da semana.
  static const _days = {'Segunda-feira': Color(0xFF52D27A), 'Terça-feira': Color(0xFF7CB1FF),
    'Quarta-feira': Color(0xFFF5D10D), 'Quinta-feira': Color(0xFFF56565),
    'Sexta-feira': Color(0xFF4DD9D9), 'Sábado': Color(0xFFB57BFF),
    'Domingo': Color(0xFFFF9F40), 'Livre': kMuted};

  @override
  Widget build(BuildContext context) {
    if (_plan == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kYellow)));
    return Scaffold(
      appBar: AppBar(title: Text(_plan!.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await Navigator.pushNamed(context, '/workout/session/create', arguments: {'planId': widget.planId}); _load(); },
        child: const Icon(Icons.add), // Abre tela para adicionar uma nova sessão (Ex: Treino A, Treino B).
      ),
      body: RefreshIndicator(
        color: kYellow, onRefresh: _load,
        child: _sessions.isEmpty
            ? const Center(child: Text('Nenhuma sessão. Adicione com o botão +', style: TextStyle(color: kMuted)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _sessions.length,
                itemBuilder: (_, i) {
                  final s     = _sessions[i];
                  final color = _days[s.dayOfWeek] ?? kMuted;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(.15),
                        child: Icon(Icons.fitness_center, color: color, size: 18)),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(s.dayOfWeek, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () async { await DatabaseService().deleteWorkoutSession(s.id); _load(); }),
                        const Icon(Icons.chevron_right, color: kMuted),
                      ]),
                      onTap: () async {
                        // Abre a tela de detalhamento da sessão (lista de exercícios).
                        await Navigator.pushNamed(context, '/workout/session/detail', arguments: {'sessionId': s.id});
                        _load();
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
