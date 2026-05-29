// Modelo de dados que representa o Usuário do sistema
class User {
  final String id;             // Identificador único (UUID) do usuário
  final String name;           // Nome completo do usuário
  final String email;          // Email exclusivo para login
  final String passwordHash;   // Senha criptografada (hash) para autenticação
  final DateTime createdAt;    // Data e hora de criação da conta

  const User({required this.id, required this.name, required this.email,
      required this.passwordHash, required this.createdAt});

  // Converte a conta de usuário para mapa para salvar no SQLite
  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email,
    'password_hash': passwordHash,
    'created_at': createdAt.toIso8601String(),
  };

  // Instancia um User a partir dos dados do SQLite
  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'], name: m['name'], email: m['email'],
    passwordHash: m['password_hash'],
    createdAt: DateTime.parse(m['created_at']),
  );
}
