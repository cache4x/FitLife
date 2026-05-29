import 'package:flutter/material.dart';
import '../theme.dart';

// Widget reutilizável para exibir cartões de estatísticas/métricas no dashboard
class StatCard extends StatelessWidget {
  final String value;   // O valor numérico ou textual em destaque (ex: "5", "80%")
  final String label;   // O rótulo ou título principal da estatística (ex: "Planos de Treino")
  final String? sub;    // Subtítulo opcional de apoio (ex: "+12% esta semana")
  
  const StatCard({super.key, required this.value, required this.label, this.sub});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Exibe o valor de destaque em tamanho maior e na cor primária (Amarela)
          Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kYellow)),
          const SizedBox(height: 4),
          // Exibe o rótulo descritivo em formato menor e capitalizado
          Text(label, style: const TextStyle(fontSize: 11, color: kMuted, letterSpacing: 1, fontWeight: FontWeight.w600)),
          // Exibe o subtítulo caso tenha sido fornecido
          if (sub != null) Text(sub!, style: const TextStyle(fontSize: 11, color: kMuted)),
        ]),
      ),
    );
  }
}
