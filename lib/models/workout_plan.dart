// Modelo de dados que representa um Plano Geral de Treino (ex: "Foco em Hipertrofia")
class WorkoutPlan {
  final String id;             // Identificador único do plano de treino
  final String userId;         // ID do usuário criador do plano
  final String name;           // Nome descritivo do plano (ex: "Treino ABC")
  final String goal;           // Objetivo do treino (ex: "Emagrecimento", "Força")
  final DateTime createdAt;    // Data de criação do plano

  const WorkoutPlan({required this.id, required this.userId,
      required this.name, required this.goal, required this.createdAt});

  // Converte a instância do plano de treino em mapa para salvar no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'user_id': userId, 'name': name,
    'goal': goal, 'created_at': createdAt.toIso8601String(),
  };

  // Instancia um WorkoutPlan a partir dos dados do SQLite
  factory WorkoutPlan.fromMap(Map<String, dynamic> m) => WorkoutPlan(
    id: m['id'], userId: m['user_id'], name: m['name'],
    goal: m['goal'], createdAt: DateTime.parse(m['created_at']),
  );
}
