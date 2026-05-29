import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/database_service.dart';
import '../../models/diet_plan.dart';
import '../../widgets/app_drawer.dart';
import '../../theme.dart';

// Tela que exibe a listagem de planos alimentares cadastrados do usuário
class DietListScreen extends StatefulWidget {
  const DietListScreen({super.key});
  @override State<DietListScreen> createState() => _DietListScreenState();
}

class _DietListScreenState extends State<DietListScreen> {
  List<DietPlan> _plans = []; // Lista local contendo os planos de dieta
  String _userId = '';        // ID do usuário ativo na sessão

  @override void initState() { super.initState(); _load(); }

  // Carrega os planos alimentares a partir do banco local utilizando o ID da sessão ativa
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    final plans = await DatabaseService().getDietPlans(_userId);
    if (mounted) setState(() => _plans = plans);
  }

  // Formata datas de forma amigável (dd/MM/yyyy)
  String _fmt(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planos Alimentares')),
      drawer: const AppDrawer(), // Barra lateral esquerda
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await Navigator.pushNamed(context, '/diet/create'); _load(); },
        child: const Icon(Icons.add),
      ),
      // Condicional para tela vazia ou listagem
      body: _plans.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.restaurant_menu, color: kMuted, size: 64),
              const SizedBox(height: 16),
              const Text('Nenhum plano criado', style: TextStyle(color: kMuted, fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () async { await Navigator.pushNamed(context, '/diet/create'); _load(); },
                  child: const Text('+ Criar Plano')),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (_, i) {
                final p = _plans[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 6),
                      // Meta de calorias destacada em formato de chip azulado
                      Chip(
                        label: Text('${p.calorieGoal} kcal/dia',
                            style: const TextStyle(color: Color(0xFF4DD9D9), fontSize: 11, fontWeight: FontWeight.w700)),
                        backgroundColor: const Color(0xFF1F3A3A),
                        side: const BorderSide(color: Color(0xFF1F3A3A)),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 4),
                      Text('Início: ${_fmt(p.startDate)}', style: const TextStyle(color: kMuted, fontSize: 12)),
                    ]),
                    // Botão para excluir o plano alimentar
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async { await DatabaseService().deleteDietPlan(p.id); _load(); }),
                      const Icon(Icons.chevron_right, color: kMuted),
                    ]),
                    onTap: () async {
                      // Abre a tela de detalhes enviando o ID do plano
                      await Navigator.pushNamed(context, '/diet/detail', arguments: {'planId': p.id});
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
