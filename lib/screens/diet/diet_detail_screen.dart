import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_service.dart';
import '../../models/diet_plan.dart';
import '../../models/meal.dart';
import '../../models/meal_item.dart';
import '../../theme.dart';

// Tela de detalhes do plano alimentar, exibindo refeições e consumo de calorias
class DietDetailScreen extends StatefulWidget {
  final String planId; // ID do plano de dieta selecionado
  const DietDetailScreen({super.key, required this.planId});
  @override State<DietDetailScreen> createState() => _DietDetailScreenState();
}

class _DietDetailScreenState extends State<DietDetailScreen> {
  DietPlan? _plan;                              // Plano de dieta atual
  List<Meal> _meals = [];                       // Lista de refeições associadas ao plano
  final Map<String, List<MealItem>> _items = {}; // Mapeamento de itens/alimentos de cada refeição (mealId -> MealItem)

  @override void initState() { super.initState(); _load(); }

  // Carrega do banco local os dados do plano, refeições e seus respectivos alimentos
  Future<void> _load() async {
    final db    = DatabaseService();
    final plan  = await db.getDietPlan(widget.planId);
    final meals = await db.getMealsByPlan(widget.planId);
    final itemsMap = <String, List<MealItem>>{};
    for (final m in meals) { itemsMap[m.id] = await db.getMealItems(m.id); }
    if (mounted) setState(() { _plan = plan; _meals = meals; _items.addAll(itemsMap); });
  }

  // Exibe um modal inferior para cadastrar uma nova refeição (ex: Almoço)
  Future<void> _addMeal() async {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('+ Nova Refeição', style: TextStyle(color: kYellow, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome da refeição')),
          const SizedBox(height: 12),
          TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Horário (ex: 07:00)', suffixIcon: Icon(Icons.access_time, color: kMuted))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final meal = Meal(id: const Uuid().v4(), dietPlanId: widget.planId,
                  name: nameCtrl.text.trim(), suggestedTime: timeCtrl.text.trim(), totalCalories: 0);
              await DatabaseService().insertMeal(meal);
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: const Text('Criar'),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // Exibe um modal inferior para adicionar um alimento a uma refeição
  Future<void> _addItem(Meal meal) async {
    final foodCtrl = TextEditingController();
    final qtyCtrl  = TextEditingController(text: '100');
    String unit    = 'g';
    final calCtrl  = TextEditingController(text: '0');
    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: StatefulBuilder(builder: (_, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
          Text('+ Alimento em "${meal.name}"', style: const TextStyle(color: kYellow, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          TextField(controller: foodCtrl, decoration: const InputDecoration(labelText: 'Alimento')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantidade'))),
            const SizedBox(width: 8),
            Expanded(child: DropdownButtonFormField<String>(
              value: unit, dropdownColor: kCard,
              decoration: const InputDecoration(labelText: 'Unidade'),
              items: ['g','ml','un','colher','xícara','porção'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setS(() => unit = v!),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'kcal'))),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (foodCtrl.text.trim().isEmpty) return;
              final cal  = int.tryParse(calCtrl.text) ?? 0;
              // Cria novo item alimentar
              final item = MealItem(id: const Uuid().v4(), mealId: meal.id,
                  food: foodCtrl.text.trim(), quantity: double.tryParse(qtyCtrl.text) ?? 100,
                  unit: unit, calories: cal);
              final db  = DatabaseService();
              await db.insertMealItem(item);
              // Atualiza o total calórico da refeição mãe
              await db.updateMealCalories(meal.id, meal.totalCalories + cal);
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
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
    if (_plan == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kYellow)));
    
    // Calcula o consumo atual de calorias e percentual atingido da meta
    final totalConsumed = _meals.fold(0, (s, m) => s + m.totalCalories);
    final pct = _plan!.calorieGoal > 0 ? (totalConsumed / _plan!.calorieGoal).clamp(0.0, 1.0) : 0.0;
    
    return Scaffold(
      appBar: AppBar(title: Text(_plan!.name)),
      floatingActionButton: FloatingActionButton(onPressed: _addMeal, child: const Icon(Icons.add)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Painel resumo da meta calórica com barra de progresso
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$totalConsumed kcal', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kYellow)),
              Text('meta: ${_plan!.calorieGoal} kcal', style: const TextStyle(color: kMuted)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: pct, minHeight: 8, backgroundColor: kBorder, color: kYellow)),
          ]))),
          const SizedBox(height: 16),
          // Lista de Refeições
          ..._meals.map((meal) {
            final mealItems = _items[meal.id] ?? [];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(
                title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: meal.suggestedTime.isNotEmpty ? Text(meal.suggestedTime, style: const TextStyle(color: kMuted, fontSize: 12)) : null,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Chip(label: Text('${meal.totalCalories} kcal', style: const TextStyle(color: Color(0xFF4DD9D9), fontSize: 11, fontWeight: FontWeight.w700)),
                      backgroundColor: const Color(0xFF1F3A3A), side: const BorderSide(color: Color(0xFF1F3A3A)), padding: EdgeInsets.zero),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () async { await DatabaseService().deleteMeal(meal.id); _load(); }),
                ]),
              ),
              // Alimentos inseridos na refeição
              if (mealItems.isNotEmpty) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: mealItems.map((item) => Row(children: [
                  Expanded(child: Text(item.food, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${item.quantity} ${item.unit}', style: const TextStyle(color: kMuted, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('${item.calories} kcal', style: const TextStyle(color: kYellow, fontSize: 12, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close, size: 16, color: kMuted),
                      onPressed: () async {
                        final db = DatabaseService();
                        await db.deleteMealItem(item.id);
                        await db.updateMealCalories(meal.id, (meal.totalCalories - item.calories).clamp(0, 999999));
                        _load();
                      }),
                ])).toList()),
              ),
              // Botão para adicionar alimento
              Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: OutlinedButton.icon(
                onPressed: () => _addItem(meal),
                icon: const Icon(Icons.add, size: 16), label: const Text('Adicionar alimento'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(36)),
              )),
            ]));
          }),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}
