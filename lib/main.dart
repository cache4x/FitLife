import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/workout/workout_list_screen.dart';
import 'screens/workout/workout_create_screen.dart';
import 'screens/workout/workout_detail_screen.dart';
import 'screens/workout/session_create_screen.dart';
import 'screens/workout/session_detail_screen.dart';
import 'screens/diet/diet_list_screen.dart';
import 'screens/diet/diet_create_screen.dart';
import 'screens/diet/diet_detail_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/schedule/schedule_create_screen.dart';
import 'screens/progression/progression_screen.dart';
import 'screens/progression/progression_add_screen.dart';

// Função principal de inicialização do aplicativo
void main() async {
  // Garante a inicialização das bindings do Flutter antes de rodar o app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Acessa as preferências locais persistidas
  final prefs = await SharedPreferences.getInstance();
  
  // Verifica se existe um ID de usuário já logado
  final userId = prefs.getString('userId');
  
  // Inicia o widget raiz do app passando o estado de login inicial
  runApp(MuscleHelperApp(initialUserId: userId));
}

// Widget raiz do aplicativo MuscleHelper
class MuscleHelperApp extends StatelessWidget {
  final String? initialUserId;
  const MuscleHelperApp({super.key, this.initialUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuscleHelper',
      debugShowCheckedModeBanner: false,
      // Define a identidade visual global do aplicativo
      theme: buildTheme(),
      // Define a rota inicial com base na presença de sessão ativa
      initialRoute: initialUserId != null ? '/dashboard' : '/login',
      // Definição das rotas estáticas do aplicativo
      routes: {
        '/login':              (_) => const LoginScreen(),
        '/register':           (_) => const RegisterScreen(),
        '/dashboard':          (_) => const DashboardScreen(),
        '/workout':            (_) => const WorkoutListScreen(),
        '/workout/create':     (_) => const WorkoutCreateScreen(),
        '/diet':               (_) => const DietListScreen(),
        '/diet/create':        (_) => const DietCreateScreen(),
        '/schedule':           (_) => const ScheduleScreen(),
        '/schedule/create':    (_) => const ScheduleCreateScreen(),
      },
      // Geração dinâmica de rotas para telas que exigem parâmetros
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        final args = settings.arguments as Map<String, dynamic>? ?? {};

        // Rota para a tela de detalhes do treino
        if (uri.path == '/workout/detail') {
          return MaterialPageRoute(builder: (_) => WorkoutDetailScreen(planId: args['planId']));
        }
        // Rota para criação de uma nova sessão de treino
        if (uri.path == '/workout/session/create') {
          return MaterialPageRoute(builder: (_) => SessionCreateScreen(planId: args['planId']));
        }
        // Rota para detalhes da sessão de treino concluída
        if (uri.path == '/workout/session/detail') {
          return MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: args['sessionId']));
        }
        // Rota para visualização detalhada da dieta
        if (uri.path == '/diet/detail') {
          return MaterialPageRoute(builder: (_) => DietDetailScreen(planId: args['planId']));
        }
        // Rota para tela de histórico de progressão de carga
        if (uri.path == '/progression') {
          return MaterialPageRoute(builder: (_) => ProgressionScreen(exerciseId: args['exerciseId'], exerciseName: args['exerciseName']));
        }
        // Rota para adicionar uma nova carga à progressão do exercício
        if (uri.path == '/progression/add') {
          return MaterialPageRoute(builder: (_) => ProgressionAddScreen(exerciseId: args['exerciseId'], exerciseName: args['exerciseName']));
        }
        return null;
      },
    );
  }
}
