// Modelo de dados que representa um exercício inserido em um treino/divisão
class ExerciseItem {
  final String id;                  // Identificador único do item de exercício
  final String workoutSessionId;    // ID do treino/sessão vinculada (Treino A, B, etc.)
  final String exerciseId;          // Código de ID único da tabela estática de exercícios
  final String exerciseName;        // Nome comum do exercício (ex: "Supino Reto")
  final String muscleGroup;         // Grupo muscular treinado (ex: "Peito")
  final int sets;                   // Quantidade de séries estipuladas
  final int reps;                   // Quantidade de repetições estipuladas
  final double suggestedLoad;       // Carga sugerida ou inicial recomendada
  final int order;                  // Ordem de execução do exercício no treino

  const ExerciseItem({required this.id, required this.workoutSessionId,
      required this.exerciseId, required this.exerciseName,
      required this.muscleGroup, required this.sets, required this.reps,
      required this.suggestedLoad, required this.order});

  // Converte o objeto de exercício para um mapa (SQLite)
  Map<String, dynamic> toMap() => {
    'id': id, 'workout_session_id': workoutSessionId,
    'exercise_id': exerciseId, 'exercise_name': exerciseName,
    'muscle_group': muscleGroup, 'sets': sets, 'reps': reps,
    'suggested_load': suggestedLoad, 'order_index': order,
  };

  // Instancia um ExerciseItem a partir dos dados do SQLite
  factory ExerciseItem.fromMap(Map<String, dynamic> m) => ExerciseItem(
    id: m['id'], workoutSessionId: m['workout_session_id'],
    exerciseId: m['exercise_id'], exerciseName: m['exercise_name'],
    muscleGroup: m['muscle_group'], sets: m['sets'], reps: m['reps'],
    suggestedLoad: (m['suggested_load'] as num).toDouble(),
    order: m['order_index'],
  );
}
