import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/database_service.dart';
import '../../models/schedule_item.dart';
import '../../services/audio_service.dart';
import '../../widgets/app_drawer.dart';
import '../../theme.dart';

/// Tela principal da Agenda que gerencia e lista compromissos de treino e alimentação de forma interativa.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override State<ScheduleScreen> createState() => _ScheduleScreenState();
}

/// Estado da tela de agenda, manipulando carregamento, filtros e conclusão de tarefas.
class _ScheduleScreenState extends State<ScheduleScreen> {
  // Dados locais da agenda e o filtro textual de busca ativo.
  List<ScheduleItem> _items = [];
  String _userId = '';
  String _filter = 'todos';

  @override void initState() { super.initState(); _load(); }

  /// Recupera a lista completa de tarefas de agendamento do usuário do banco de dados SQLite.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    final items = await DatabaseService().getScheduleItems(_userId);
    if (mounted) setState(() => _items = items);
  }

  /// Retorna uma sublista filtrada com base no chip selecionado (Treino, Refeicao, concluídos, etc.).
  List<ScheduleItem> get _filtered {
    if (_filter == 'pendentes')  return _items.where((i) => !i.completed).toList();
    if (_filter == 'concluidos') return _items.where((i) => i.completed).toList();
    if (_filter == 'Treino')     return _items.where((i) => i.type == 'Treino').toList();
    if (_filter == 'Refeicao')   return _items.where((i) => i.type == 'Refeicao').toList();
    return _items;
  }

  /// Agrupa os itens filtrados pelo dia/mês/ano correspondente para estruturar a exibição em seções.
  Map<String, List<ScheduleItem>> get _grouped {
    final map = <String, List<ScheduleItem>>{};
    for (final i in _filtered) {
      final key = '${i.date.day.toString().padLeft(2,'0')}/${i.date.month.toString().padLeft(2,'0')}/${i.date.year}';
      (map[key] ??= []).add(i);
    }
    return map;
  }

  /// Registra a conclusão da atividade do agendamento, executa retorno sonoro e atualiza os dados da tela.
  Future<void> _complete(ScheduleItem item) async {
    await DatabaseService().completeScheduleItem(item.id);
    await AudioService().playWorkoutDone(); // Feedback sonoro positivo.
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await Navigator.pushNamed(context, '/schedule/create'); _load(); },
        child: const Icon(Icons.add), // Abre tela para adicionar novo compromisso na agenda.
      ),
      body: Column(children: [
        // Barra de rolagem horizontal contendo os chips para seleção de filtros rápidos.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            for (final f in [('todos','Todos'),('pendentes','Pendentes'),('concluidos','Concluídos'),('Treino','Treino'),('Refeicao','Refeição')])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(f.$2),
                  selected: _filter == f.$1,
                  onSelected: (_) => setState(() => _filter = f.$1),
                  selectedColor: kYellow,
                  labelStyle: TextStyle(color: _filter == f.$1 ? kBg : Colors.white,
                      fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
          ]),
        ),
        
        // Área contendo a lista agrupada de tarefas ordenadas por dia.
        Expanded(
          child: grouped.isEmpty
              ? const Center(child: Text('Nenhum agendamento.', style: TextStyle(color: kMuted)))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: grouped.entries.map((entry) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Cabeçalho da seção diária.
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        Container(width: 4, height: 14, color: kYellow, margin: const EdgeInsets.only(right: 8)),
                        Text(entry.key, style: const TextStyle(color: kYellow, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1)),
                      ]),
                    ),
                    
                    // Exibição dos cards individuais com as opções de exclusão ou check-in.
                    ...entry.value.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          item.type == 'Treino' ? Icons.fitness_center : Icons.restaurant,
                          color: item.completed ? kMuted : (item.type == 'Treino' ? const Color(0xFF7CB1FF) : const Color(0xFF4DD9D9)),
                        ),
                        title: Text(item.title,
                            style: TextStyle(fontWeight: FontWeight.w700, decoration: item.completed ? TextDecoration.lineThrough : null, color: item.completed ? kMuted : Colors.white)),
                        subtitle: Text('${item.date.hour.toString().padLeft(2,'0')}:${item.date.minute.toString().padLeft(2,'0')} · ${item.type}',
                            style: const TextStyle(color: kMuted, fontSize: 11)),
                        trailing: item.completed
                            ? const Chip(label: Text('✓ Feito', style: TextStyle(color: Color(0xFF52D27A), fontSize: 11, fontWeight: FontWeight.w700)),
                                backgroundColor: Color(0xFF1F3A26), side: BorderSide(color: Color(0xFF1F3A26)), padding: EdgeInsets.zero)
                            : Row(mainAxisSize: MainAxisSize.min, children: [
                                OutlinedButton(
                                  onPressed: () => _complete(item),
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                                  child: const Text('✓', style: TextStyle(color: kYellow)),
                                ),
                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                    onPressed: () async { await DatabaseService().deleteScheduleItem(item.id); _load(); }),
                              ]),
                      ),
                    )),
                  ])).toList(),
                ),
        ),
      ]),
    );
  }
}
