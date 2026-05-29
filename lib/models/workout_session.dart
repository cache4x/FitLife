// Modelo de dados que representa uma divisão específica de um treino (ex: "Treino A - Peito e Tríceps")
class WorkoutSession {
  final String id;              // Identificador único da divisão de treino
  final String workoutPlanId;   // ID do plano de treino geral ao qual pertence
  final String name;            // Nome da divisão (ex: "Treino A")
  final String dayOfWeek;       // Dia(s) da semana sugerido(s) para execução (ex: "Segunda-feira")

  const WorkoutSession({required this.id, required this.workoutPlanId,
      required this.name, required this.dayOfWeek});

  // Converte a divisão de treino em mapa para salvar no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'workout_plan_id': workoutPlanId,
    'name': name, 'day_of_week': dayOfWeek,
  };

  // Instancia uma WorkoutSession a partir dos dados do SQLite
  factory WorkoutSession.fromMap(Map<String, dynamic> m) => WorkoutSession(
    id: m['id'], workoutPlanId: m['workout_plan_id'],
    name: m['name'], dayOfWeek: m['day_of_week'],
  );
}
