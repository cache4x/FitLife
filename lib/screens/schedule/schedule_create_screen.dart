import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_service.dart';
import '../../models/schedule_item.dart';
import '../../theme.dart';

/// Tela de formulário que permite criar e agendar um novo compromisso (Treino ou Refeição).
class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});
  @override State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

/// Estado do formulário de criação de agendamento.
class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  // Chave de validação do formulário e controladores para dados do agendamento.
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String _type     = 'Treino'; // Tipo inicial padrão.
  DateTime _date   = DateTime.now();

  /// Abre seletores sequenciais para escolher a data (DatePicker) e a hora (TimePicker).
  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: kYellow)),
        child: child!),
    );
    if (d == null) return;
    
    // Abre seletor de hora após o usuário confirmar a data.
    final t = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(_date),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: kYellow)),
        child: child!),
    );
    if (t != null) setState(() => _date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  /// Valida o título do agendamento, cria a entidade do modelo e insere no banco SQLite.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final item  = ScheduleItem(
      id: const Uuid().v4(), userId: prefs.getString('userId') ?? '',
      date: _date, type: _type, title: _titleCtrl.text.trim(), completed: false,
    );
    await DatabaseService().insertScheduleItem(item);
    if (mounted) Navigator.pop(context); // Retorna para a tela de agenda atualizada.
  }

  /// Converte a data e a hora do agendamento em String legível no padrão DD/MM/AAAA HH:MM.
  String _fmt(DateTime d) {
    final time = '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year} $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Tipo', style: TextStyle(color: kMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 8),
            
            // Chips para alternar dinamicamente entre Treino ou Refeição, com colorações temáticas.
            Row(children: [
              Expanded(child: ChoiceChip(
                label: const Text('Treino'), selected: _type == 'Treino',
                onSelected: (_) => setState(() => _type = 'Treino'),
                selectedColor: const Color(0xFF23304A),
                labelStyle: TextStyle(color: _type == 'Treino' ? const Color(0xFF7CB1FF) : kMuted, fontWeight: FontWeight.w700),
              )),
              const SizedBox(width: 8),
              Expanded(child: ChoiceChip(
                label: const Text('Refeição'), selected: _type == 'Refeicao',
                onSelected: (_) => setState(() => _type = 'Refeicao'),
                selectedColor: const Color(0xFF1F3A3A),
                labelStyle: TextStyle(color: _type == 'Refeicao' ? const Color(0xFF4DD9D9) : kMuted, fontWeight: FontWeight.w700),
              )),
            ]),
            const SizedBox(height: 16),
            
            // Input de texto para definir o título/descrição do agendamento.
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Título obrigatório' : null,
            ),
            const SizedBox(height: 16),
            
            // Botão que aciona a escolha de data e hora do agendamento.
            ListTile(
              tileColor: kCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: kBorder)),
              title: const Text('Data e Hora', style: TextStyle(color: kMuted, fontSize: 13)),
              subtitle: Text(_fmt(_date), style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.calendar_today, color: kYellow),
              onTap: _pickDate,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Agendar', style: TextStyle(fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }
}
