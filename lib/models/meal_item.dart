// Modelo de dados que representa um alimento específico pertencente a uma refeição
class MealItem {
  final String id;        // Identificador único do item de alimento
  final String mealId;    // ID da refeição associada
  final String food;      // Nome do alimento (ex: "Peito de Frango Grelhado")
  final double quantity;  // Quantidade consumida (ex: 150.0)
  final String unit;      // Unidade de medida da quantidade (ex: "g", "ml", "unidades")
  final int calories;     // Valor calórico total dessa porção específica

  const MealItem({required this.id, required this.mealId, required this.food,
      required this.quantity, required this.unit, required this.calories});

  // Converte o item de refeição em um mapa para salvar no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'meal_id': mealId, 'food': food,
    'quantity': quantity, 'unit': unit, 'calories': calories,
  };

  // Instancia um MealItem a partir dos dados do SQLite
  factory MealItem.fromMap(Map<String, dynamic> m) => MealItem(
    id: m['id'], mealId: m['meal_id'], food: m['food'],
    quantity: (m['quantity'] as num).toDouble(),
    unit: m['unit'], calories: m['calories'],
  );
}
