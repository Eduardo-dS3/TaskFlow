/// Pessoa da equipe (ou usuário logado).
class Member {
  const Member({
    required this.id,
    required this.name,
    required this.role,
    this.email = '',
    this.isAdmin = false,
    this.active = true,
    this.weeklyCapacity = 40,
    this.lastSeen,
  });

  /// Tempo sem atividade a partir do qual a pessoa deixa de aparecer online.
  static const onlineWindow = Duration(minutes: 5);

  final String id;
  final String name;

  /// Cargo ou função (ex.: "Product Manager").
  final String role;
  final String email;

  /// Administradores gerenciam a equipe e as configurações gerais.
  final bool isAdmin;

  /// Contas desativadas não conseguem entrar no sistema.
  final bool active;

  /// Horas de trabalho disponíveis por semana.
  final double weeklyCapacity;
  final DateTime? lastSeen;

  /// Iniciais exibidas no avatar (ex.: "Mariana Souza" -> "MS").
  String get initials => initialsOf(name);

  bool isOnline(DateTime now) {
    final seen = lastSeen;
    return seen != null && now.difference(seen) < onlineWindow;
  }

  @override
  bool operator ==(Object other) => other is Member && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Iniciais de um nome: primeira letra do primeiro e do último nome, ou as
/// duas primeiras letras quando há um nome só.
String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final single = parts.first;
    return single.substring(0, single.length < 2 ? 1 : 2).toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
