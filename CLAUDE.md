# MuscleHelper Flutter — Guia de Sessão

## Objetivo

Versão Flutter do MuscleHelper — plataforma completa de fitness com autenticação e quatro módulos: **Dieta**, **Treino**, **Agendamento** e **Progressão de Carga**. Projeto independente do ASP.NET Core (usado em disciplina separada na faculdade).

---

## Stack

- **Dart 3.x** + **Flutter 3.x**
- **Material Design 3** (tema dark customizado)
- **sqflite** + **path** — SQLite local no dispositivo
- **audioplayers ^6.1.0** — sons nativos (workout_done, new_record, login_success)
- **crypto** — SHA-256 para hash de senha
- **shared_preferences** — sessão do usuário (userId + userName)
- **fl_chart ^0.69.0** — gráfico de progressão de carga (LineChart)
- **uuid** — geração de IDs (v4)
- **intl** — formatação de datas

---

## Convenções do projeto

- IDs são `String` (UUID v4 gerado no momento de inserção)
- Sem Provider/BLoC — estado gerenciado com `setState` simples
- Sem backend — SQLite totalmente local
- Formulários inline via `showModalBottomSheet`
- Rotas nomeadas + `onGenerateRoute` para rotas com parâmetros
- Senha hasheada com SHA-256 via pacote `crypto`
- Sessão armazenada em `SharedPreferences` (`userId`, `userName`)
- Tema: `kBg=#0E1116`, `kYellow=#F5D10D`, `kCard=#1C2027`, `kBorder=#2A2F38`, `kMuted=#9AA0A6`

---

## Estrutura de arquivos

```
lib/
  main.dart                         ← rotas + initialRoute por sessão
  theme.dart                        ← buildTheme(), constantes de cor
  db/
    database_service.dart           ← Singleton, 9 tabelas, CRUD completo
  services/
    audio_service.dart              ← Singleton, 3 sons com fallback silencioso
  models/
    user.dart
    workout_plan.dart
    workout_session.dart
    exercise_item.dart
    diet_plan.dart
    meal.dart
    meal_item.dart
    schedule_item.dart
    load_progression.dart
  widgets/
    stat_card.dart                  ← StatCard(value, label, sub?)
    app_drawer.dart                 ← Drawer com navegação + logout
  screens/
    auth/
      login_screen.dart
      register_screen.dart
    home/
      dashboard_screen.dart
    workout/
      workout_list_screen.dart
      workout_create_screen.dart
      workout_detail_screen.dart
      session_create_screen.dart
      session_detail_screen.dart
    diet/
      diet_list_screen.dart
      diet_create_screen.dart
      diet_detail_screen.dart
    schedule/
      schedule_screen.dart
      schedule_create_screen.dart
    progression/
      progression_screen.dart
      progression_add_screen.dart
assets/
  sounds/
    workout_done.mp3
    new_record.mp3
    login_success.mp3
```

---

## Schema SQLite (tabelas criadas em `_onCreate`)

### `users`
| Coluna | Tipo | Obs |
|--------|------|-----|
| id | TEXT PK | UUID |
| name | TEXT | |
| email | TEXT UNIQUE | |
| passwordHash | TEXT | SHA-256 |
| createdAt | TEXT | ISO 8601 |

### `workout_plans`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| userId | TEXT FK |
| name | TEXT |
| goal | TEXT |
| createdAt | TEXT |

### `workout_sessions`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| workoutPlanId | TEXT FK |
| name | TEXT |
| dayOfWeek | TEXT |

### `exercise_items`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| workoutSessionId | TEXT FK |
| exerciseId | TEXT |
| exerciseName | TEXT |
| sets | INTEGER |
| reps | INTEGER |
| suggestedLoad | REAL |
| order | INTEGER |

### `diet_plans`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| userId | TEXT FK |
| name | TEXT |
| calorieGoal | INTEGER |
| startDate | TEXT |
| endDate | TEXT nullable |

### `meals`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| dietPlanId | TEXT FK |
| name | TEXT |
| suggestedTime | TEXT |
| totalCalories | INTEGER |

### `meal_items`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| mealId | TEXT FK |
| food | TEXT |
| quantity | REAL |
| unit | TEXT |
| calories | INTEGER |

### `schedule_items`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| userId | TEXT FK |
| date | TEXT |
| type | TEXT (`Treino` ou `Refeicao`) |
| title | TEXT |
| completed | INTEGER (0/1) |

### `load_progressions`
| Coluna | Tipo |
|--------|------|
| id | TEXT PK |
| userId | TEXT FK |
| exerciseId | TEXT FK |
| exerciseName | TEXT |
| date | TEXT |
| sets | INTEGER |
| reps | INTEGER |
| load | REAL |
| notes | TEXT nullable |

---

## Rotas nomeadas

| Rota | Tela |
|------|------|
| `/login` | LoginScreen |
| `/register` | RegisterScreen |
| `/dashboard` | DashboardScreen |
| `/workout` | WorkoutListScreen |
| `/workout/create` | WorkoutCreateScreen |
| `/workout/detail` | WorkoutDetailScreen (arg: `{'planId', 'planName'}`) |
| `/session/create` | SessionCreateScreen (arg: `{'planId'}`) |
| `/session/detail` | SessionDetailScreen (arg: `{'sessionId', 'sessionName'}`) |
| `/diet` | DietListScreen |
| `/diet/create` | DietCreateScreen |
| `/diet/detail` | DietDetailScreen (arg: `{'planId'}`) |
| `/schedule` | ScheduleScreen |
| `/schedule/create` | ScheduleCreateScreen |
| `/progression` | ProgressionScreen (arg: `{'exerciseId', 'exerciseName'}`) |
| `/progression/add` | ProgressionAddScreen (arg: `{'exerciseId', 'exerciseName'}`) |

---

## Exercícios pré-cadastrados

`DatabaseService.kExercises` — lista de 20 exercícios com ID, nome e grupo muscular. Usada nos dropdowns de seleção de exercício (sem banco, apenas em memória).

---

## Funcionalidades de áudio

| Evento | Arquivo |
|--------|---------|
| Login / Registro bem-sucedido | `login_success.mp3` |
| Agendamento marcado como concluído | `workout_done.mp3` |
| Novo recorde pessoal de carga | `new_record.mp3` |

> Adicionar os arquivos .mp3 em `assets/sounds/`. O app não quebra se os arquivos estiverem ausentes.

---

## Como rodar

```bash
# Instalar Flutter SDK: https://flutter.dev/docs/get-started/install

cd "Trabalho Dezani Flutter"
flutter pub get
flutter run
```

Para gerar APK de release:
```bash
flutter build apk --release
```

---

## Projeto relacionado

O projeto ASP.NET Core MVC equivalente está em `C:\Users\leona\OneDrive\Documentos\Claude\Projects\Trabalho Dezani\`. Ambos os projetos implementam as mesmas funcionalidades, mas são completamente independentes — backends, bancos e linguagens diferentes. Não há comunicação entre eles.
