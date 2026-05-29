import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../models/exercise_item.dart';
import '../models/diet_plan.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../models/schedule_item.dart';
import '../models/load_progression.dart';

// Serviço de gerenciamento do banco de dados SQLite local
class DatabaseService {
  // Implementação do padrão Singleton para garantir instância única
  static final DatabaseService _instance = DatabaseService._();
  static Database? _db;
  DatabaseService._();
  factory DatabaseService() => _instance;

  // Getter assíncrono para obter a conexão ativa do banco de dados
  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  // Inicializa o banco de dados abrindo ou criando o arquivo SQLite
  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'musclehelper.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Criação das tabelas do banco de dados na primeira inicialização
  Future<void> _onCreate(Database db, int version) async {
    // Tabela de Usuários
    await db.execute('''CREATE TABLE users (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL, created_at TEXT NOT NULL)''');

    // Tabela de Planos de Treino
    await db.execute('''CREATE TABLE workout_plans (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL, name TEXT NOT NULL,
      goal TEXT NOT NULL, created_at TEXT NOT NULL)''');

    // Tabela de Divisões/Sessões de Treino (ex: Treino A, Treino B)
    await db.execute('''CREATE TABLE workout_sessions (
      id TEXT PRIMARY KEY, workout_plan_id TEXT NOT NULL,
      name TEXT NOT NULL, day_of_week TEXT NOT NULL)''');

    // Tabela de Exercícios vinculados a uma divisão de treino
    await db.execute('''CREATE TABLE exercise_items (
      id TEXT PRIMARY KEY, workout_session_id TEXT NOT NULL,
      exercise_id TEXT NOT NULL, exercise_name TEXT NOT NULL,
      muscle_group TEXT NOT NULL, sets INTEGER NOT NULL, reps INTEGER NOT NULL,
      suggested_load REAL NOT NULL, order_index INTEGER NOT NULL)''');

    // Tabela de Planos de Dieta
    await db.execute('''CREATE TABLE diet_plans (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL, name TEXT NOT NULL,
      calorie_goal INTEGER NOT NULL, start_date TEXT NOT NULL,
      end_date TEXT)''');

    // Tabela de Refeições pertencentes a um plano de dieta
    await db.execute('''CREATE TABLE meals (
      id TEXT PRIMARY KEY, diet_plan_id TEXT NOT NULL,
      name TEXT NOT NULL, suggested_time TEXT, total_calories INTEGER NOT NULL)''');

    // Tabela de Itens/Alimentos de uma refeição
    await db.execute('''CREATE TABLE meal_items (
      id TEXT PRIMARY KEY, meal_id TEXT NOT NULL, food TEXT NOT NULL,
      quantity REAL NOT NULL, unit TEXT NOT NULL, calories INTEGER NOT NULL)''');

    // Tabela de Agenda/Cronograma (tarefas diárias de treinos e dietas)
    await db.execute('''CREATE TABLE schedule_items (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL, date TEXT NOT NULL,
      type TEXT NOT NULL, title TEXT NOT NULL,
      workout_session_id TEXT, meal_id TEXT, completed INTEGER NOT NULL)''');

    // Tabela de Histórico de Cargas (progressão de carga nos exercícios)
    await db.execute('''CREATE TABLE load_progressions (
      id TEXT PRIMARY KEY, user_id TEXT NOT NULL, exercise_id TEXT NOT NULL,
      exercise_name TEXT NOT NULL, date TEXT NOT NULL,
      sets INTEGER NOT NULL, reps INTEGER NOT NULL,
      load REAL NOT NULL, notes TEXT)''');
  }

  // ── MÉTODOS DE OPERAÇÃO DOS USUÁRIOS (Cadastro e Login) ──
  Future<void>   insertUser(User u)        async => (await db).insert('users', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  Future<User?>  getUserByEmail(String e)  async { final r = await (await db).query('users', where: 'email = ?', whereArgs: [e]); return r.isEmpty ? null : User.fromMap(r.first); }

  // ── MÉTODOS DE OPERAÇÃO DOS PLANOS DE TREINO (CRUD) ──
  Future<void>             insertWorkoutPlan(WorkoutPlan p)    async => (await db).insert('workout_plans', p.toMap());
  Future<List<WorkoutPlan>> getWorkoutPlans(String userId)     async => ((await db).query('workout_plans', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC')).then((r) => r.map(WorkoutPlan.fromMap).toList());
  Future<WorkoutPlan?>     getWorkoutPlan(String id)           async { final r = await (await db).query('workout_plans', where: 'id = ?', whereArgs: [id]); return r.isEmpty ? null : WorkoutPlan.fromMap(r.first); }
  Future<void>             deleteWorkoutPlan(String id)        async => (await db).delete('workout_plans', where: 'id = ?', whereArgs: [id]);

  // ── MÉTODOS DE OPERAÇÃO DAS SESSÕES DE TREINO (CRUD) ──
  Future<void>               insertWorkoutSession(WorkoutSession s) async => (await db).insert('workout_sessions', s.toMap());
  Future<List<WorkoutSession>> getSessionsByPlan(String planId)     async => ((await db).query('workout_sessions', where: 'workout_plan_id = ?', whereArgs: [planId])).then((r) => r.map(WorkoutSession.fromMap).toList());
  Future<WorkoutSession?>    getWorkoutSession(String id)           async { final r = await (await db).query('workout_sessions', where: 'id = ?', whereArgs: [id]); return r.isEmpty ? null : WorkoutSession.fromMap(r.first); }
  Future<void>               deleteWorkoutSession(String id)        async => (await db).delete('workout_sessions', where: 'id = ?', whereArgs: [id]);

  // ── MÉTODOS DE OPERAÇÃO DOS EXERCÍCIOS VINCULADOS (CRUD) ──
  Future<void>             insertExerciseItem(ExerciseItem e)       async => (await db).insert('exercise_items', e.toMap());
  Future<List<ExerciseItem>> getExercisesBySession(String sessionId) async => ((await db).query('exercise_items', where: 'workout_session_id = ?', whereArgs: [sessionId], orderBy: 'order_index')).then((r) => r.map(ExerciseItem.fromMap).toList());
  Future<void>             deleteExerciseItem(String id)            async => (await db).delete('exercise_items', where: 'id = ?', whereArgs: [id]);

  // ── MÉTODOS DE OPERAÇÃO DOS PLANOS DE DIETA (CRUD) ──
  Future<void>          insertDietPlan(DietPlan p)       async => (await db).insert('diet_plans', p.toMap());
  Future<List<DietPlan>> getDietPlans(String userId)     async => ((await db).query('diet_plans', where: 'user_id = ?', whereArgs: [userId], orderBy: 'start_date DESC')).then((r) => r.map(DietPlan.fromMap).toList());
  Future<DietPlan?>     getDietPlan(String id)           async { final r = await (await db).query('diet_plans', where: 'id = ?', whereArgs: [id]); return r.isEmpty ? null : DietPlan.fromMap(r.first); }
  Future<void>          deleteDietPlan(String id)        async => (await db).delete('diet_plans', where: 'id = ?', whereArgs: [id]);

  // ── MÉTODOS DE OPERAÇÃO DAS REFEIÇÕES (CRUD) ──
  Future<void>        insertMeal(Meal m)                async => (await db).insert('meals', m.toMap());
  Future<List<Meal>>  getMealsByPlan(String dietPlanId) async => ((await db).query('meals', where: 'diet_plan_id = ?', whereArgs: [dietPlanId])).then((r) => r.map(Meal.fromMap).toList());
  Future<void>        deleteMeal(String id)             async => (await db).delete('meals', where: 'id = ?', whereArgs: [id]);
  Future<void>        updateMealCalories(String id, int cal) async => (await db).update('meals', {'total_calories': cal}, where: 'id = ?', whereArgs: [id]);

  // ── MÉTODOS DE OPERAÇÃO DOS ITENS DE REFEIÇÃO (CRUD) ──
  Future<void>           insertMealItem(MealItem i)        async => (await db).insert('meal_items', i.toMap());
  Future<List<MealItem>> getMealItems(String mealId)       async => ((await db).query('meal_items', where: 'meal_id = ?', whereArgs: [mealId])).then((r) => r.map(MealItem.fromMap).toList());
  Future<MealItem?>      getMealItem(String id)            async { final r = await (await db).query('meal_items', where: 'id = ?', whereArgs: [id]); return r.isEmpty ? null : MealItem.fromMap(r.first); }
  Future<void>           deleteMealItem(String id)         async => (await db).delete('meal_items', where: 'id = ?', whereArgs: [id]);

  // ── MÉTODOS DE OPERAÇÃO DO CRONOGRAMA/AGENDA ──
  Future<void>               insertScheduleItem(ScheduleItem s)  async => (await db).insert('schedule_items', s.toMap());
  Future<List<ScheduleItem>> getScheduleItems(String userId)     async => ((await db).query('schedule_items', where: 'user_id = ?', whereArgs: [userId], orderBy: 'date ASC')).then((r) => r.map(ScheduleItem.fromMap).toList());
  Future<void>               completeScheduleItem(String id)     async => (await db).update('schedule_items', {'completed': 1}, where: 'id = ?', whereArgs: [id]);
  Future<void>               deleteScheduleItem(String id)       async => (await db).delete('schedule_items', where: 'id = ?', whereArgs: [id]);

  // ── MÉTODOS DE PROGRESSÃO E HISTÓRICO DE CARGA ──
  Future<void>                   insertProgression(LoadProgression p)     async => (await db).insert('load_progressions', p.toMap());
  Future<List<LoadProgression>>  getProgressions(String userId, String exId) async => ((await db).query('load_progressions', where: 'user_id = ? AND exercise_id = ?', whereArgs: [userId, exId], orderBy: 'date ASC')).then((r) => r.map(LoadProgression.fromMap).toList());
  Future<LoadProgression?>       getLastProgression(String userId)        async { final r = await (await db).query('load_progressions', where: 'user_id = ?', whereArgs: [userId], orderBy: 'date DESC', limit: 1); return r.isEmpty ? null : LoadProgression.fromMap(r.first); }
  Future<void>                   deleteProgression(String id)             async => (await db).delete('load_progressions', where: 'id = ?', whereArgs: [id]);

  // ── CONSULTAS E MÉTRICAS DO PAINEL DE CONTROLE (DASHBOARD) ──
  // Conta quantos treinos foram concluídos na semana atual
  Future<int> countWorkoutsThisWeek(String userId) async {
    final now   = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final s = DateTime(start.year, start.month, start.day).toIso8601String();
    final e = DateTime(start.year, start.month, start.day + 7).toIso8601String();
    final r = await (await db).rawQuery(
      "SELECT COUNT(*) as c FROM schedule_items WHERE user_id = ? AND type = 'Treino' AND date >= ? AND date < ? AND completed = 1",
      [userId, s, e]);
    return r.first['c'] as int;
  }

  // Conta a quantidade total de planos de treino do usuário
  Future<int> countWorkoutPlans(String userId) async {
    final r = await (await db).rawQuery('SELECT COUNT(*) as c FROM workout_plans WHERE user_id = ?', [userId]);
    return r.first['c'] as int;
  }

  // Conta a quantidade total de planos de dieta do usuário
  Future<int> countDietPlans(String userId) async {
    final r = await (await db).rawQuery('SELECT COUNT(*) as c FROM diet_plans WHERE user_id = ?', [userId]);
    return r.first['c'] as int;
  }

  // Busca os próximos itens da agenda que ainda não foram concluídos
  Future<List<ScheduleItem>> getUpcoming(String userId, {int limit = 5}) async {
    final now = DateTime.now().toIso8601String();
    final r = await (await db).query('schedule_items',
        where: 'user_id = ? AND date >= ? AND completed = 0',
        whereArgs: [userId, now], orderBy: 'date ASC', limit: limit);
    return r.map(ScheduleItem.fromMap).toList();
  }
}

// Catálogo estático em memória com exercícios padrões (para seleção no app)
const List<Map<String, String>> kExercises = [
  {'id': 'ex-peito-supino',             'name': 'Supino Reto',           'muscle': 'Peito'},
  {'id': 'ex-peito-crucifixo',          'name': 'Crucifixo',             'muscle': 'Peito'},
  {'id': 'ex-ombros-desenvolvimento',   'name': 'Desenvolvimento Militar','muscle': 'Ombros'},
  {'id': 'ex-ombros-elevacao',          'name': 'Elevação Lateral',      'muscle': 'Ombros'},
  {'id': 'ex-biceps-rosca-direta',      'name': 'Rosca Direta',          'muscle': 'Bíceps'},
  {'id': 'ex-biceps-martelo',           'name': 'Rosca Martelo',         'muscle': 'Bíceps'},
  {'id': 'ex-triceps-pulley',           'name': 'Tríceps na Polia',      'muscle': 'Tríceps'},
  {'id': 'ex-triceps-frances',          'name': 'Tríceps Francês',       'muscle': 'Tríceps'},
  {'id': 'ex-costas-barra-fixa',        'name': 'Barra Fixa',            'muscle': 'Costas'},
  {'id': 'ex-costas-remada',            'name': 'Remada Curvada',        'muscle': 'Costas'},
  {'id': 'ex-abdomen-prancha',          'name': 'Prancha',               'muscle': 'Abdômen'},
  {'id': 'ex-abdomen-supra',            'name': 'Abdominal Supra',       'muscle': 'Abdômen'},
  {'id': 'ex-quadriceps-agachamento',   'name': 'Agachamento Livre',     'muscle': 'Quadríceps'},
  {'id': 'ex-quadriceps-leg-press',     'name': 'Leg Press 45°',         'muscle': 'Quadríceps'},
  {'id': 'ex-gluteos-hip-thrust',       'name': 'Hip Thrust',            'muscle': 'Glúteos'},
  {'id': 'ex-gluteos-polia',            'name': 'Glúteo na Polia',       'muscle': 'Glúteos'},
  {'id': 'ex-posteriores-stiff',        'name': 'Stiff',                 'muscle': 'Posteriores'},
  {'id': 'ex-posteriores-mesa',         'name': 'Mesa Flexora',          'muscle': 'Posteriores'},
  {'id': 'ex-panturrilha-em-pe',        'name': 'Panturrilha em Pé',     'muscle': 'Panturrilha'},
  {'id': 'ex-panturrilha-sentado',      'name': 'Panturrilha Sentado',   'muscle': 'Panturrilha'},
];
