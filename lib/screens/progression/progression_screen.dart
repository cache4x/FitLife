import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/database_service.dart';
import '../../models/load_progression.dart';
import '../../services/audio_service.dart';
import '../../theme.dart';

/// Tela que apresenta o histórico detalhado e o gráfico de evolução de carga para um exercício específico.
class ProgressionScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  const ProgressionScreen({super.key, required this.exerciseId, required this.exerciseName});
  @override State<ProgressionScreen> createState() => _ProgressionScreenState();
}

/// Estado da tela de progressão de carga de um exercício.
class _ProgressionScreenState extends State<ProgressionScreen> {
  // Lista de registros de carga salvos e o identificador do usuário ativo.
  List<LoadProgression> _records = [];
  String _userId = '';

  @override void initState() { super.initState(); _load(); }

  /// Busca no banco de dados SQLite todos os registros de progressão de carga salvos para o exercício.
  Future<void> _load() async {
    final prefs  = await SharedPreferences.getInstance();
    _userId      = prefs.getString('userId') ?? '';
    final records = await DatabaseService().getProgressions(_userId, widget.exerciseId);
    if (mounted) setState(() => _records = records);
  }

  /// Formata um objeto DateTime para string curta no padrão brasileiro DD/MM.
  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    // Cálculos de métricas a partir dos registros de evolução carregados.
    final maxLoad  = _records.isNotEmpty ? _records.map((r) => r.load).reduce((a, b) => a > b ? a : b) : 0.0;
    final lastLoad = _records.isNotEmpty ? _records.last.load : 0.0;
    final firstLoad = _records.isNotEmpty ? _records.first.load : 0.0;
    final diff     = lastLoad - firstLoad;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () async {
            // Abre formulário para registrar nova carga e atualiza ao retornar.
            await Navigator.pushNamed(context, '/progression/add',
                arguments: {'exerciseId': widget.exerciseId, 'exerciseName': widget.exerciseName});
            _load();
          }),
        ],
      ),
      body: _records.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.trending_up, color: kMuted, size: 64),
              const SizedBox(height: 16),
              const Text('Nenhum registro ainda', style: TextStyle(color: kMuted)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () async {
                await Navigator.pushNamed(context, '/progression/add',
                    arguments: {'exerciseId': widget.exerciseId, 'exerciseName': widget.exerciseName});
                _load();
              }, child: const Text('+ Registrar Carga')),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Linha de cartões contendo informações calculadas de carga máxima, atual e contagem total.
                Row(children: [
                  Expanded(child: _statCard('${maxLoad}kg', 'Carga Máxima')),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard('${lastLoad}kg', 'Último Registro',
                      sub: _records.length > 1 ? '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg' : null,
                      subColor: diff >= 0 ? const Color(0xFF52D27A) : Colors.redAccent)),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard('${_records.length}', 'Registros')),
                ]),
                const SizedBox(height: 16),
                
                // Exibição do gráfico de linha com a biblioteca fl_chart.
                Card(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('EVOLUÇÃO DA CARGA', style: TextStyle(color: kYellow, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: LineChart(LineChartData(
                        gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: kBorder, strokeWidth: 1), getDrawingVerticalLine: (_) => FlLine(color: kBorder, strokeWidth: 1)),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: kMuted, fontSize: 10)), reservedSize: 32)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: (_records.length / 4).ceilToDouble().clamp(1, 9999),
                              getTitlesWidget: (v, _) { final i = v.toInt(); if (i < 0 || i >= _records.length) return const SizedBox(); return Text(_fmtDate(_records[i].date), style: const TextStyle(color: kMuted, fontSize: 9)); }, reservedSize: 24)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [LineChartBarData(
                          spots: _records.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.load)).toList(),
                          isCurved: true, color: kYellow, barWidth: 2,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: kYellow.withOpacity(.1)),
                        )],
                      )),
                    ),
                  ]),
                )),
                const SizedBox(height: 16),
                Row(children: [
                  Container(width: 4, height: 14, color: kYellow, margin: const EdgeInsets.only(right: 8)),
                  const Text('HISTÓRICO', style: TextStyle(color: kYellow, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
                ]),
                const SizedBox(height: 8),
                
                // Lista reversa exibindo o histórico de cargas e botão para remoção.
                ..._records.reversed.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center, color: kYellow),
                    title: Text('${r.load} kg', style: const TextStyle(fontWeight: FontWeight.w700, color: kYellow, fontSize: 18)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${r.sets} séries × ${r.reps} reps', style: const TextStyle(color: kMuted, fontSize: 12)),
                      if (r.notes != null && r.notes!.isNotEmpty) Text(r.notes!, style: const TextStyle(color: kMuted, fontSize: 11, fontStyle: FontStyle.italic)),
                    ]),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(_fmtDate(r.date), style: const TextStyle(color: kMuted, fontSize: 12)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          onPressed: () async { await DatabaseService().deleteProgression(r.id); _load(); }),
                    ]),
                  ),
                )),
                const SizedBox(height: 80),
              ]),
            ),
    );
  }

  /// Constrói um cartão de métrica simples de forma modular para a interface.
  Widget _statCard(String value, String label, {String? sub, Color? subColor}) => Card(child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kYellow)),
      Text(label, style: const TextStyle(fontSize: 10, color: kMuted)),
      if (sub != null) Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: subColor ?? kYellow)),
    ]),
  ));
}
