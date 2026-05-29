// Modelo de dados que representa uma atividade/evento agendado no cronograma diário
class ScheduleItem {
  final String id;                  // Identificador único da atividade da agenda
  final String userId;              // ID do usuário dono da agenda
  final DateTime date;              // Data e horário planejados para a atividade
  final String type;                // Tipo de atividade (ex: "Treino", "Refeição")
  final String title;               // Título descritivo da atividade
  final String? workoutSessionId;    // ID de sessão de treino opcional
  final String? mealId;             // ID de refeição opcional
  final bool completed;             // Flag indicando se a atividade já foi realizada

  const ScheduleItem({required this.id, required this.userId, required this.date,
      required this.type, required this.title, this.workoutSessionId,
      this.mealId, required this.completed});

  // Copia o item da agenda permitindo atualizar o status de conclusão
  ScheduleItem copyWith({bool? completed}) => ScheduleItem(
    id: id, userId: userId, date: date, type: type, title: title,
    workoutSessionId: workoutSessionId, mealId: mealId,
    completed: completed ?? this.completed,
  );

  // Converte o item de agenda em mapa para salvar no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'user_id': userId, 'date': date.toIso8601String(),
    'type': type, 'title': title,
    'workout_session_id': workoutSessionId,
    'meal_id': mealId, 'completed': completed ? 1 : 0,
  };

  // Instancia um ScheduleItem a partir dos dados do SQLite
  factory ScheduleItem.fromMap(Map<String, dynamic> m) => ScheduleItem(
    id: m['id'], userId: m['user_id'],
    date: DateTime.parse(m['date']), type: m['type'], title: m['title'],
    workoutSessionId: m['workout_session_id'],
    mealId: m['meal_id'], completed: m['completed'] == 1,
  );
}
