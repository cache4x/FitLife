import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/database_service.dart';
import '../../models/load_progression.dart';
import '../../models/schedule_item.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../theme.dart';

/// Tela inicial (Dashboard) que apresenta o resumo semanal, métricas e eventos pendentes do usuário.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

/// Estado da tela de Dashboard, responsável pelo carregamento e exibição das estatísticas do usuário.
class _DashboardScreenState extends State<DashboardScreen> {
  // Variáveis para guardar informações do usuário e contadores estatísticos do banco de dados.
  String _userName = '';
  String _userId   = '';
  int _workoutsWeek = 0, _workoutPlans = 0, _dietPlans = 0;
  LoadProgression? _lastLoad;
  List<ScheduleItem> _upcoming = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(); // Inicia a carga dos dados ao renderizar a tela.
  }

  /// Recupera dados das preferências e realiza consultas paralelas no banco de dados SQLite.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId   = prefs.getString('userId') ?? '';
    _userName = prefs.getString('userName') ?? '';
    final db  = DatabaseService();
    
    // Executa múltiplas queries assíncronas em paralelo para otimizar o tempo de resposta.
    final results = await Future.wait([
      db.countWorkoutsThisWeek(_userId),
      db.countWorkoutPlans(_userId),
      db.countDietPlans(_userId),
      db.getLastProgression(_userId),
      db.getUpcoming(_userId),
    ]);
    
    if (mounted) setState(() {
      _workoutsWeek = results[0] as int;
      _workoutPlans = results[1] as int;
      _dietPlans    = results[2] as int;
      _lastLoad     = results[3] as LoadProgression?;
      _upcoming     = results[4] as List<ScheduleItem>;
      _loading      = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load), // Botão manual de recarregar.
        ],
      ),
      drawer: const AppDrawer(), // Gaveta lateral de navegação.
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kYellow))
          : RefreshIndicator(
              color: kYellow,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Olá, $_userName 👋',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Aqui está seu resumo', style: TextStyle(color: kMuted)),
                  const SizedBox(height: 20),

                  _sectionTitle('Resumo da Semana'),
                  // Grid com cartões de estatísticas contendo os dados carregados do banco.
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8, mainAxisSpacing: 8,
                    childAspectRatio: 1.6,
                    children: [
                      StatCard(value: '$_workoutsWeek', label: 'Treinos agendados', sub: 'esta semana'),
                      StatCard(value: '$_workoutPlans', label: 'Planos de treino', sub: 'cadastrados'),
                      StatCard(value: '$_dietPlans',    label: 'Planos alimentares', sub: 'cadastrados'),
                      StatCard(value: _upcoming.length.toString(), label: 'Próximos eventos', sub: 'pendentes'),
                    ],
                  ),

                  // Exibe a última progressão de carga registrada se ela existir.
                  if (_lastLoad != null) ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Último Registro de Carga'),
                    Card(child: ListTile(
                      leading: const Icon(Icons.trending_up, color: kYellow, size: 32),
                      title: Text(_lastLoad!.exerciseName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${_lastLoad!.sets} séries × ${_lastLoad!.reps} reps',
                          style: const TextStyle(color: kMuted)),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${_lastLoad!.load} kg',
                            style: const TextStyle(color: kYellow, fontSize: 20, fontWeight: FontWeight.w800)),
                      ]),
                      onTap: () => Navigator.pushNamed(context, '/progression',
                          arguments: {'exerciseId': _lastLoad!.exerciseId, 'exerciseName': _lastLoad!.exerciseName}),
                    )),
                  ],

                  const SizedBox(height: 20),
                  _sectionTitle('Próximos Agendamentos'),
                  if (_upcoming.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        const Text('Nenhum agendamento pendente. ', style: TextStyle(color: kMuted)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/schedule/create'),
                          child: const Text('Criar agora', style: TextStyle(color: kYellow, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    )
                  else
                    // Lista os próximos compromissos (treinos ou refeições).
                    ...(_upcoming.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          item.type == 'Treino' ? Icons.fitness_center : Icons.restaurant,
                          color: item.type == 'Treino' ? const Color(0xFF7CB1FF) : const Color(0xFF4DD9D9),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(_fmtDate(item.date), style: const TextStyle(color: kMuted, fontSize: 12)),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            // Conclui o agendamento no banco de dados e atualiza a tela.
                            await DatabaseService().completeScheduleItem(item.id);
                            _load();
                          },
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                          child: const Text('✓', style: TextStyle(color: kYellow)),
                        ),
                      ),
                    ))),

                  const SizedBox(height: 20),
                  _sectionTitle('Acesso Rápido'),
                  // Grid com atalhos de navegação rápida para as principais telas.
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8, mainAxisSpacing: 8,
                    childAspectRatio: 2.4,
                    children: [
                      _quickLink(context, Icons.fitness_center, 'Novo Treino',    '/workout/create'),
                      _quickLink(context, Icons.restaurant_menu,'Nova Dieta',     '/diet/create'),
                      _quickLink(context, Icons.calendar_today, 'Agendar',        '/schedule/create'),
                      _quickLink(context, Icons.list,           'Ver Treinos',    '/workout'),
                    ],
                  ),
                ]),
              ),
            ),
    );
  }

  /// Constrói o título padronizado das seções do dashboard.
  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 4, height: 16, color: kYellow, margin: const EdgeInsets.only(right: 10)),
      Text(t.toUpperCase(), style: const TextStyle(color: kYellow, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 2)),
    ]),
  );

  /// Cria botões de links rápidos com efeitos visuais e navegação por rota.
  Widget _quickLink(BuildContext ctx, IconData icon, String label, String route) => InkWell(
    onTap: () => Navigator.pushNamed(ctx, route),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: kYellow, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    ),
  );

  /// Formata a data e hora do agendamento para exibição simples (ex: "Hoje 14:00" ou "22/05 14:00").
  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month) return 'Hoje ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }
}
