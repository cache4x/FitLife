# MuscleHelper Flutter — Backlog

## Sprint 1 — Infraestrutura e Autenticação ✓

- [x] Criar projeto Flutter (`pubspec.yaml`, estrutura de pastas)
- [x] Configurar tema dark com Material Design 3 (`lib/theme.dart`)
- [x] Configurar rotas nomeadas em `lib/main.dart`
- [x] Implementar `DatabaseService` (SQLite via sqflite, singleton, 9 tabelas)
- [x] Implementar `AudioService` (audioplayers, fallback silencioso)
- [x] Criar modelos com `toMap()` / `fromMap()`: User, WorkoutPlan, WorkoutSession, ExerciseItem, DietPlan, Meal, MealItem, ScheduleItem, LoadProgression
- [x] Tela de Login — SHA-256, SharedPreferences, som de sucesso
- [x] Tela de Registro — validação completa (nome, email, senha ≥6, confirmação)
- [x] Widgets reutilizáveis: `StatCard`, `AppDrawer`

## Sprint 2 — Treino ✓

- [x] Lista de planos (`WorkoutListScreen`) — goal color map, swipe delete, FAB
- [x] Criar plano (`WorkoutCreateScreen`) — ChoiceChip para objetivo
- [x] Detalhe do plano (`WorkoutDetailScreen`) — sessões com color coding por dia
- [x] Criar sessão (`SessionCreateScreen`) — nome + dropdown dia da semana
- [x] Detalhe da sessão (`SessionDetailScreen`) — exercícios via ModalBottomSheet, dropdown de 20 exercícios pré-cadastrados, sets/reps/carga

## Sprint 3 — Dieta ✓

- [x] Lista de planos alimentares (`DietListScreen`) — badge de kcal, período
- [x] Criar plano alimentar (`DietCreateScreen`) — meta calórica, datas com DatePicker dark
- [x] Detalhe do plano (`DietDetailScreen`) — LinearProgressIndicator, refeições com itens inline, ModalBottomSheet para adicionar refeição e alimento

## Sprint 4 — Agendamento ✓

- [x] Tela de agenda (`ScheduleScreen`) — agrupado por data, filtros com ChoiceChip (Todos/Pendentes/Concluídos/Treino/Refeição)
- [x] Criar agendamento (`ScheduleCreateScreen`) — DatePicker + TimePicker dark, tipo Treino/Refeição
- [x] Marcar como concluído — toca `workout_done.mp3`
- [x] Deletar agendamento

## Sprint 5 — Progressão de Carga ✓

- [x] Tela de progressão (`ProgressionScreen`) — 3 cards de stats (carga máx, último, contagem), gráfico de linha com fl_chart, histórico em ordem decrescente
- [x] Registrar carga (`ProgressionAddScreen`) — detecção automática de PR (compara com máximo existente), toca `new_record.mp3` se PR, SnackBar "🏆 Novo recorde pessoal!"
- [x] Botão "Ver Progressão" em cada exercício na sessão de treino

## Sprint 6 — Dashboard ✓

- [x] Dashboard (`DashboardScreen`) — Future.wait paralelo para stats, StatCard grid, último recorde, próximos agendamentos com botão de concluir, links rápidos, RefreshIndicator

---

## Diferenças em relação ao projeto ASP.NET

| Aspecto | ASP.NET Core MVC | Flutter |
|---------|-----------------|---------|
| Linguagem | C# (.NET 10) | Dart 3.x |
| Framework UI | Razor Views + Bootstrap 5.3 | Flutter 3.x + Material Design 3 |
| Banco | SQLite via EF Core 10 | SQLite via sqflite |
| Auth | Session cookie + BCrypt | SharedPreferences + SHA-256 (crypto) |
| IDs | GUID (string) | UUID v4 (uuid package) |
| Áudio | — | audioplayers (workout_done.mp3, new_record.mp3, login_success.mp3) |
| Gráficos | Chart.js (CDN) | fl_chart 0.69.0 |
| Deploy | Docker Compose (porta 8080) | `flutter run` / APK |
| State | MVC + TempData | setState |
| Forms inline | Modal (Bootstrap) | ModalBottomSheet |

---

## Arquivos de som necessários

Adicionar em `assets/sounds/`:
- `workout_done.mp3` — tocado ao concluir agendamento
- `new_record.mp3` — tocado ao registrar novo recorde pessoal
- `login_success.mp3` — tocado ao fazer login/registro com sucesso

> O app funciona sem os arquivos (fallback silencioso), mas os sons enriquecem a experiência.

---

## Como rodar

```bash
# 1. Instalar Flutter SDK (https://flutter.dev/docs/get-started/install)
# 2. Na pasta do projeto:
flutter pub get
flutter run
```

> Certifique-se de ter um emulador/dispositivo conectado ou o Flutter Web habilitado.
cd