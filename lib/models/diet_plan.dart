// Modelo de dados que representa um Plano de Dieta do usuário
class DietPlan {
  final String id;             // Identificador único do plano de dieta
  final String userId;         // ID do usuário dono do plano
  final String name;           // Nome descritivo da dieta (ex: "Hipertrofia", "Cutting")
  final int calorieGoal;       // Meta diária de calorias a serem consumidas
  final DateTime startDate;    // Data de início da vigência do plano
  final DateTime? endDate;     // Data de término (opcional) do plano

  const DietPlan({required this.id, required this.userId, required this.name,
      required this.calorieGoal, required this.startDate, this.endDate});

  // Converte a instância do modelo para um mapa de chave/valor para persistência no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'user_id': userId, 'name': name,
    'calorie_goal': calorieGoal,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
  };

  // Fábrica para construir uma instância de DietPlan a partir de dados recuperados do SQLite
  factory DietPlan.fromMap(Map<String, dynamic> m) => DietPlan(
    id: m['id'], userId: m['user_id'], name: m['name'],
    calorieGoal: m['calorie_goal'],
    startDate: DateTime.parse(m['start_date']),
    endDate: m['end_date'] != null ? DateTime.parse(m['end_date']) : null,
  );
}
