// Modelo de dados que representa uma Refeição (ex: Café da Manhã, Almoço)
class Meal {
  final String id;             // Identificador único da refeição
  final String dietPlanId;     // ID do plano de dieta associado a esta refeição
  final String name;           // Nome da refeição (ex: "Jantar")
  final String suggestedTime;  // Horário sugerido para consumo (ex: "19:00")
  final int totalCalories;     // Total acumulado de calorias da refeição

  const Meal({required this.id, required this.dietPlanId, required this.name,
      required this.suggestedTime, required this.totalCalories});

  // Método auxiliar para criar uma cópia da refeição atualizando campos específicos
  Meal copyWith({int? totalCalories}) => Meal(
    id: id, dietPlanId: dietPlanId, name: name,
    suggestedTime: suggestedTime,
    totalCalories: totalCalories ?? this.totalCalories,
  );

  // Converte a refeição em um mapa para salvar no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'diet_plan_id': dietPlanId, 'name': name,
    'suggested_time': suggestedTime, 'total_calories': totalCalories,
  };

  // Instancia uma Meal a partir dos dados do SQLite
  factory Meal.fromMap(Map<String, dynamic> m) => Meal(
    id: m['id'], dietPlanId: m['diet_plan_id'], name: m['name'],
    suggestedTime: m['suggested_time'] ?? '',
    totalCalories: m['total_calories'] ?? 0,
  );
}
