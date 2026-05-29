// Modelo de dados que registra uma evolução/progressão de carga em determinado exercício
class LoadProgression {
  final String id;              // Identificador único do registro de progressão
  final String userId;          // ID do usuário que registrou a carga
  final String exerciseId;      // ID único do exercício associado
  final String exerciseName;    // Nome do exercício para exibição histórica rápida
  final DateTime date;          // Data e hora do registro do treino
  final int sets;               // Quantidade de séries executadas com essa carga
  final int reps;               // Quantidade de repetições realizadas por série
  final double load;            // Peso/carga utilizado (em kg ou unidade padrão)
  final String? notes;          // Observações sobre a execução ou cansaço (opcional)

  const LoadProgression({required this.id, required this.userId,
      required this.exerciseId, required this.exerciseName,
      required this.date, required this.sets, required this.reps,
      required this.load, this.notes});

  // Converte os dados da progressão de carga para salvar no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'user_id': userId, 'exercise_id': exerciseId,
    'exercise_name': exerciseName, 'date': date.toIso8601String(),
    'sets': sets, 'reps': reps, 'load': load, 'notes': notes,
  };

  // Instancia uma LoadProgression a partir dos dados do SQLite
  factory LoadProgression.fromMap(Map<String, dynamic> m) => LoadProgression(
    id: m['id'], userId: m['user_id'], exerciseId: m['exercise_id'],
    exerciseName: m['exercise_name'], date: DateTime.parse(m['date']),
    sets: m['sets'], reps: m['reps'],
    load: (m['load'] as num).toDouble(), notes: m['notes'],
  );
}
