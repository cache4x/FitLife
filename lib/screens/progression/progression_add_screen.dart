import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../db/database_service.dart';
import '../../models/load_progression.dart';
import '../../services/audio_service.dart';
import '../../theme.dart';

/// Tela de formulário para cadastrar um novo registro de carga (sets, reps, peso) para um exercício.
class ProgressionAddScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  const ProgressionAddScreen({super.key, required this.exerciseId, required this.exerciseName});
  @override State<ProgressionAddScreen> createState() => _ProgressionAddScreenState();
}

/// Estado do formulário de registro de carga.
class _ProgressionAddScreenState extends State<ProgressionAddScreen> {
  // Chave de validação do formulário e controladores dos campos de texto.
  final _formKey   = GlobalKey<FormState>();
  final _setsCtrl  = TextEditingController(text: '3');
  final _repsCtrl  = TextEditingController(text: '12');
  final _loadCtrl  = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  DateTime _date   = DateTime.now(); // Data padrão é o dia de hoje.

  /// Valida as entradas, insere o registro no banco SQLite e toca som motivacional caso seja recorde.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    final db     = DatabaseService();

    // Compara a nova carga com o histórico para verificar se é um recorde pessoal.
    final existing = await db.getProgressions(userId, widget.exerciseId);
    final newLoad  = double.parse(_loadCtrl.text);
    final isRecord = existing.isEmpty || newLoad > existing.map((r) => r.load).reduce((a, b) => a > b ? a : b);

    // Cria o objeto do modelo carregando os inputs do usuário.
    final record = LoadProgression(
      id: const Uuid().v4(), userId: userId,
      exerciseId: widget.exerciseId, exerciseName: widget.exerciseName,
      date: _date,
      sets: int.parse(_setsCtrl.text), reps: int.parse(_repsCtrl.text),
      load: newLoad, notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    
    await db.insertProgression(record);

    // Toca som festivo se o usuário ultrapassou sua carga máxima anterior.
    if (isRecord) await AudioService().playNewRecord();

    if (mounted) {
      if (isRecord) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🏆 Novo recorde pessoal!'),
          backgroundColor: Color(0xFF3A361F)));
      }
      Navigator.pop(context); // Retorna à tela anterior de histórico de evolução.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Carga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Banner identificador do exercício correspondente à carga.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: Row(children: [
                const Icon(Icons.fitness_center, color: kYellow, size: 28),
                const SizedBox(width: 12),
                Text(widget.exerciseName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ]),
            ),
            const SizedBox(height: 20),
            
            // Campos paralelos para Séries e Repetições (inputs numéricos inteiros).
            Row(children: [
              Expanded(child: TextFormField(controller: _setsCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Séries'),
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'Inválido' : null)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _repsCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repetições'),
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'Inválido' : null)),
            ]),
            const SizedBox(height: 16),
            
            // Campo de entrada da carga em quilos (suporta decimais).
            TextFormField(
              controller: _loadCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Carga (kg)', suffixText: 'kg'),
              validator: (v) => (double.tryParse(v ?? '') == null) ? 'Inválido' : null,
            ),
            const SizedBox(height: 16),
            
            // Seletor de data por diálogo padrão do sistema operacional.
            ListTile(
              tileColor: kCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: kBorder)),
              title: const Text('Data', style: TextStyle(color: kMuted, fontSize: 13)),
              subtitle: Text('${_date.day.toString().padLeft(2,'0')}/${_date.month.toString().padLeft(2,'0')}/${_date.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.calendar_today, color: kYellow),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date,
                    firstDate: DateTime(2020), lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: kYellow)), child: child!));
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 16),
            
            // Campo de anotações opcionais sobre o rendimento ou sensações.
            TextFormField(
              controller: _notesCtrl, maxLines: 2,
              decoration: const InputDecoration(labelText: 'Observações (opcional)', hintText: 'Ex: Senti dificuldade nos últimos reps...'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Salvar Registro', style: TextStyle(fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }
}
