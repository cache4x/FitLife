import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// Widget do menu lateral de navegação (Drawer) da aplicação
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Função privada para realizar logout, limpando dados locais e voltando à tela de login
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF181B21),
      child: Column(children: [
        // Cabeçalho estilizado do menu lateral
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFF181B21),
            border: Border(bottom: BorderSide(color: kYellow, width: 2)),
          ),
          child: Row(children: [
            const Icon(Icons.fitness_center, color: kYellow, size: 32),
            const SizedBox(width: 12),
            Text('MUSCLEHELPER',
                style: const TextStyle(color: kYellow, fontWeight: FontWeight.w900,
                    fontSize: 20, letterSpacing: 2)),
          ]),
        ),
        // Links de navegação para as telas principais
        _tile(context, Icons.dashboard_outlined, 'Dashboard',       '/dashboard'),
        _tile(context, Icons.fitness_center,      'Treino',          '/workout'),
        _tile(context, Icons.restaurant_menu,     'Dieta',           '/diet'),
        _tile(context, Icons.calendar_today,      'Agenda',          '/schedule'),
        const Spacer(),
        const Divider(color: kBorder),
        // Item de logout ("Sair") do aplicativo
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
          onTap: () => _logout(context),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  // Widget auxiliar para construir cada item de navegação lateral com detecção de estado ativo
  Widget _tile(BuildContext ctx, IconData icon, String label, String route) {
    final current = ModalRoute.of(ctx)?.settings.name ?? '';
    final active  = current == route;
    return ListTile(
      leading: Icon(icon, color: active ? kYellow : kMuted),
      title: Text(label, style: TextStyle(
          color: active ? kYellow : Colors.white, fontWeight: active ? FontWeight.w700 : FontWeight.normal)),
      tileColor: active ? kYellow.withOpacity(.08) : null,
      onTap: () { Navigator.pop(ctx); if (!active) Navigator.pushNamed(ctx, route); },
    );
  }
}
