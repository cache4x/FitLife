import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_service.dart';
import '../../models/workout_session.dart';
import '../../models/exercise_item.dart';
import '../../theme.dart';

/// Tela que apresenta a lista de exercícios contidos em uma sessão específica, com recursos de criação e remoção.
class SessionDetailScreen extends StatefulWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});
  @override State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

/// Estado da tela de detalhes da sessão (gerenciamento dos exercícios).
class _SessionDetailScreenState extends State<SessionDetailScreen> {
  // Entidade da sessão atual e lista dos exercícios que a compõem.
  WorkoutSession? _session;
  List<ExerciseItem> _items = [];

  @override void initState() { super.initState(); _load(); }

  /// Carrega as informações da sessão e seus exercícios vinculados do banco SQLite.
  Future<void> _load() async {
    final db = DatabaseService();
    final s  = await db.getWorkoutSession(widget.sessionId);
    final e  = await db.getExercisesBySession(widget.sessionId);
    if (mounted) setState(() { _session = s; _items = e; });
  }

  /// Exibe um diálogo BottomSheet dinâmico com formulário para cadastro e parametrização do exercício.
  Future<void> _addExercise() async {
    String? selectedId = kExercises.first['id'];
    final setsCtrl  = TextEditingController(text: '3');
    final repsCtrl  = TextEditingController(text: '12');
    final loadCtrl  = TextEditingController(text: '0');

    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: StatefulBuilder(builder: (_, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('+ Adicionar Exercício', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kYellow)),
          const SizedBox(height: 16),
          
          // Dropdown preenchido com a lista de exercícios predefinidos da base global.
          DropdownButtonFormField<String>(
            value: selectedId, dropdownColor: kCard,
            decoration: const InputDecoration(labelText: 'Exercício'),
            items: kExercises.map((e) => DropdownMenuItem(
              value: e['id'], child: Text('${e['name']} (${e['muscle']})', style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setS(() => selectedId = v),
          ),
          const SizedBox(height: 12),
          
          // Inputs numéricos rápidos para personalização (séries, repetições e carga base sugerida).
          Row(children: [
            Expanded(child: TextField(controller: setsCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Séries'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: repsCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Repetições'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: loadCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Carga (kg)'))),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final ex = kExercises.firstWhere((e) => e['id'] == selectedId);
              final item = ExerciseItem(
                id: const Uuid().v4(), workoutSessionId: widget.sessionId,
                exerciseId: ex['id']!, exerciseName: ex['name']!,
                muscleGroup: ex['muscle']!,
                sets: int.tryParse(setsCtrl.text) ?? 3,
                reps: int.tryParse(repsCtrl.text) ?? 12,
                suggestedLoad: double.tryParse(loadCtrl.text) ?? 0,
                order: _items.length + 1,
              );
              await DatabaseService().insertExerciseItem(item);
              if (ctx.mounted) Navigator.pop(ctx); // Fecha o BottomSheet.
              _load(); // Atualiza a lista.
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: const Text('Adicionar'),
          ),
          const SizedBox(height: 20),
        ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kYellow)));
    return Scaffold(
      appBar: AppBar(title: Text(_session!.name)),
      floatingActionButton: FloatingActionButton(onPressed: _addExercise, child: const Icon(Icons.add)),
      body: _items.isEmpty
          ? const Center(child: Text('Nenhum exercício. Adicione com o botão +', style: TextStyle(color: kMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: kYellow.withOpacity(.15),
                        child: Text('${i + 1}', style: const TextStyle(color: kYellow, fontWeight: FontWeight.w700))),
                    title: Text(item.exerciseName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${item.sets} séries × ${item.reps} reps'
                        '${item.suggestedLoad > 0 ? ' · ${item.suggestedLoad} kg' : ''}',
                        style: const TextStyle(color: kMuted, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async { await DatabaseService().deleteExerciseItem(item.id); _load(); },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
