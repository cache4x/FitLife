import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_service.dart';
import '../../models/diet_plan.dart';
import '../../theme.dart';

// Tela para criação de um novo plano de dieta/alimentação
class DietCreateScreen extends StatefulWidget {
  const DietCreateScreen({super.key});
  @override State<DietCreateScreen> createState() => _DietCreateScreenState();
}

class _DietCreateScreenState extends State<DietCreateScreen> {
  final _formKey   = GlobalKey<FormState>();            // Chave global do formulário para validação
  final _nameCtrl  = TextEditingController();           // Controlador para o nome do plano de dieta
  final _calCtrl   = TextEditingController(text: '2000'); // Controlador para meta de calorias diárias
  DateTime _start  = DateTime.now();                    // Data de início da dieta (padrão hoje)
  DateTime? _end;                                       // Data de término opcional

  // Abre o DatePicker nativo para seleção das datas de início ou término
  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
      context: context, initialDate: isStart ? _start : (_end ?? DateTime.now()),
      firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: kYellow)),
        child: child!,
      ),
    );
    if (d != null) setState(() { if (isStart) _start = d; else _end = d; });
  }

  // Valida e salva o plano de dieta no banco local SQLite
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    
    // Constrói o novo modelo de dados DietPlan
    final plan  = DietPlan(
      id: const Uuid().v4(), userId: prefs.getString('userId') ?? '',
      name: _nameCtrl.text.trim(),
      calorieGoal: int.tryParse(_calCtrl.text) ?? 2000,
      startDate: _start, endDate: _end,
    );
    
    // Insere no banco local e fecha a tela atual
    await DatabaseService().insertDietPlan(plan);
    if (mounted) Navigator.pop(context);
  }

  // Formata datas de maneira amigável (dd/MM/yyyy)
  String _fmt(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Plano Alimentar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Campo de texto para Nome do Plano
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do plano'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            // Campo de texto para Meta Calórica diária
            TextFormField(
              controller: _calCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Meta calórica (kcal/dia)', suffixText: 'kcal'),
              validator: (v) => (v == null || (int.tryParse(v) ?? 0) < 500) ? 'Informe um valor válido' : null,
            ),
            const SizedBox(height: 16),
            // Seletor clicável para Data de Início
            ListTile(
              tileColor: kCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: kBorder)),
              title: const Text('Data de Início', style: TextStyle(color: kMuted, fontSize: 13)),
              subtitle: Text(_fmt(_start), style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.calendar_today, color: kYellow),
              onTap: () => _pickDate(true),
            ),
            const SizedBox(height: 10),
            // Seletor clicável para Data de Término (Opcional)
            ListTile(
              tileColor: kCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: kBorder)),
              title: const Text('Data de Término (opcional)', style: TextStyle(color: kMuted, fontSize: 13)),
              subtitle: Text(_end != null ? _fmt(_end!) : 'Sem data', style: TextStyle(fontWeight: FontWeight.w600, color: _end != null ? Colors.white : kMuted)),
              trailing: _end != null
                  ? IconButton(icon: const Icon(Icons.clear, color: kMuted), onPressed: () => setState(() => _end = null))
                  : const Icon(Icons.calendar_today, color: kMuted),
              onTap: () => _pickDate(false),
            ),
            const SizedBox(height: 32),
            // Botão para criar o plano
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Criar Plano', style: TextStyle(fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }
}
